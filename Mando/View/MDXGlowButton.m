//
//  MDXGlowButton.m
//  GlowButton
//
//  Created by Mario Diana on 4/25/21.
//

#import "MDXGlowButton.h"

@interface MDXGlowButtonLayer : CAGradientLayer
@property (nonatomic, strong) UILabel* label;
@end

@implementation MDXGlowButtonLayer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self setNeedsDisplay];
    }
    
    return self;
}

- (instancetype)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    
    if (self) {
        // override this method and use it to copy the values of instance variables into the new object.
        [self setNeedsDisplay];
    }
    
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    // See: https://stackoverflow.com/a/26924839
    size_t count = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    
    const CGFloat* components = CGColorGetComponents([self backgroundColor]);
    CGFloat colors[8] = {1.0f, 1.0f, 1.0f, 1.0f, components[0], components[1], components[2], 0.5};
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, locations, count);
    CGColorSpaceRelease(rgb);
    
    CGPoint center = CGPointMake(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]));
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height);
    
    CGContextDrawRadialGradient(ctx, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    
    if ([[self label] text]) {
        // We want the label to show while we're highlighting.
        UIGraphicsPushContext(ctx);
        
        NSDictionary* attributes = @{
            NSFontAttributeName: [[self label] font],
            NSForegroundColorAttributeName: [[self label] textColor]
        };
        
        [[[self label] text] drawInRect:[[self label] frame] withAttributes:attributes];
        
        UIGraphicsPopContext();
    }
}

@end


@interface MDXGlowButton ()
@property (nonatomic, strong) CALayer* backgroundColorLayer;
@end

IB_DESIGNABLE
@implementation MDXGlowButton

- (instancetype)init
{
    self = [super init];
    
    if (self) {
    }
    
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
    }
    
    return self;
}


- (void)showHighlightColor
{
    MDXGlowButtonLayer* layer = [[MDXGlowButtonLayer alloc] init];
    layer.frame = self.bounds;
    layer.backgroundColor = [[self backgroundColor] CGColor];
    layer.label = self.titleLabel;
    
    [[self layer] addSublayer:layer];
    self.backgroundColorLayer = layer;
    
    [self setNeedsDisplay];
}


- (void)hideHighlightColor
{
    [[self backgroundColorLayer] removeFromSuperlayer];
    [self setNeedsDisplay];
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch
                     withEvent:(UIEvent *)event
{
    [self showHighlightColor];
    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch
                   withEvent:(UIEvent *)event
{
    [self hideHighlightColor];
}


- (void)drawRect:(CGRect)rect
{
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:rect];
    [path moveToPoint:rect.origin];
    
    [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    [path addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)];
    [path addLineToPoint:rect.origin];
    
    if ([self isRounded]) {
        UIBezierPath* maskPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:8.0];
        CAShapeLayer* mask = [[CAShapeLayer alloc] init];
        mask.path = maskPath.CGPath;
        self.layer.mask = mask;
    }
}

@end
