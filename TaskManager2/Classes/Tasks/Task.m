//
//  Task.m
//  NewTodos
//
//  Created by Peter Chase on 11-01-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Task.h"

#define DeviceID @"deviceID"

@interface Task ()
+ (NSString*)getUUID;
@end

@implementation Task
@synthesize taskId;
@synthesize parentId;
@synthesize systemId;
@synthesize parentSystemId;
@synthesize title;
@synthesize description;
@synthesize startDate;
@synthesize endDate;
@synthesize priority;
@synthesize status;
@synthesize tags;
@synthesize recurranceType;
@synthesize recurranceValue;

-(id) init {
	self = [super init];
	if (self != nil) {
		self.taskId = 0;
		self.parentId = NO_PARENT;
		self.systemId = [Task getUUID];
		self.startDate = [NSDate date];
		self.endDate = [NSDate date];
		self.recurranceType = NONE;
		self.recurranceValue = -1;
		self.priority = 0;
		self.status = 0;
	}
	return self;
}

-(void) dealloc {
	[title release];
	[description release];
	[systemId release];
	[parentSystemId release];
	[startDate release];
	[endDate release];
	[tags release];

	[super dealloc];
}

-(id) copyWithZone:(NSZone *)zone {
	Task* copy = [[[self class] allocWithZone: zone] init];
	
	copy.taskId = self.taskId;
	copy.parentId = self.parentId;
	copy.systemId = self.systemId;
	copy.parentSystemId = self.parentSystemId;
	copy.title = self.title;
	copy.description = self.description;
	copy.startDate = self.startDate;
	copy.endDate = self.endDate;
	copy.priority = self.priority;
	copy.status = self.status;
	copy.tags = self.tags;
	copy.recurranceType = self.recurranceType;
	copy.recurranceValue = self.recurranceValue;
	
	return copy;
}


+ (NSString*)getUUID {
    NSString* uuidStr = [[NSUserDefaults standardUserDefaults] valueForKey:DeviceID];
    if (uuidStr == nil) {
        // Create a unique meeting identifier
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        uuidStr = (NSString*)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        [[NSUserDefaults standardUserDefaults] setValue:uuidStr forKey:DeviceID];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [uuidStr autorelease];
    }
    return uuidStr;
}


@end
