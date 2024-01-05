//
//  MandoButtonsViewController.m
//  MandoButtonPrototype
//
//  Created by Mario Diana on 5/31/21.
//

#import "MandoButtonsViewController.h"

#import "MandoConstants.h"
#import "MDXGlowButton.h"

@interface MandoButtonsViewController ()
@property (nonatomic, weak) UIView* overlayView;
@property (nonatomic, strong) NSArray* buttons;
@end

@implementation MandoButtonsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.buttons = [self createButtons];
    [self setupConstraintsForButtons:[self buttons]];
    
    [self setupOverlayView];
    self.overlayView.userInteractionEnabled = NO;
}


- (void)play:(id)sender
{
    [[self delegate] play:sender];
}


- (void)setButtonsInteractionEnabled:(BOOL)enabled
{
    self.overlayView.userInteractionEnabled = !enabled;
}


- (NSArray *)createButtons
{
    MDXGlowButton* green = [[MDXGlowButton alloc] init];
    green.backgroundColor = MandoGreen();
    [green addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    green.tag = MandoGreenNote;
    
    MDXGlowButton* red = [[MDXGlowButton alloc] init];
    red.backgroundColor = MandoRed();
    [red addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    red.tag = MandoRedNote;
    
    MDXGlowButton* orange = [[MDXGlowButton alloc] init];
    orange.backgroundColor = MandoOrange();
    [orange addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    orange.tag = MandoOrangeNote;
    
    MDXGlowButton* blue = [[MDXGlowButton alloc] init];
    blue.backgroundColor = MandoBlue();
    [blue addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    blue.tag = MandoBlueNote;
    
    return @[green, red, orange, blue];
}


- (void)setupConstraintsForButtons:(NSArray *)buttons
{
    UIStackView* topRow =
        [[UIStackView alloc] initWithArrangedSubviews:@[buttons[0], buttons[1]]];
    topRow.axis = UILayoutConstraintAxisHorizontal;
    topRow.distribution = UIStackViewDistributionFillEqually;
    
    UIStackView* bottomRow =
        [[UIStackView alloc] initWithArrangedSubviews:@[buttons[2], buttons[3]]];
    bottomRow.axis = UILayoutConstraintAxisHorizontal;
    bottomRow.distribution = UIStackViewDistributionFillEqually;
    
    UIStackView* vertical =
        [[UIStackView alloc] initWithArrangedSubviews:@[topRow, bottomRow]];
    vertical.axis = UILayoutConstraintAxisVertical;
    vertical.distribution = UIStackViewDistributionFillEqually;
    
    vertical.translatesAutoresizingMaskIntoConstraints = NO;
    [[self view] addSubview:vertical];
    
    [[vertical topAnchor] constraintEqualToAnchor:[[self view] topAnchor]].active = YES;
    [[vertical bottomAnchor] constraintEqualToAnchor:[[self view] bottomAnchor]].active = YES;
    [[vertical leadingAnchor] constraintEqualToAnchor:[[self view] leadingAnchor]].active = YES;
    [[vertical trailingAnchor] constraintEqualToAnchor:[[self view] trailingAnchor]].active = YES;
    
    [[self view] setNeedsUpdateConstraints];
}


- (void)setupOverlayView
{
    // We will prevent user interaction as appropriate.
    UIView* overlayView = [[UIView alloc] init];
    overlayView.backgroundColor = [UIColor clearColor];
    overlayView.translatesAutoresizingMaskIntoConstraints = NO;
    [[self view] addSubview:overlayView];
    
    // Place right on top of the buttons.
    [[overlayView topAnchor] constraintEqualToAnchor:[[self view] topAnchor]].active = YES;
    [[overlayView bottomAnchor] constraintEqualToAnchor:[[self view] bottomAnchor]].active = YES;
    [[overlayView leadingAnchor] constraintEqualToAnchor:[[self view] leadingAnchor]].active = YES;
    [[overlayView trailingAnchor] constraintEqualToAnchor:[[self view] trailingAnchor]].active = YES;
    
    self.overlayView = overlayView;
    
    [[self view] setNeedsUpdateConstraints];
}

@end
