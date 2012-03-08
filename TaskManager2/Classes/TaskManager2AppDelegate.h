//
//  TaskManager2AppDelegate.h
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskManager2AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	IBOutlet UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

-(void)displayAlert:(NSTimer*)timer;

@end

