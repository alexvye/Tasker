//
//  CommonUI.h
//  TaskManager2
//
//  Created by Peter Chase on 11-03-19.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@interface CommonUI : NSObject {
    
}

+ (void)addToolbarToViewController:(UIViewController*)vc withTitle:(NSString*)title;
+ (void)addToolbarToViewControllerWithSpacer:(UIViewController*)vc withTitle:(NSString*)title;

+(UILocalNotification*)getNotificationForTask:(Task*)task;
+(void)scheduleNotification:(NSDate*)date forTask:(Task*)task;
+(void)cancelNotificationForTask:(Task*)task;
+(void)renewAllTimers;
+(NSTimer*)timerFromNotification:(UILocalNotification*)notification;

@end
