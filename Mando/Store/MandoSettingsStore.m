//
//  MandoSettingsStore.m
//  Mando
//
//  Created by Mario Diana on 5/16/21.
//

#import "MandoSettingsStore.h"
#import "MandoNotifications.h"

NSString* const MandoUserSettingsKey = @"MandoUserSettingsKey";
NSString* const MandoAccelerateEachRoundKey = @"AccelerateEachRound";
NSString* const MandoPlayRateKey = @"PlayRate";
NSString* const MandoNotesPerRoundKey = @"NotesPerRound";

@implementation MandoSettingsStore
@dynamic playRate, notesPerRound;

+ (MandoSettingsStore *)sharedStore
{
    static dispatch_once_t onceToken;
    static MandoSettingsStore* instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[MandoSettingsStore alloc] initSharedInstance];
    });
    
    return instance;
}


- (instancetype)initSharedInstance
{
    self = [super init];
    
    if (self) {
        // Load it into memory early on.
        [self settings];
    }
    
    return self;
}


- (NSDictionary *)settings
{
    // Initialize all default settngs, as needed.
    NSDictionary* userSettings =
        [[NSUserDefaults standardUserDefaults] dictionaryForKey:MandoUserSettingsKey];
    
    if (!userSettings) {
        // We should only need to do this once, since we'll persist defaults immediately.
        NSLog(@"## Intializing user settings dictionary...");
        NSDictionary* config = @{
            MandoAccelerateEachRoundKey: [NSNumber numberWithBool:YES],
            MandoPlayRateKey: [NSNumber numberWithFloat:0.6],
            MandoNotesPerRoundKey: [NSNumber numberWithInteger:1]
        };
        
        userSettings = [NSDictionary dictionaryWithDictionary:config];
        [[NSUserDefaults standardUserDefaults] setObject:userSettings
                                                  forKey:MandoUserSettingsKey];
    }
    
    return userSettings;
}


- (BOOL)isAcceleratingEachRound
{
    return [[[self settings] objectForKey:MandoAccelerateEachRoundKey] boolValue];
}


- (void)setAccelerateEachRound:(BOOL)accelerateEachRound
{
    id value = [NSNumber numberWithBool:accelerateEachRound];
    [self updateSettingsWithObject:value forKey:MandoAccelerateEachRoundKey];
}


- (NSTimeInterval)playRate
{
    return [[[self settings] objectForKey:MandoPlayRateKey] floatValue];
}


- (void)setPlayRate:(NSTimeInterval)playRate
{
    id value = [NSNumber numberWithFloat:playRate];
    [self updateSettingsWithObject:value forKey:MandoPlayRateKey];
}


- (NSInteger)notesPerRound
{
    return [[[self settings] objectForKey:MandoNotesPerRoundKey] integerValue];
}


- (void)setNotesPerRound:(NSInteger)notesPerRound
{
    id value = [NSNumber numberWithInteger:notesPerRound];
    [self updateSettingsWithObject:value forKey:MandoNotesPerRoundKey];
}


- (void)updateSettingsWithObject:(id)object forKey:(id)key
{
    NSMutableDictionary* settings =
        [NSMutableDictionary dictionaryWithDictionary:[self settings]];
    
    [settings setObject:object forKey:key];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:settings]
                                              forKey:MandoUserSettingsKey];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MandoUserSettingsDidChangeNotification
                                                        object:self];
}

@end
