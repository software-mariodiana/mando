//
//  MDXPausableTimer.m
//  TimerDemo
//
//  Created by Mario Diana on 5/6/21.
//

#import "MDXPausableTimer.h"

@interface MDXPausableTimer ()
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, copy) void (^timerBlock)(NSTimer *);
@end

@implementation MDXPausableTimer

- (void)dealloc
{
    _timerBlock = nil;
    [_timer invalidate];
    _timer = nil;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                               block:(void (^)(NSTimer *timer))block
{
    self = [super init];
    
    if (self) {
        _timerBlock = block;
        _timer = [NSTimer timerWithTimeInterval:interval repeats:NO block:^(NSTimer* timer) {
            block(timer);
        }];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    
    return self;
}

- (void)resume
{
    if ([[self timer] isValid]) {
        // Do nothing if we already have a timer running.
        return;
    }
    
    self.timer = [NSTimer timerWithTimeInterval:[self interval] repeats:NO block:[self timerBlock]];
    [[NSRunLoop currentRunLoop] addTimer:[self timer] forMode:NSDefaultRunLoopMode];
    self.paused = NO;
}

- (void)pause
{
    NSDate* date = [[self timer] fireDate];
    [[self timer] invalidate];
    
    self.interval = [date timeIntervalSinceNow];
    self.paused = YES;
}

- (void)invalidate
{
    [[self timer] invalidate];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([[self timer] respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:[self timer]];
    }
    else {
        [super forwardInvocation:anInvocation];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [super methodSignatureForSelector:selector] ?: [[self timer] methodSignatureForSelector:selector];
}

@end
