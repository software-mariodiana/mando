//
//  MandoInfoViewViewController.m
//  Mando
//
//  Created by Mario Diana on 5/10/21.
//

#import "MandoInfoViewViewController.h"

#import "MandoLeaderboardStore.h"
#import "MandoPlaybackViewController.h"
#import "MDXSynth.h"

NSString* const MandoInfoViewTableCellIdentifier = @"MandoInfoViewTableCellIdentifier";

@interface MandoInfoViewViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, weak) MDXSynth* synth;
@end

@implementation MandoInfoViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Leaderboard";
    UIColor* background = UIColor.systemBackgroundColor;
    
    UINavigationController* nc = [self navigationController];
    nc.toolbarHidden = YES;
    nc.navigationBar.backgroundColor = background;
    nc.toolbar.backgroundColor = background;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(dismiss:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIView* subview = nil;
    
    if ([self lastGamePlayed] != nil) {
        UITableView* tableView = [[UITableView alloc] init];
        
        tableView.dataSource = self;
        tableView.delegate = self;
        
        self.tableView = tableView;
        subview = tableView;
    }
    else {
        subview = [[UIView alloc] init];
        subview.backgroundColor = UIColor.whiteColor;
        
        UILabel* label = [[UILabel alloc] init];
        label.text = @"No past games";
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [subview addSubview:label];
        
        [[label centerXAnchor] constraintEqualToAnchor:[subview centerXAnchor]].active = YES;
        [[label centerYAnchor] constraintEqualToAnchor:[subview centerYAnchor]].active = YES;
    }
    
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [[self view] addSubview:subview];
    
    [[subview topAnchor] constraintEqualToAnchor:[[self view] topAnchor]].active = YES;
    [[subview bottomAnchor] constraintEqualToAnchor:[[self view] bottomAnchor]].active = YES;
    [[subview leadingAnchor] constraintEqualToAnchor:[[self view] leadingAnchor]].active = YES;
    [[subview trailingAnchor] constraintEqualToAnchor:[[self view] trailingAnchor]].active = YES;
    
    [[self view] setNeedsUpdateConstraints];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath* indexPath = [[self tableView] indexPathForSelectedRow];
    
    if (indexPath) {
        [[self tableView] deselectRowAtIndexPath:indexPath animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[MandoLeaderboardStore sharedStore] prune];
}

- (void)dismiss:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (id<MandoGameLeader>)lastGamePlayed
{
    return [[MandoLeaderboardStore sharedStore] lastGamePlayed];
}

- (void)setSynth:(MDXSynth *)synth
{
    _synth = synth;
}

- (NSArray *)leaders
{
    return [[MandoLeaderboardStore sharedStore] leaders];
}

#pragma mark - Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([self lastGamePlayed]) ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell =
        [tableView dequeueReusableCellWithIdentifier:MandoInfoViewTableCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:MandoInfoViewTableCellIdentifier];
    }
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    id<MandoGameLeader> leader = nil;
    
    if ([self numberOfSectionsInTableView:tableView] > 1 && [indexPath section] == 0) {
        leader = [self lastGamePlayed];
    }
    else {
        leader = [[self leaders] objectAtIndex:[indexPath row]];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Score: %@", [leader score]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [leader dateString]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if ([self numberOfSectionsInTableView:tableView] > 1 && section == 0) {
        return 1;
    }
    else {
        return [[self leaders] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if ([self numberOfSectionsInTableView:tableView] > 1 && section == 0) {
        return @"Last game played";
    }
    else {
        return @"High scores";
    }
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MandoGameLeader> leader = nil;
    
    if ([self numberOfSectionsInTableView:tableView] > 1 && [indexPath section] == 0) {
        leader = [self lastGamePlayed];
    }
    else {
        leader = [[self leaders] objectAtIndex:[indexPath row]];
    }
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"MandoPlaybackStoryboard" bundle:nil];
    MandoPlaybackViewController* playback =
        [storyboard instantiateViewControllerWithIdentifier:@"MandoPlaybackID"];
    
    playback.game = leader;
    playback.synth = [self synth];
    
    [[self navigationController] setDelegate:playback];
    [[self navigationController] pushViewController:playback animated:YES];
}

@end
