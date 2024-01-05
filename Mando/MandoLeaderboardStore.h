//
//  MandoLeaderboardStore.h
//  Mando
//
//  Created by Mario Diana on 5/10/21.
//

#import <Foundation/Foundation.h>
#import "MandoGameLeader.h"

@class MandoGameRecord;


@interface MandoLeaderboardStore : NSObject

+ (MandoLeaderboardStore *)sharedStore;

- (instancetype)init __attribute__((unavailable("not available")));

- (NSArray *)leaders;
- (id<MandoGameLeader>)lastGamePlayed;
- (void)addGameRecord:(MandoGameRecord *)record;
- (void)prune;

@end
