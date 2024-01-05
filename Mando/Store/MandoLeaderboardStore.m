//
//  MandoLeaderboardStore.m
//  Mando
//
//  Created by Mario Diana on 5/10/21.
//

#import "MandoLeaderboardStore.h"

#import "MandoGameRecord.h"
#import "MandoMidiPlaying.h"

#define MANDO_LEADER_MAX 10

typedef id (^MapBlock)(id element);

NSArray* Map(NSArray* list, MapBlock block) {
    NSMutableArray* result = [NSMutableArray array];
    for (id item in list) {
        [result addObject:block(item)];
    }
    return [NSArray arrayWithArray:result];
}

NSString* const MandoLeaderboardScoresKey = @"MandoLeaderboardScoresKey";
NSString* const MandoLeaderboardLastGamePlayedKey = @"MandoLeaderboardLastGamePlayedKey";

@interface MandoTone : NSObject <MandoMidiPlaying>
@property (nonatomic, assign) int midiNote;
@end

@implementation MandoTone
@end

@interface MandoGameLeader : NSObject <MandoGameLeader>

@property (nonatomic, copy) NSString* score;
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSArray* toneSequence;

+ (NSISO8601DateFormatter *)ISO8601DateFormatter;
+ (NSDateFormatter *)dateFormatter;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithGameRecord:(MandoGameRecord *)record;
- (NSString *)dateString;
- (NSComparisonResult)compare:(MandoGameLeader *)other;
- (MandoGameLeader *)after:(MandoGameLeader *)other;

@end

@implementation MandoGameLeader

+ (NSISO8601DateFormatter *)ISO8601DateFormatter
{
    static dispatch_once_t onceISO8601Token;
    static NSISO8601DateFormatter* df;
    
    dispatch_once(&onceISO8601Token, ^{
        df = [[NSISO8601DateFormatter alloc] init];
    });
    
    return df;
}

+ (NSDateFormatter *)dateFormatter
{
    static dispatch_once_t onceDateFormatterToken;
    static NSDateFormatter* df;

    dispatch_once(&onceDateFormatterToken, ^{
        df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterFullStyle;
        df.timeStyle = NSDateFormatterMediumStyle;
        df.doesRelativeDateFormatting = YES;
    });
    
    return df;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    // Invalid instantiation without a dictionary.
    self = (dictionary) ? [super init] : nil;
    
    if (self) {
        _score = [dictionary objectForKey:@"score"];
        _date = [[MandoGameLeader ISO8601DateFormatter] dateFromString:[dictionary objectForKey:@"ISO8602DateString"]];
        
        NSArray* toneSequence = Map([dictionary objectForKey:@"toneSequence"], ^id(id element) {
            MandoTone* tone = [[MandoTone alloc] init];
            tone.midiNote = [element intValue];
            return tone;
        });
        
        _toneSequence = toneSequence;
    }
    
    return self;
}

- (instancetype)initWithGameRecord:(MandoGameRecord *)record
{
    // Invalid instantiation without game record.
    self = (record) ? [super init] : nil;
    
    if (self) {
        _score = [NSString stringWithFormat:@"%ld", [record roundNumber]];
        
        NSArray* toneSequence = Map([record toneSequence], ^id(id element) {
            MandoTone* tone = [[MandoTone alloc] init];
            tone.midiNote = [element midiNote];
            return tone;
        });
        
        _toneSequence = [NSArray arrayWithArray:toneSequence];
    }
    
    return self;
}

- (NSString *)dateString
{
    return [[MandoGameLeader dateFormatter] stringFromDate:[self date]];
}

- (NSDictionary *)dictionary
{
    NSArray* toneSequence = Map([self toneSequence], ^id(id element) {
        int midiNote = [element midiNote];
        return [NSNumber numberWithInt:midiNote];
    });
    
    return @{
        @"score": [self score],
        @"toneSequence": toneSequence,
        @"ISO8602DateString": [[MandoGameLeader ISO8601DateFormatter] stringFromDate:[self date]]
    };
}

- (NSComparisonResult)compare:(MandoGameLeader *)other
{
    // Sorted by score, with equal scores sorted by date.
    if ([[self score] integerValue] > [[other score] integerValue]) {
        return NSOrderedDescending;
    }
    else if ([[self score] integerValue] < [[other score] integerValue]) {
        return NSOrderedAscending;
    }
    else {
        return [[self date] compare:[other date]];
    }
}
 
- (MandoGameLeader *)after:(MandoGameLeader *)other
{
    NSDate* later = [[self date] laterDate:[other date]];
    
    if ([[self date] isEqualToDate:later]) {
        return self;
    }
    else {
        return  other;
    }
}

@end


@interface MandoLeaderboardStore ()
@property (nonatomic, strong) NSArray* sortedLeaders;
@property (nonatomic, strong) MandoGameLeader* lastGamePlayed;
@end

@implementation MandoLeaderboardStore

+ (MandoLeaderboardStore *)sharedStore
{
    static dispatch_once_t onceToken;
    static MandoLeaderboardStore* instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[MandoLeaderboardStore alloc] initSharedInstance];
    });
    
    return instance;
}

- (instancetype)initSharedInstance
{
    self = [super init];
    
    if (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
            NSArray* leadersPlist = [user arrayForKey:MandoLeaderboardScoresKey] ?: @[];
            
            NSArray* leaders = Map(leadersPlist, ^id(id element) {
                return [[MandoGameLeader alloc] initWithDictionary:element];
            });
            
            NSDictionary* record = [user dictionaryForKey:MandoLeaderboardLastGamePlayedKey];
            
            if (record) {
                // On a first run, there is no record.
                MandoGameLeader* lastGame = [[MandoGameLeader alloc] initWithDictionary:record];
                self->_lastGamePlayed = lastGame;
            }
            
            self.sortedLeaders = [leaders sortedArrayUsingSelector:@selector(compare:)];
        });
    }
    
    return self;
}

- (void)prune
{
    //FIXME: I suspect something about this pruning operation is redundant.
    NSUInteger count =
        ([[self sortedLeaders] count] > MANDO_LEADER_MAX) ? MANDO_LEADER_MAX : [[self sortedLeaders] count];
    
    self.sortedLeaders = [[self sortedLeaders] subarrayWithRange:NSMakeRange(0, count)];
}

- (id<MandoGameLeader>)lastGamePlayed
{
    __block MandoGameLeader* target = nil;
    
    [[self sortedLeaders] enumerateObjectsUsingBlock:^(MandoGameLeader* leader, NSUInteger idx, BOOL* stop) {
        target = [leader after:target];
    }];
    
    return target;
}

- (NSArray *)leaders
{
    NSArray* sortedLeaders = [[[self sortedLeaders] reverseObjectEnumerator] allObjects];
    NSUInteger count =
        ([sortedLeaders count] > MANDO_LEADER_MAX) ? MANDO_LEADER_MAX : [sortedLeaders count];
    
    NSLog(@"Count: %ld", count);
    
    return [sortedLeaders subarrayWithRange:NSMakeRange(0, count)];
}

- (void)addGameRecord:(MandoGameRecord *)record
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    MandoGameLeader* leader = [[MandoGameLeader alloc] initWithGameRecord:record];
    leader.date = [NSDate date];
    
    [self setLastGamePlayed:leader];
    
    NSMutableArray* leaders = [NSMutableArray arrayWithArray:[self sortedLeaders]];
    [leaders addObject:leader];
    
    self.sortedLeaders = [leaders sortedArrayUsingSelector:@selector(compare:)];
    
    // We only want to persist the last 10 (or so).
    NSArray* leadersPlist = Map([self leaders], ^id(id element) {
        return [element dictionary];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
        [user setObject:leadersPlist forKey:MandoLeaderboardScoresKey];
        [user setObject:[leader dictionary] forKey:MandoLeaderboardLastGamePlayedKey];
    });
}

@end
