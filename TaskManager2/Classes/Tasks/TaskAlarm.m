//
//  TaskAlarm.m
//  TaskManager2
//
//  Created by Peter Chase on 12-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskAlarm.h"

#define kTaskId     @"taskId"
#define kSystemId   @"systemId"
#define kAlarmDate  @"alarmDate"
#define kAlarmFile  @"alarmFile"

@interface TaskAlarm ()
+ (NSArray*)loadAlarms;
+ (void)saveAlarms:(NSArray*)alarms;
+ (NSString*)archivePathForFile:(NSString*)file;
@end


@implementation TaskAlarm
@synthesize taskId = _taskId;
@synthesize systemId = _systemId;
@synthesize alarmDate = _alarmDate;


#pragma mark - Persistance Methods
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self != nil) {
        self.taskId = [decoder decodeIntForKey:kTaskId];
        self.systemId = [decoder decodeObjectForKey:kSystemId];
        self.alarmDate = [decoder decodeObjectForKey:kAlarmDate];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.taskId forKey:kTaskId];
    [encoder encodeObject:self.systemId forKey:kSystemId];
    [encoder encodeObject:self.alarmDate forKey:kAlarmDate];
}

+ (NSArray*)loadAlarms {
    NSArray* alarms = nil;
    NSString* alarmPath = [TaskAlarm archivePathForFile:kAlarmFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:alarmPath]) {
        alarms = [NSKeyedUnarchiver unarchiveObjectWithFile:alarmPath];
    }
    return alarms;
}

+ (void)saveAlarms:(NSArray*)alarms {
    [NSKeyedArchiver archiveRootObject:alarms toFile:[TaskAlarm archivePathForFile:kAlarmFile]];
}

+ (NSString*)archivePathForFile:(NSString*)file {
	NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:file];
}

+ (void)addTaskAlarm:(TaskAlarm*)newAlarm {
    if (newAlarm == nil) {
        return;
    }
    
    BOOL found = FALSE;
    NSMutableArray* alarms = [[[TaskAlarm loadAlarms] mutableCopy] autorelease];
    if (alarms == nil) {
        alarms = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    }
    
    // Update alarm if it exits.
    for (TaskAlarm* alarm in alarms) {
        if (alarm.taskId == newAlarm.taskId && [alarm.systemId isEqualToString:newAlarm.systemId]) {
            found = TRUE;
            alarm.alarmDate = newAlarm.alarmDate;
        }
    }
    
    // Add alarm to list
    if (!found) {
        [alarms addObject:newAlarm];
    }
    
    [TaskAlarm saveAlarms:alarms];
}

+ (void)removeTaskAlarm:(TaskAlarm*)alarm {
    if (alarm == nil) {
        return;
    }
    
    NSMutableArray* alarms = [[[TaskAlarm loadAlarms] mutableCopy] autorelease];
    if (alarms == nil || alarms.count == 0) {
        return;
    }

    // Update alarm if it exits.
    BOOL found = FALSE;
    for (int i = 0; i < alarms.count; i++) {
        TaskAlarm* tmpAlarm = [alarms objectAtIndex:i];
        if (alarm.taskId == tmpAlarm.taskId && [alarm.systemId isEqualToString:tmpAlarm.systemId]) {
            [alarms removeObjectAtIndex:i];
            found = TRUE;
            break;
        }
    }
    
    if (found) {
        [TaskAlarm saveAlarms:alarms];
    }
}

+ (TaskAlarm*)getAlarmForTask:(Task*)task {
    if (task == nil) {
        return nil;
    }

    NSMutableArray* alarms = [[[TaskAlarm loadAlarms] mutableCopy] autorelease];
    if (alarms == nil || alarms.count == 0) {
        return nil;
    }
    
    for (TaskAlarm* alarm in alarms) {
        if (alarm.taskId == task.taskId && [alarm.systemId isEqualToString:task.systemId]) {
            return alarm;
        }
    }
    
    return nil;
}

@end
