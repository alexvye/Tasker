//
//  TaskManager2iPadAppDelegate.m
//  TaskManager2
//
//  Created by Peter Chase on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskManager2iPadAppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "DataManager.h"


@implementation TaskManager2iPadAppDelegate

@synthesize window = _window;
@synthesize splitViewController = _splitViewController;

- (void)dealloc
{
    [_window release];
    [_splitViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[DataManager loadData];
//    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil] autorelease];
    UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
    
    DetailViewController *detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil] autorelease];
    UINavigationController *detailNavigationController = [[[UINavigationController alloc] initWithRootViewController:detailViewController] autorelease];
    
    masterViewController.detailViewController = detailViewController;
    
    self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
    self.splitViewController.delegate = detailViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, detailNavigationController, nil];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)updateTables {
    bool first = YES;
    NSArray* controllers = [self.splitViewController viewControllers];
    for (UINavigationController* navCtl in controllers) {
        NSArray* viewControllers = [navCtl viewControllers];
        for (UIViewController* vc in viewControllers) {
            if ([vc isKindOfClass:[MasterViewController class]]) {
                MasterViewController* mvc = (MasterViewController*) vc;
                [mvc.dataTable reloadData];
                if (first) {
                    first = NO;
                    [mvc updateDetails];
                }
            }
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
