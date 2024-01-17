//
//  ConfettiLayer.h
//  Confetti Layer
//
//  Created by Mario Diana on 1/16/24.
//

#import <QuartzCore/QuartzCore.h>

extern NSString* const MDXConfettiLayerDidShowNotification;
extern NSString* const MDXConfettiLayerDidHideNotification;

@interface MDXSimpleConfettiLayer : CALayer

- (void)show;
- (void)show:(void (^)(void))showBlock;

- (void)hide;
- (void)hide:(void (^)(void))hideBlock;

@end
