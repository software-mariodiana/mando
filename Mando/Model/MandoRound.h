//
//  MandoRound.h
//  Mando
//
//  Created by Mario Diana on 6/7/21.
//

#import <Foundation/Foundation.h>

@protocol MandoRound <NSObject>
- (NSInteger)roundNumber;
- (NSArray *)toneSequence;
- (NSTimeInterval)playRate;
@end
