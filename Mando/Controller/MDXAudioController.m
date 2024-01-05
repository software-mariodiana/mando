//
//  MDXAudioController.m
//  Mando
//
//  Created by Mario Diana on 6/15/21.
//

#import "MDXAudioController.h"
#import <AVFoundation/AVFoundation.h>

@implementation MDXAudioController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)registerForNotificationsWithSession:(AVAudioSession *)session
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionDidReceiveInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:session];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self tearDownAudioSession];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self setUpAudioSession];
}

- (BOOL)setUpAudioSession
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    BOOL success = NO;
    NSError *error = nil;

    AVAudioSession *session = [AVAudioSession sharedInstance];
    success = [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if (!success) {
        NSLog(@"%@ Error setting category: %@",
              NSStringFromSelector(_cmd), [error localizedDescription]);

        // Exit early
        return success;
    }

    success = [session setActive:YES error:&error];
    
    if (!success) {
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        [self registerForNotificationsWithSession:session];
    }

    return success;
}

- (BOOL)tearDownAudioSession
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:session];
    
    NSError *deactivationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive:NO error:&deactivationError];
    
    if (!success) {
        NSLog(@"%@", [deactivationError localizedDescription]);
    }
    
    return success;
}

- (void)audioSessionDidReceiveInterruption:(NSNotification *)notification
{
    AVAudioSessionInterruptionType interruption =
        [[[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey] integerValue];

    if (interruption == AVAudioSessionInterruptionTypeBegan) {
        [self tearDownAudioSession];
    }
    else if (interruption == AVAudioSessionInterruptionTypeEnded) {
        [self setUpAudioSession];
    }
}

//TODO: Respond to application events
//
// 1. moves to background
// 2. moves to foreground (after moving from the background)
// 3. paused
// 4. resumes

@end
