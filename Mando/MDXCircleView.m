//
//  MDXCircleView.m
//  Circle
//
//  Created by Mario Diana on 4/29/21.
//  Copyright © 2021 Mario Diana. All rights reserved.
//

#import "MDXCircleView.h"

@interface MDXCircleView ()
@property (nonatomic, strong) UIColor* mdx_backgroundColor;
@end

IB_DESIGNABLE
@implementation MDXCircleView

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.mdx_backgroundColor = backgroundColor;
    [super setBackgroundColor:[UIColor clearColor]];
}

- (CGRect)circleRectFromRect:(CGRect)rect
{
    CGFloat x = CGRectGetMidX(rect);
    CGFloat y = CGRectGetMidY(rect);
    CGPoint center = CGPointMake(x, y);
    CGFloat length = fmin(rect.size.width, rect.size.height);
    x = center.x - (length / 2.0);
    y = center.y - (length / 2.0);
    return CGRectMake(x, y, length, length);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, [self circleRectFromRect:rect]);
    CGContextSetFillColorWithColor(ctx, [[self mdx_backgroundColor] CGColor]);
    CGContextFillPath(ctx);
}


@end
