//
//  MDXPausableTimer.h
//  TimerDemo
//
//  Created by Mario Diana on 5/6/21.
//

#import <Foundation/Foundation.h>

@interface MDXPausableTimer : NSObject

- (instancetype)init __attribute__((unavailable("not available")));

/**
 * Return new instance.
 *
 * @param interval  number of seconds until timer fires.
 * @param block     callback upon firing of timer.
 */
- (instancetype)initWithTimeInterval:(NSTimeInterval)interval
                               block:(void (^)(NSTimer *timer))block;

/** Return YES if timer is paused; otherwise, NO. */
- (BOOL)isPaused;

/** Start timer. (Does nothing if timer is already running.) */
- (void)resume;

/** Pause timer. */
- (void)pause;

/** Invalidates the timer. */
- (void)invalidate;

@end
