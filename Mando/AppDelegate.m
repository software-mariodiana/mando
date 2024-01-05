//
//  AppDelegate.m
//  Mando
//
//  Created by Mario Diana on 4/26/21.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[self window] setBackgroundColor:[UIColor lightGrayColor]];
    [[self window] setRootViewController:[[NSClassFromString(@"ViewController") alloc] init]];
    [[self window] makeKeyAndVisible];
    return YES;
}

@end
