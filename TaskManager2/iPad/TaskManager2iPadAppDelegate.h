//
//  TaskManager2iPadAppDelegate.h
//  TaskManager2
//
//  Created by Peter Chase on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskManager2iPadAppDelegate : NSObject<UIApplicationDelegate>

@property(nonatomic, strong) IBOutlet UIWindow* window;
@property(nonatomic, strong) IBOutlet UISplitViewController* splitViewController;

@end
