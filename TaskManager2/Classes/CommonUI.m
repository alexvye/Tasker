//
//  CommonUI.m
//  TaskManager2
//
//  Created by Peter Chase on 11-03-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonUI.h"
#import "TaskManager2AppDelegate.h"

static NSMutableArray* timers = nil;

@implementation CommonUI

+ (void)addToolbarToViewController:(UIViewController*)vc withTitle:(NSString*)title {
	//Initialize the toolbar
	UIToolbar* toolbar = [[[UIToolbar alloc] init] autorelease];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	toolbar.barStyle = UIBarStyleDefault;
	
	//Set the toolbar to fit the width of the app.
	[toolbar sizeToFit];

    /*	
	//Caclulate the height of the toolbar
	CGFloat toolbarHeight = [toolbar frame].size.height;
	
	//Get the bounds of the parent view
	CGRect rootViewBounds = vc.parentViewController.view.bounds;
	
	//Get the width of the parent view,
	CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
	
	//Create a rectangle for the toolbar
	CGRect rectArea = CGRectMake(0, 0, rootViewWidth, toolbarHeight);
	
	//Reposition and resize the receiver
	[toolbar setFrame:rectArea];
     */
	
	//Create a button
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				   target:vc 
																				   action:@selector(cancelPressed:)] autorelease];
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				 target:vc 
																				 action:@selector(donePressed:)] autorelease];
	
	UILabel* titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(70.0f , 11.0f, 180.0f, 21.0f)] autorelease];
	[titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setTextColor:[UIColor whiteColor]];
	[titleLabel setText:title];
	[titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	UIBarButtonItem *toolbarTitle = [[[UIBarButtonItem alloc] initWithCustomView:titleLabel] autorelease];
	
	[toolbar setItems:[NSArray arrayWithObjects:cancelButton,toolbarTitle,doneButton,nil]];
	
	//Add the toolbar as a subview to the navigation controller.
	[vc.view addSubview:toolbar];
}

+ (void)addToolbarToViewControllerWithSpacer:(UIViewController*)vc withTitle:(NSString*)title {
	//Initialize the toolbar
	UIToolbar* toolbar = [[[UIToolbar alloc] init] autorelease];
	toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	toolbar.barStyle = UIBarStyleDefault;
	
	//Set the toolbar to fit the width of the app.
	[toolbar sizeToFit];
	
	//Caclulate the height of the toolbar
	CGFloat toolbarHeight = [toolbar frame].size.height;
	
	//Get the bounds of the parent view
	CGRect rootViewBounds = vc.parentViewController.view.bounds;
	
	//Get the width of the parent view,
	CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
	
	//Create a rectangle for the toolbar
	CGRect rectArea = CGRectMake(0, 0, rootViewWidth, toolbarHeight);
	
	//Reposition and resize the receiver
	[toolbar setFrame:rectArea];
	
	//Create a button
	UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				   target:vc 
																				   action:@selector(cancelPressed:)] autorelease];
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				 target:vc 
																				 action:@selector(donePressed:)] autorelease];
	UIBarButtonItem *spacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			 target:nil 
																			 action:nil] autorelease];
	UIBarButtonItem *spacer2 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			  target:nil 
																			  action:nil] autorelease];
	
	UILabel* titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(70.0f , 11.0f, 180.0f, 21.0f)] autorelease];
	[titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setTextColor:[UIColor whiteColor]];
	[titleLabel setText:title];
	[titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	UIBarButtonItem *toolBarTitle = [[[UIBarButtonItem alloc] initWithCustomView:titleLabel] autorelease];
	
	[toolbar setItems:[NSArray arrayWithObjects:cancelButton,spacer,toolBarTitle,spacer2,doneButton,nil]];
	
	//Add the toolbar as a subview to the navigation controller.
	[vc.view addSubview:toolbar];
}

+(UILocalNotification*)getNotificationForTask:(Task*)task {
    NSArray* notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification* notification in notifications) {
        NSDictionary* userInfo = notification.userInfo;
        NSString* systemIdStr = [userInfo valueForKey:@"systemId"];
        NSString* taskIdStr = [userInfo valueForKey:@"taskId"];
        if (systemIdStr != nil && taskIdStr != nil) {
            if ([task.systemId isEqualToString:systemIdStr] &&
                [[NSString stringWithFormat:@"%d", task.taskId] isEqualToString:taskIdStr]) {
                return notification;
            }
        }
    }
    return nil;
}

+(void)scheduleNotification:(NSDate*)date forTask:(Task*)task {
    NSMutableDictionary* userInfo = [[[NSMutableDictionary alloc] init] autorelease];
    [userInfo setValue:[NSString stringWithFormat:@"%d", task.taskId] forKey:@"taskId"];
    [userInfo setValue:task.systemId forKey:@"systemId"];

	UILocalNotification* localNotif = [[[UILocalNotification alloc] init] autorelease];
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = task.title;
    localNotif.hasAction = NO;
    localNotif.userInfo = userInfo;
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

+(void)cancelNotificationForTask:(Task*)task {
    UILocalNotification* notification = [CommonUI getNotificationForTask:task];
    if (notification != nil) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

+(void)renewAllTimers {
    if (timers != nil) {
        for (NSTimer* timer in timers) {
            [timer invalidate];
        }
        [timers removeAllObjects];
    }
    
    NSArray* notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification* notification in notifications) {
        [CommonUI timerFromNotification:notification];
    }
}

+(NSTimer*)timerFromNotification:(UILocalNotification*)notification {
    if (timers == nil) {
        timers = [[NSMutableArray alloc] init];
    }
    
    TaskManager2AppDelegate* delegate = (TaskManager2AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:[notification.fireDate timeIntervalSinceNow] target:delegate selector:@selector(displayAlert:) userInfo:notification.alertBody repeats:YES];
    [timers addObject:timer];
    return timer;
}

@end
