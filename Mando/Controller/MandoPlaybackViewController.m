//
//  MandoPlaybackViewController.m
//  Mando
//
//  Created by Mario Diana on 6/6/21.
//

#import "MandoPlaybackViewController.h"

#import "MDXGlowButton+MidiNote.h"
#import "MandoConstants.h"
#import "MandoSettingsStore.h"

@interface MandoPlaybackViewController ()
@property (nonatomic, weak) IBOutlet MDXGlowButton *greenButton;
@property (nonatomic, weak) IBOutlet MDXGlowButton *redButton;
@property (nonatomic, weak) IBOutlet MDXGlowButton *orangeButton;
@property (nonatomic, weak) IBOutlet MDXGlowButton *blueButton;
@property (nonatomic, strong) NSDictionary* buttons;
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, assign, getter=isExitState) BOOL exitState;
@end

@implementation MandoPlaybackViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.greenButton.tag = MandoGreenNote;
    self.redButton.tag = MandoRedNote;
    self.orangeButton.tag = MandoOrangeNote;
    self.blueButton.tag = MandoBlueNote;
    
    self.navigationItem.backButtonTitle = @"Leaders";
    
    // The space below the toolbar has no color if not set manually.
    self.navigationController.view.backgroundColor = self.navigationController.toolbar.backgroundColor;
    
    UIBarButtonItem* spacer =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
    
    UIBarButtonItem* resumeButton =
        [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"play.rectangle"]
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(play:)];
    
    [self setToolbarItems:@[spacer, resumeButton]];
    
    self.buttons = [self createButtonsTable];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.exitState = YES;
}

- (NSDictionary *)createButtonsTable
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    return @{
        [NSNumber numberWithInt:[[self greenButton] midiNote]]: [self greenButton],
        [NSNumber numberWithInt:[[self redButton] midiNote]]: [self redButton],
        [NSNumber numberWithInt:[[self orangeButton] midiNote]]: [self orangeButton],
        [NSNumber numberWithInt:[[self blueButton] midiNote]]: [self blueButton]
    };
}

- (void)play:(id)sender
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSTimeInterval rate = [[MandoSettingsStore sharedStore] playRate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (id<MandoMidiPlaying> tone in [[self game] toneSequence]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MDXGlowButton* button = [self buttonForTone:tone];
                [button showHighlightColor];
                [[self synth] playNote:[button midiNote]];
                [button performSelector:@selector(hideHighlightColor) withObject:nil afterDelay:0.2];
            });
            
            [NSThread sleepForTimeInterval:rate];
            
            if ([self isExitState]) {
                // Stop playback if user closes view.
                break;
            }
        }
    });
}

- (MDXGlowButton *)buttonForTone:(id<MandoMidiPlaying>)tone
{
    NSNumber* key = [NSNumber numberWithInt:[tone midiNote]];
    return [[self buttons] objectForKey:key];
}

- (MDXSynth *)synth
{
    NSAssert(_synth, @"Invalid instance: \"synth\" property is nil");
    return _synth;
}

@end
