//
//  MandoSettingsStore.h
//  Mando
//
//  Created by Mario Diana on 5/16/21.
//

#import <Foundation/Foundation.h>

@interface MandoSettingsStore : NSObject

@property (nonatomic, assign) NSTimeInterval playRate;
@property (nonatomic, assign) NSInteger notesPerRound;

+ (MandoSettingsStore *)sharedStore;

- (instancetype)init __attribute__((unavailable("not available")));

@end
