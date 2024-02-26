//
//  MandoGameEngine.m
//  Mando
//
//  Created by Mario Diana on 4/27/21.
//

#import "MandoGameEngine.h"

#import "MandoGame.h"
#import "MDXPausableTimer.h"
#import "MandoNotifications.h"
#import "MandoSettingsStore.h"

#define SPEED_INCREASE 0.9583
#define MIN_INTERVAL 0.25

#define PauseForRoundInterval() [NSThread sleepForTimeInterval:0.6]
#define PauseForInterval() [NSThread sleepForTimeInterval:[self playRateInterval]]

@interface MandoErrorTone : NSObject
- (int)midiNote;
@end

@implementation MandoErrorTone

- (int)midiNote
{
    return 111;
}

@end


@interface MandoGameEngine ()
@property (nonatomic, assign, getter=isAcceleratingEachRound) BOOL accelerateEachRound;
@property (nonatomic, assign) NSTimeInterval playRateInterval;
@property (nonatomic, assign) NSInteger notesPerRound;
@property (nonatomic, strong) MDXPausableTimer* timer;
@property (nonatomic, strong) NSArray* tones;
@property (nonatomic, weak) id<MandoGameEngineDelegate> delegate;
@property (nonatomic, strong) MandoGame* game;
@property (nonatomic, strong) id<MandoRound> currentRound;
@property (nonatomic, assign) NSInteger roundCursor;
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, assign, getter=isReset) BOOL reset;
@property (nonatomic, assign, getter=hasUserTerminatedGame) BOOL userTerminatedGame;
@end

@implementation MandoGameEngine

- (void)dealloc
{
    _tones = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)initWithMidiTones:(NSArray *)tones delegate:(id<MandoGameEngineDelegate>)delegate
{
    self = [super init];
    
    if (self) {
        _accelerateEachRound = [[MandoSettingsStore sharedStore] isAcceleratingEachRound];
        _playRateInterval = [[MandoSettingsStore sharedStore] playRate];
        _notesPerRound = [[MandoSettingsStore sharedStore] notesPerRound];
        _tones = tones;
        _delegate = delegate;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userSettingsDidChange:)
                                                     name:MandoUserSettingsDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}


- (void)userSettingsDidChange:(NSNotification *)notification
{
    MandoSettingsStore* settings = [notification object];
    
    // The simplest thing to do is update everything.
    self.accelerateEachRound = [settings isAcceleratingEachRound];
    self.playRateInterval = [settings playRate];
    self.notesPerRound = [settings notesPerRound];
}


- (void)resetPlayRateInterval
{
    self.playRateInterval = [[MandoSettingsStore sharedStore] playRate];
    
    if ([self isAcceleratingEachRound]) {
        // Round 2 will then be at the user's desired starting speed.
        self.playRateInterval = self.playRateInterval / SPEED_INCREASE;
    }
}


- (void)updatePlayRateInterval
{
    if ([self isAcceleratingEachRound] && [self playRateInterval] > MIN_INTERVAL) {
        self.playRateInterval = self.playRateInterval * SPEED_INCREASE;
    }
}


- (void)startNewGame
{
    self.userTerminatedGame = NO;
    [self resetPlayRateInterval];
    [self playRound];
}


- (void)resetRound
{
    [[self timer] invalidate];
    self.reset = YES;
    self.paused = NO;
    
    [self playRound];
}


- (void)playRound
{
    if (![self game]) {
        self.game = [[MandoGame alloc] initWithMidiTones:[self tones]];
    }
    
    NSLog(@"## Play rate interval: %.2f", [self playRateInterval]);
    NSLog(@"## Notes added per round: %ld", [self notesPerRound]);
    id<MandoRound> round = [self currentRound];
    
    if (![self isReset]) {
        round = [[self game] nextRoundWithNoteCount:[self notesPerRound] playRate:[self playRateInterval]];
        self.currentRound = round;
    }
    
    [[self delegate] gameEngine:self willBeginCallForRoundNumber:[round roundNumber]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PauseForRoundInterval();
        
        [self handleGamePause];
        BOOL terminated = NO;
        self.reset = NO;
        
        for (id tone in [round toneSequence]) {
            terminated = [self handleGamePause];
            
            if (terminated || [self isReset]) {
                break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self delegate] gameEngine:self didChooseTone:tone];
            });
            
            PauseForInterval();
        }
        
        if ([self isReset]) {
            self.reset = NO;
        }
        else if (!terminated) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.roundCursor = 0;
                [[self delegate] gameEngine:self didCompleteCallForRoundNumber:[round roundNumber]];
                
                [self startTimer];
            });
        }
    });
    
    [self updatePlayRateInterval];
}


- (void)startTimer
{
    self.timer = [[MDXPausableTimer alloc] initWithTimeInterval:7.0 block:^(NSTimer *timer) {
        [self timerFireMethod:timer];
    }];
}


- (void)evaluateTone:(id)candidate
{
    id tone = [[[self currentRound] toneSequence] objectAtIndex:[self roundCursor]];
    BOOL matched = [tone isEqual:candidate];
    
    if (!matched) {
        [self terminateGame];
        return;
    }
    
    [[self timer] invalidate];
    self.timer = nil;
    
    self.roundCursor += 1;
    
    if ([[[self currentRound] toneSequence] count] == [self roundCursor]) {
        [[self delegate] gameEngine:self
        didCompleteResponseForRound:[self currentRound]
                         withResult:YES];
    }
    else {
        [self startTimer];
    }
}


- (void)terminateGame
{
    self.game = nil;
    
    [[self timer] invalidate];
    self.timer = nil;
    
    [[self delegate] gameEngine:self didEvaluateTone:[[MandoErrorTone alloc] init]];
    
    [[self delegate] gameEngine:self
    didCompleteResponseForRound:[self currentRound]
                     withResult:NO];
}


- (void)timerFireMethod:(NSTimer *)timer
{
    NSLog(@"## Timeout!");
    [self terminateGame];
}


- (void)pause
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    if ([self isPaused]) {
        return;
    }
    
    self.paused = YES;
    
    if ([self timer]) {
        [[self timer] pause];
    }
}


- (void)resume
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    self.paused = NO;
    
    if ([self timer]) {
        [[self timer] resume];
    }
}


- (void)terminate
{
    self.userTerminatedGame = YES;
    [self terminateGame];
    self.paused = NO;
}


- (BOOL)handleGamePause
{
    if ([self isPaused]) {
        for (;;) {
            [NSThread sleepForTimeInterval:0.1];
            if (![self isPaused]) break;
        }
    }
    
    return [self hasUserTerminatedGame];
}

@end
