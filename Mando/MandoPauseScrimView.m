//
//  MandoPauseScrimView.m
//  Mando
//
//  Created by Mario Diana on 5/6/21.
//

#import "MandoPauseScrimView.h"

@implementation MandoPauseScrimView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    }
    
    return self;
}

@end
