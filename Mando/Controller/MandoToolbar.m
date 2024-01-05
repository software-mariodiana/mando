//
//  MandoToolbar.m
//  Mando
//
//  Created by Mario Diana on 5/3/21.
//

#import "MandoToolbar.h"

@interface MandoToolbar ()
@property (nonatomic, assign, getter=isIdleState) BOOL idleState;
@end

@implementation MandoToolbar

- (void)updateButtonsStateToPlay
{
    self.settingsButton.enabled = NO;
    self.infoButton.enabled = NO;
    self.stopButton.enabled = YES;
    self.resumeButton.enabled = YES;
    self.idleState = NO;
}


- (void)updateButtonsStateToPause
{
    self.settingsButton.enabled = YES;
    self.infoButton.enabled = YES;
    self.stopButton.enabled = YES;
    self.resumeButton.enabled = YES;
    self.idleState = NO;
}


- (void)updateButtonsStateToIdle
{
    self.settingsButton.enabled = YES;
    self.infoButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.resumeButton.enabled = YES;
    self.idleState = YES;
}

@end
