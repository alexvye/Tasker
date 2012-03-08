//
//  TaskManager2iPadAppDelegate.h
//  TaskManager2
//
//  Created by Peter Chase on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskManager2iPadAppDelegate : NSObject<UIApplicationDelegate> {
    UIWindow* window;
    UISplitViewController* splitViewController;
}

@property(nonatomic, retain) IBOutlet UIWindow* window;
@property(nonatomic, retain) IBOutlet UISplitViewController* splitViewController;

@end
