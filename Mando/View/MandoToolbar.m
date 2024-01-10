//
//  MandoToolbar.m
//  Mando
//
//  Created by Mario Diana on 5/3/21.
//

#import "MandoToolbar.h"

NSString* const MandoGameStateDidUpdateToIdleNotification = @"MandoGameStateDidUpdateToIdle";
NSString* const MandoGameStateDidUpdateToPlayNotification = @"MandoGameStateDidUpdateToPlay";
NSString* const MandoGameStateDidUpdateToPauseNotification = @"MandoGameStateDidUpdateToPause";

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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MandoGameStateDidUpdateToPlayNotification
                                                        object:self];
}


- (void)updateButtonsStateToPause
{
    self.settingsButton.enabled = YES;
    self.infoButton.enabled = YES;
    self.stopButton.enabled = YES;
    self.resumeButton.enabled = YES;
    self.idleState = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MandoGameStateDidUpdateToPauseNotification
                                                        object:self];
}


- (void)updateButtonsStateToIdle
{
    self.settingsButton.enabled = YES;
    self.infoButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.resumeButton.enabled = YES;
    self.idleState = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MandoGameStateDidUpdateToIdleNotification
                                                        object:self];
}

@end
