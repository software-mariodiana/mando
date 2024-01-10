//
//  MandoGameLeader.h
//  Mando
//
//  Created by Mario Diana on 6/7/21.
//

#import <Foundation/Foundation.h>
#import "MandoMidiPlaying.h"

@protocol MandoGameLeader <NSObject>
- (NSString *)score;
- (NSString *)dateString;
- (NSArray *)toneSequence;
- (NSTimeInterval)playRate;
@end
