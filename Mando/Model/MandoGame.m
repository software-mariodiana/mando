//
//  MandoGame.m
//  Mando
//
//  Created by Mario Diana on 4/28/21.
//

#import "MandoGame.h"


@interface MandoRound : NSObject <MandoRound>
@property (nonatomic, strong) NSArray* toneSequence;
@property (nonatomic, assign) NSInteger roundNumber;
@property (nonatomic, assign) NSTimeInterval playRate;
@end

@implementation MandoRound

@end


@interface MandoGame ()
@property (nonatomic, strong) NSArray* tones;
@property (nonatomic, strong) NSMutableArray* sequence;
@property (nonatomic, assign) NSInteger roundNumber;
@end

@implementation MandoGame

- (instancetype)initWithMidiTones:(NSArray *)tones
{
    self = [super init];
    
    if (self) {
        _sequence = [NSMutableArray array];
        _tones = tones;
    }
    
    return self;
}


- (id<MandoRound>)nextRoundWithNoteCount:(NSInteger)noteCount playRate:(NSTimeInterval)interval
{
    MandoRound* round = [[MandoRound alloc] init];
    
    for (int i = 0; i < noteCount; i++) {
        uint32_t i = (uint32_t)[[self tones] count];
        id tone = [[self tones] objectAtIndex:arc4random_uniform(i)];
        [[self sequence] addObject:tone];
    }
    
    self.roundNumber += 1;
    round.toneSequence = [NSArray arrayWithArray:[self sequence]];
    round.roundNumber = self.roundNumber;
    round.playRate = interval;
    
    return round;
}

@end
