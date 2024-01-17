//
//  ConfettiLayer.m
//  Confetti Layer
//
//  Created by Mario Diana on 1/16/24.
//

#import "MDXSimpleConfettiLayer.h"
#import <UIKit/UIKit.h>

NSString* const MDXConfettiLayerDidShowNotification = @"MDXConfettiLayerDidShowNotification";
NSString* const MDXConfettiLayerDidHideNotification = @"MDXConfettiLayerDidHideNotification";

const CGFloat yOffset = -100.0;

@interface MDXSimpleConfettiLayer () <CAAnimationDelegate>
@property (nonatomic, weak) CAEmitterLayer* confetti;
@property (nonatomic, strong) CABasicAnimation* showAnimation;
@property (nonatomic, strong) CABasicAnimation* hideAnimation;
@property (nonatomic, copy) void (^completionBlock)(void);
@end

@implementation MDXSimpleConfettiLayer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.backgroundColor = UIColor.blackColor.CGColor;
        self.opacity = 0.0;
        
        CAEmitterLayer* confetti = [CAEmitterLayer layer];
        confetti.emitterCells = [self cells];
        [self addSublayer:confetti];
        _confetti = confetti;
        
        // Remove the default or we get a flash at the end of the animation.
        self.actions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"opacity", nil];
        
        CABasicAnimation* showAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        showAnimation.delegate = self;
        showAnimation.fromValue = @(0.0);
        showAnimation.toValue = @(1.0);
        showAnimation.duration = 2.0;
        showAnimation.timingFunction = 
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _showAnimation = showAnimation;
        
        CABasicAnimation* hideAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        hideAnimation.delegate = self;
        hideAnimation.fromValue = @(1.0);
        hideAnimation.toValue = @(0.0);
        hideAnimation.duration = 0.25;
        hideAnimation.timingFunction = 
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _hideAnimation = hideAnimation;
    }
    
    return self;
}

- (void)show
{
    [self addAnimation:[self showAnimation] forKey:@"showOpacityAnimationKey"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MDXConfettiLayerDidShowNotification object:self];
}

- (void)show:(void (^)(void))showBlock
{
    self.completionBlock = showBlock;
    [self show];
}

- (void)hide
{
    [self addAnimation:[self hideAnimation] forKey:@"hideOpacityAnimationKey"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MDXConfettiLayerDidHideNotification object:self];
}

- (void)hide:(void (^)(void))hideBlock
{
    self.completionBlock = hideBlock;
    [self hide];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [[self confetti] setEmitterPosition:[self calculatePositionFromFrame:frame]];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    self.opacity = (self.opacity == 1.0) ? 0.0 : 1.0;
    
    if ([self completionBlock]) {
        self.completionBlock();
    }
    
    self.completionBlock = nil;
}

- (CGPoint)calculatePositionFromFrame:(CGRect)frame
{
    CGFloat x = frame.origin.x + (frame.size.width / 2.0);
    return CGPointMake(x, yOffset);
}

- (NSArray *)cells
{
    NSArray* colors = [self colors];
    NSMutableArray* cells = [NSMutableArray arrayWithCapacity:[colors count]];
    
    id image = [self whiteSquareImage];
    
    for (UIColor* aColor in colors) {
        CAEmitterCell* cell = [CAEmitterCell emitterCell];
        cell.scale = 0.0175;
        cell.emissionRange = M_PI * 2;
        cell.lifetime = 20;
        cell.birthRate = 50;
        cell.velocity = 150;
        cell.color = aColor.CGColor;
        cell.contents = image;
        [cells addObject:cell];
    }
    
    return [NSArray arrayWithArray:cells];
}

- (NSArray *)colors
{
    return @[
        UIColor.systemRedColor,
        UIColor.systemBlueColor,
        UIColor.systemOrangeColor,
        UIColor.systemPinkColor,
        UIColor.systemGreenColor,
        UIColor.systemYellowColor,
        UIColor.systemPurpleColor
    ];
}

- (id)whiteSquareImage
{
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(100.0, 100.0)];
    
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        [[UIColor colorWithWhite:1.0 alpha:1.0] setFill];
        [context fillRect:CGRectMake(0, 0, 100, 100)];
      }];
    
    return (__bridge id)image.CGImage;
}

@end
