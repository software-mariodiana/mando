//
//  MandoGameEngine.h
//  Mando
//
//  Created by Mario Diana on 4/27/21.
//

#import <Foundation/Foundation.h>
#import "MandoRound.h"

@class MandoGameEngine;


@protocol MandoGameEngineDelegate <NSObject>

- (void)gameEngine:(MandoGameEngine *)engine didChooseTone:(id)tone;

- (void)gameEngine:(MandoGameEngine *)engine didEvaluateTone:(id)tone;

- (void)gameEngine:(MandoGameEngine *)engine willBeginCallForRoundNumber:(NSInteger)round;

- (void)gameEngine:(MandoGameEngine *)engine didCompleteCallForRoundNumber:(NSInteger)round;

- (void)gameEngine:(MandoGameEngine *)engine
didCompleteResponseForRound:(id<MandoRound>)round
        withResult:(BOOL)success;

@end


@interface MandoGameEngine : NSObject

- (instancetype)initWithMidiTones:(NSArray *)tones delegate:(id<MandoGameEngineDelegate>)delegate;

- (void)startNewGame;

- (void)resetRound;

- (void)playRound;

- (void)evaluateTone:(id)candidate;

- (void)pause;

- (void)resume;

- (void)terminate;

- (id<MandoGameEngineDelegate>)delegate;

@end
