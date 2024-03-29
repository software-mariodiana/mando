//
//  ViewController.m
//  Mando
//
//  Created by Mario Diana on 4/26/21.
//

#import "ViewController.h"

#import "MDXSimpleConfettiLayer.h"
#import "MandoButtonsViewController.h"
#import "MandoPauseScrimView.h"
#import "MDXGlowButton+MidiNote.h"
#import "MDXSynth.h"
#import "MandoToolbar.h"
#import "MandoGameEngine.h"
#import "MandoInfoViewViewController.h"
#import "MandoLeaderboardStore.h"
#import "MandoSettingsStore.h"
#import "MandoSettingsTableViewController.h"
#import "MandoNotifications.h"
#import "MandoGameRecord.h"
#import "MandoCallObserver.h"

const NSInteger kConfettiThreshold = 10;

@interface ViewController () <MandoButtonsViewDelegate, MandoGameEngineDelegate, MandoCallObserverDelegate>
@property (nonatomic, weak) MDXSimpleConfettiLayer* confetti;
@property (nonatomic, weak) UIView* buttonsContainerView;
@property (nonatomic, strong) MandoButtonsViewController* buttonsViewController;
@property (nonatomic, strong) NSDictionary* userSettings;
@property (nonatomic, weak) UIView* scrim;
@property (nonatomic, strong) MDXSynth* synth;
@property (nonatomic, weak) MandoToolbar* toolbar;
@property (nonatomic, strong) MandoGameEngine* gameEngine;
@property (nonatomic, assign, getter=isResponseRoundActive) BOOL responseRoundActive;
@property (nonatomic, strong) MandoCallObserver* callObserver;
@property (nonatomic, strong) UIAlertController* interruptionAlert;
@end

@implementation ViewController

#pragma mark - View lifecycle

- (void)loadView
{
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    UIView *view = [[UIView alloc] initWithFrame:[mainWindow bounds]];
    [view setBackgroundColor:[UIColor systemBackgroundColor]];
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // We want to do this early on, so the database is loaded.
    [MandoLeaderboardStore sharedStore];
    
    MandoToolbar* toolbar = [self createToolbar];
    toolbar.translatesAutoresizingMaskIntoConstraints = NO;
    [[self view] addSubview:toolbar];
    
    UILayoutGuide* margins = [[self view] safeAreaLayoutGuide];
    
    [[toolbar bottomAnchor] constraintEqualToAnchor:[margins bottomAnchor]].active = YES;
    [[toolbar widthAnchor] constraintEqualToAnchor:[[self view] widthAnchor]].active = YES;
    self.toolbar = toolbar;
    
    [[self toolbar] updateButtonsStateToIdle];
    
    UIView* buttonsContainerView = [[UIView alloc] init];
    buttonsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [[self view] addSubview:buttonsContainerView];
    
    [[buttonsContainerView topAnchor] constraintEqualToAnchor:[margins topAnchor]].active = YES;
    [[buttonsContainerView leadingAnchor] constraintEqualToAnchor:[[self view] leadingAnchor]].active = YES;
    [[buttonsContainerView trailingAnchor] constraintEqualToAnchor:[[self view] trailingAnchor]].active = YES;
    [[buttonsContainerView bottomAnchor] constraintEqualToAnchor:[[self toolbar] topAnchor]].active = YES;
    
    self.buttonsContainerView = buttonsContainerView;
    
    [self setupButtonsViewController];
    
    MDXSimpleConfettiLayer* confetti = [[MDXSimpleConfettiLayer alloc] init];
    confetti.frame = [[[self view] layer] bounds];
    [[[self view] layer] addSublayer:confetti];
    self.confetti = confetti;
    
    [[self view] setNeedsUpdateConstraints];
    
    self.synth = [[MDXSynth alloc] init];
    self.gameEngine =
        [[MandoGameEngine alloc] initWithMidiTones:[[self buttonsViewController] buttons]
                                          delegate:self];
    
    self.callObserver = [[MandoCallObserver alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self toolbar] setupResumeButtonAnimation];
}


- (BOOL)prefersStatusBarHidden
{
    return [self isIpad];
}


#pragma mark - UI setup

- (void)setupButtonsViewController
{
    self.buttonsViewController = [[MandoButtonsViewController alloc] init];
    [self addChildViewController:[self buttonsViewController]];
    
    UIView* childView = [[self buttonsViewController] view];
    childView.translatesAutoresizingMaskIntoConstraints = NO;
    [[self buttonsContainerView] addSubview:childView];
    
    [[childView topAnchor] constraintEqualToAnchor:[[self buttonsContainerView] topAnchor]].active = YES;
    [[childView bottomAnchor] constraintEqualToAnchor:[[self buttonsContainerView] bottomAnchor]].active = YES;
    [[childView leadingAnchor] constraintEqualToAnchor:[[self buttonsContainerView] leadingAnchor]].active = YES;
    [[childView trailingAnchor] constraintEqualToAnchor:[[self buttonsContainerView] trailingAnchor]].active = YES;
    
    [[self buttonsContainerView] setNeedsUpdateConstraints];
    
    [[self buttonsViewController] didMoveToParentViewController:self];
    
    [[self buttonsViewController] setDelegate:self];
}


- (MandoToolbar *)createToolbar
{
    // If you init without a frame, a bug causes constraint conflicts at runtime.
    MandoToolbar* toolbar =
        [[MandoToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    
    UIBarButtonItem* settingsButton =
        [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"gearshape"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(openSettings:)];
    
    UIBarButtonItem* infoButton =
        [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"info.circle"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(showInfo:)];
    
    UIBarButtonItem* spacer =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
    
    UIBarButtonItem* stopButton =
        [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"stop"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(stop:)];
    
    UIBarButtonItem* resumeButton = resumeButton =
        [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"playpause"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(startNewGame:)];
    
    [toolbar setItems:@[settingsButton, infoButton, spacer, stopButton, resumeButton]];
    
    toolbar.settingsButton = settingsButton;
    toolbar.infoButton = infoButton;
    toolbar.stopButton = stopButton;
    toolbar.resumeButton = resumeButton;
    
    return toolbar;
}


- (void)showPauseScrim
{
    if ([self scrim]) {
        return;
    }
    
    UIBlurEffect* blur =
        [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
    
    UIVisualEffectView* scrim = [[UIVisualEffectView alloc] initWithEffect:blur];
    scrim.translatesAutoresizingMaskIntoConstraints = NO;
    [[self buttonsContainerView] addSubview:scrim];
    
    [[scrim topAnchor] constraintEqualToAnchor:[[self buttonsContainerView] topAnchor]].active = YES;
    [[scrim bottomAnchor] constraintEqualToAnchor:[[self buttonsContainerView] bottomAnchor]].active = YES;
    [[scrim leadingAnchor] constraintEqualToAnchor:[[self buttonsContainerView] leadingAnchor]].active = YES;
    [[scrim trailingAnchor] constraintEqualToAnchor:[[self buttonsContainerView] trailingAnchor]].active = YES;
    
    self.scrim = scrim;
    
    UIImageView* imageView =
        [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"pause.circle"]];
    
    imageView.tintColor = [UIColor whiteColor];
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [[scrim contentView] addSubview:imageView];
    
    CGFloat width = fmin(self.view.frame.size.width, self.view.frame.size.height) * 0.75;
    [[imageView widthAnchor] constraintEqualToConstant:width].active = YES;
    [[imageView heightAnchor] constraintEqualToConstant:width].active = YES;
    [[imageView centerXAnchor] constraintEqualToAnchor:[scrim centerXAnchor]].active = YES;
    [[imageView centerYAnchor] constraintEqualToAnchor:[scrim centerYAnchor]].active = YES;
    
    [[self view] setNeedsUpdateConstraints];
}


- (void)hidePauseScrim
{
    [[self scrim] removeFromSuperview];
    [[self view] setNeedsUpdateConstraints];
}


- (BOOL)isShowingGameOverAlert
{
    UIViewController* viewController = [self presentedViewController];
    return [viewController isKindOfClass:NSClassFromString(@"UIAlertController")];
}


- (void)applicationWillResignActive:(NSNotification *)notification
{
    // No reason to pause if we're idle or showing the Game Over alert.
    if (![[self toolbar] isIdleState] && ![self isShowingGameOverAlert]) {
        [self pause:self];
    }
}


#pragma mark - Game play

- (void)updateResumeButtonWithSelector:(SEL)selector
{
    self.toolbar.resumeButton.action = selector;
}


- (IBAction)startNewGame:(id)sender
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     %@", sender);
    self.interruptionAlert = nil;
    self.callObserver.delegate = self;
    [[self gameEngine] startNewGame];
    [self updateResumeButtonWithSelector:@selector(pause:)];
    [[self toolbar] updateButtonsStateToPlay];
}


- (IBAction)openSettings:(id)sender
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     %@", sender);
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MandoSettingsStoryboard" bundle:nil];
    UIViewController* settings =
        [storyboard instantiateViewControllerWithIdentifier:@"MandoSettingsID"];
    
    [self presentViewController:settings animated:YES completion:nil];
}


- (IBAction)showInfo:(id)sender
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     %@", sender);
    MandoInfoViewViewController* info = [[MandoInfoViewViewController alloc] init];
    [info setSynth:[self synth]];
    
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:info];
    [self presentViewController:nc animated:YES completion:nil];
}


- (IBAction)stop:(id)sender
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     %@", sender);
    [[self gameEngine] pause];
    
    UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:@"End game"
                                            message:@"Do you wish to end the game?"
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction* action) {
        
        [self resume:nil];
    }];
    
    UIAlertAction* terminate = [UIAlertAction actionWithTitle:@"End game"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction* action) {
        [self hidePauseScrim];
        [[self gameEngine] terminate];
    }];
    
    [alert addAction:cancel];
    [alert addAction:terminate];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)pause:(id)sender
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     %@", sender);
    [self updateResumeButtonWithSelector:@selector(resume:)];
    [[self toolbar] updateButtonsStateToPause];
    [self showPauseScrim];
    [[self gameEngine] pause];
}


- (IBAction)resume:(id)sender
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     %@", sender);
    [self updateUIToContinuePlay];
    
    if (![self interruptionAlert]) {
        // This is the simple scenario.
        [[self gameEngine] resume];
    }
    else {
        [self presentViewController:[self interruptionAlert] animated:YES completion:nil];
    }
}


- (IBAction)play:(id)sender
{
    int note = [sender midiNote];
    [[self synth] playNote:note];
    
    if ([self isResponseRoundActive]) {
        [[self gameEngine] evaluateTone:sender];
    }
}


- (void)updateUIToContinuePlay
{
    [self updateResumeButtonWithSelector:@selector(pause:)];
    [[self toolbar] updateButtonsStateToPlay];
    [self hidePauseScrim];
}


#pragma mark - Game engine delegate methods

- (void)gameEngine:(MandoGameEngine *)engine didChooseTone:(id)tone
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     tone: %@", tone);
    [tone flash];
    [self play:tone];
}


- (void)gameEngine:(MandoGameEngine *)engine didEvaluateTone:(id)tone
{
    int note = [tone midiNote];
    [[self synth] playNote:note];
}


- (void)gameEngine:(MandoGameEngine *)engine willBeginCallForRoundNumber:(NSInteger)round
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     round: %ld", round);
    [[self buttonsViewController] setButtonsInteractionEnabled:NO];
}


- (void)gameEngine:(MandoGameEngine *)engine didCompleteCallForRoundNumber:(NSInteger)round;
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     round: %ld", round);
    [[self buttonsViewController] setButtonsInteractionEnabled:YES];
    self.responseRoundActive = YES;
}


- (void)gameEngine:(MandoGameEngine *)engine
didCompleteResponseForRound:(id<MandoRound>)round
        withResult:(BOOL)success
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSLog(@"##     round: %ld", [round roundNumber]);
    NSLog(@"##   success: %@", (success) ? @"YES" : @"NO");
    
    // Some players (like my nephew) tap along for the sake of muscle memory, and if they 
    // jump the gun and the button responds, it can get confusing.
    [[self buttonsViewController] setButtonsInteractionEnabled:NO];
    
    self.responseRoundActive = NO;
    
    if (success) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:1.0];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self gameEngine] playRound];
            });
        });
    }
    else {
        self.callObserver.delegate = nil;
        
        MandoGameRecord* record = [[MandoGameRecord alloc] initWithGameRound:round];
        NSString* score = [NSString stringWithFormat:@"%ld", [record roundNumber]];
        
        NSString* message = [NSString stringWithFormat:@"You completed %@ rounds", score];
        
        UIAlertController* alert =
            [UIAlertController alertControllerWithTitle:@"Game Over"
                                                message:message
                                         preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okay = [UIAlertAction actionWithTitle:@"Okay"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction* action) {
            [[self toolbar] updateButtonsStateToIdle];
            [self updateResumeButtonWithSelector:@selector(startNewGame:)];
            
            if ([record roundNumber] > kConfettiThreshold) {
                [[self confetti] hide];
            }
        }];
        
        [alert addAction:okay];
        
        if ([record roundNumber] > kConfettiThreshold) {
            [[self confetti] show:^{
                [self presentViewController:alert animated:YES completion:^{
                    [[MandoLeaderboardStore sharedStore] addGameRecord:record];
                }];
            }];
        }
        else {
            [self presentViewController:alert animated:YES completion:^{
                [[MandoLeaderboardStore sharedStore] addGameRecord:record];
            }];
        }
    }
}


#pragma  mark - Handle incoming phone calls

- (void)callObserverReceivedIncomingCall:(MandoCallObserver *)callObserver
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    // If a call comes in when the game is already paused, don't bother.
    if (![self scrim]) {
        [self suspendGame];
    }
}


- (void)suspendGame
{
    NSString* message =
        @"You may restart the game at the beginning of the round.";
    
    UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:@"Continue playing?"
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    __weak id weakself = self;
    UIAlertAction* resume = [UIAlertAction actionWithTitle:@"End game"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction* action) {
        [weakself hidePauseScrim];
        [[weakself gameEngine] terminate];
    }];
    
    UIAlertAction* restart = [UIAlertAction actionWithTitle:@"Restart"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction* action) {
        [weakself restartRound];
    }];
    
    [alert addAction:resume];
    [alert addAction:restart];
    
    self.interruptionAlert = alert;
    
    [self pause:self];
}


- (void)restartRound
{
    self.interruptionAlert = nil;
    self.responseRoundActive = NO;
    [self updateUIToContinuePlay];
    [[self gameEngine] resetRound];
}


#pragma mark - Utility methods

- (BOOL)isIpad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

@end
