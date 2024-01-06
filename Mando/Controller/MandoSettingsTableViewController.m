//
//  MandoSettingsTableViewController.m
//  Mando
//
//  Created by Mario Diana on 5/16/21.
//

#import "MandoSettingsTableViewController.h"
#import "MandoSettingsStore.h"

NSString* const MandoVersionNumberKey = @"CFBundleShortVersionString";
NSString* const MandoBuildNumberKey = @"CFBundleVersion";

NSString* const MandoUserSettingsDidChangeNotification = @"MandoUserSettingsDidChangeNotification";

// Lower values on the slider correspond to slower play rates.
float playRates[] = { 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4 };

@interface MandoSettingsTableViewController ()
@property (nonatomic, weak) IBOutlet UISlider* playRateSlider;
@property (nonatomic, weak) IBOutlet UISegmentedControl* notesPerRoundControl;
@property (nonatomic, weak) UILabel* toolbarLabel;
@end

@implementation MandoSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    [self setupToolbar];
    NSTimeInterval playRate = [[MandoSettingsStore sharedStore] playRate];
    float position = [self calculateSliderPositionFromValue:playRate];
    self.playRateSlider.value = position;
    [self updatePlayRate:[self playRateSlider]];
    
    NSInteger notesPerRound = [[MandoSettingsStore sharedStore] notesPerRound];
    NSInteger index = notesPerRound - 1;
    self.notesPerRoundControl.selectedSegmentIndex = index;
    [self updateNotesPerRound:[self notesPerRoundControl]];
}


- (void)setupToolbar
{
    UILabel* label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    
    label.backgroundColor = [UIColor clearColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIToolbar* toolbar = [[self navigationController] toolbar];
    [toolbar addSubview:label];
    
    [[label topAnchor] constraintEqualToAnchor:[toolbar topAnchor]].active = YES;
    [[label leadingAnchor] constraintEqualToAnchor:[toolbar leadingAnchor]].active = YES;
    [[label trailingAnchor] constraintEqualToAnchor:[toolbar trailingAnchor]].active = YES;
    [[label bottomAnchor] constraintEqualToAnchor:[toolbar bottomAnchor]].active = YES;
    
    [toolbar setNeedsUpdateConstraints];
    
    self.toolbarLabel = label;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* version =
            [[NSBundle mainBundle] objectForInfoDictionaryKey:MandoVersionNumberKey];
        
        NSString* build = [[NSBundle mainBundle] objectForInfoDictionaryKey:MandoBuildNumberKey];
        
        NSString* text = [NSString stringWithFormat:@"Version %@ (Build %@)", version, build];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.toolbarLabel.text = text;
        });
    });
}


- (IBAction)dismiss:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)updatePlayRate:(id)sender
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    UISlider* slider = sender;
    float value = [slider value];
    value = lroundf(value);
    slider.value = value;
    float playRate = playRates[(int)value];
    
    [[MandoSettingsStore sharedStore] setPlayRate:playRate];
}


- (IBAction)updateNotesPerRound:(id)sender
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    NSInteger index = [sender selectedSegmentIndex];
    NSInteger notes = index + 1;
    
    [[MandoSettingsStore sharedStore] setNotesPerRound:notes];
}


- (float)calculateSliderPositionFromValue:(float)value
{
    NSLog(@"## %@ - %@", NSStringFromSelector(_cmd), self);
    float* cursor = playRates;
    int index = 0;
    
    for (;;) {
        if (*cursor == value) {
            break;
        }
        
        index++;
        cursor++;
    }
    
    return (float)index;
}

@end
