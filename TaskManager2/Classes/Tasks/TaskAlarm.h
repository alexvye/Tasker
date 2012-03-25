//
//  TaskAlarm.h
//  TaskManager2
//
//  Created by Peter Chase on 12-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskAlarm : NSObject

@property (nonatomic, assign) int taskId;
@property (nonatomic, strong) NSString* systemId;
@property (nonatomic, strong) NSDate* alarmDate;

+ (void)addTaskAlarm:(TaskAlarm*)newAlarm;
+ (void)removeTaskAlarm:(TaskAlarm*)alarm;
+ (TaskAlarm*)getAlarmForTask:(Task*)task;

@end
