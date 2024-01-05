//
//  MandoGameRecord.h
//  Mando
//
//  Created by Mario Diana on 6/7/21.
//

#import <Foundation/Foundation.h>
#import "MandoRound.h"


@interface MandoGameRecord : NSObject <MandoRound>

- (instancetype)initWithGameRound:(id<MandoRound>)round;

@end
