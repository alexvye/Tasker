//
//  Task.h
//  NewTodos
//
//  Created by Peter Chase on 11-01-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NO_PARENT   -1

typedef enum RecurranceType {
	NONE = 0,
	DAILY,
	WEEKLY,
	MONTHLY
} RecurranceType;

@interface Task : NSObject<NSCopying> {
	int taskId;
	int parentId;
	NSString* systemId;
	NSString* parentSystemId;
	NSString* title;
	NSString* description;
	NSDate* startDate;
	NSDate* endDate;
	int priority;
	int status;
	NSArray* tags;
	RecurranceType recurranceType;
	int recurranceValue;
}

@property(assign) int taskId;
@property(assign) int parentId;
@property(nonatomic, retain) NSString* systemId;
@property(nonatomic, retain) NSString* parentSystemId;
@property(nonatomic, retain) NSString* title;
@property(nonatomic, retain) NSString* description;
@property(nonatomic, retain) NSDate* startDate;
@property(nonatomic, retain) NSDate* endDate;
@property(assign) int priority;
@property(assign) int status;
@property(nonatomic, retain) NSArray* tags;
@property(assign) RecurranceType recurranceType;
@property(assign) int recurranceValue;

@end
