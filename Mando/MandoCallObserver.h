//
//  MandoCallObserver.h
//  Mando
//
//  Created by Mario Diana on 6/19/21.
//

#import <Foundation/Foundation.h>

@class MandoCallObserver;


@protocol MandoCallObserverDelegate <NSObject>
- (void)callObserverReceivedIncomingCall:(MandoCallObserver *)callObserver;
@end


@interface MandoCallObserver : NSObject
@property (nonatomic, weak) id<MandoCallObserverDelegate> delegate;
@end
