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


- (void)setupResumeButtonAnimation
{
    // This should be done from within a -viewDidLoad: to take effect.
    if (@available(iOS 17.0, *)) {
        [[self resumeButton] addSymbolEffect:[NSSymbolPulseEffect effect]
                                     options:[NSSymbolEffectOptions optionsWithRepeating]
                                    animated:YES];
        
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(startAnimatingResumeButton:)
                   name:MandoGameStateDidUpdateToIdleNotification
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(startAnimatingResumeButton:)
                   name:MandoGameStateDidUpdateToPauseNotification
                 object:nil];
        
        [nc addObserver:self
               selector:@selector(stopAnimatingResumeButton:)
                   name:MandoGameStateDidUpdateToPlayNotification
                 object:nil];
    }
}


- (void)startAnimatingResumeButton:(NSNotification *)notification
{
    if (@available(iOS 17.0, *)) {
        NSSymbolEffect* pulse = [NSSymbolPulseEffect effect];
        [[self resumeButton] addSymbolEffect:pulse
                                              options:[NSSymbolEffectOptions options]
                                             animated:YES];
    }
}


- (void)stopAnimatingResumeButton:(NSNotification *)notification
{
    if (@available(iOS 17.0, *)) {
        [[self resumeButton] removeAllSymbolEffects];
    }
}

@end
