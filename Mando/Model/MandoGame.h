//
//  MandoGame.h
//  Mando
//
//  Created by Mario Diana on 4/28/21.
//

#import <Foundation/Foundation.h>
#import "MandoRound.h"

@interface MandoGame : NSObject

- (instancetype)initWithMidiTones:(NSArray *)tones;

- (id<MandoRound>)nextRoundWithNoteCount:(NSInteger)noteCount playRate:(NSTimeInterval)interval;

@end
