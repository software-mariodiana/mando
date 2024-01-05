//
//  MandoToolbar.h
//  Mando
//
//  Created by Mario Diana on 5/3/21.
//

#import <UIKit/UIKit.h>

@interface MandoToolbar : UIToolbar

@property (nonatomic, weak) UIBarButtonItem* settingsButton;
@property (nonatomic, weak) UIBarButtonItem* infoButton;
@property (nonatomic, weak) UIBarButtonItem* stopButton;
@property (nonatomic, weak) UIBarButtonItem* resumeButton;

- (void)updateButtonsStateToPlay;
- (void)updateButtonsStateToPause;
- (void)updateButtonsStateToIdle;

- (BOOL)isIdleState;

@end
