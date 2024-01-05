//
//  MandoCallObserver.m
//  Mando
//
//  Created by Mario Diana on 6/19/21.
//

#import "MandoCallObserver.h"
#import <CallKit/CallKit.h>

@interface MandoCallObserver () <CXCallObserverDelegate>
@property (nonatomic, strong) CXCallObserver* callObserver;
@property (nonatomic, strong) CXCall* currentCall;
@end

@implementation MandoCallObserver

- (void)dealloc
{
    [_callObserver setDelegate:nil queue:nil];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _callObserver = [[CXCallObserver alloc] init];
        [_callObserver setDelegate:self queue:nil];
    }
    
    return self;
}

- (void)callObserver:(nonnull CXCallObserver *)callObserver
         callChanged:(nonnull CXCall *)call
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    
    // All we are alerting the delegate to is that a call has come in which
    // it has not seen before. What it does with that information is up
    // to it.
    if (![[self currentCall] isEqualToCall:call]) {
        if ([[self delegate] respondsToSelector:@selector(callObserverReceivedIncomingCall:)]) {
            // The delegate should suspend the game only if it isn't already suspended.
            [[self delegate] callObserverReceivedIncomingCall:self];
        }
    }
    
    self.currentCall = call;
}

@end
