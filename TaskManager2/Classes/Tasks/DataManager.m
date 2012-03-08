//
//  DataManager.m
//  TaskManager
//
//  Created by Alex Vye on 11-02-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DataManager.h"
#import "Task.h"
#import "TaskDAO.h"

//static NSMutableArray* Tasks = nil;
static NSMutableArray* Tags = nil;

@implementation DataManager

+(double)getStatusFromStartDate:(NSDate*)startDate EndDate:(NSDate*)endDate {
	NSTimeInterval startInt = [startDate timeIntervalSinceNow];
	NSTimeInterval endInt = [endDate timeIntervalSinceNow];
	if (startInt >= 0.0) {
		return 0.0;
	} else if (endInt <= 0.0) {
		return 1.0;
	} else {
		NSTimeInterval taskTime = [endDate timeIntervalSinceDate:startDate];
		return - startInt / taskTime;
	}
}

//
// single point for saving application data
//
+(void)saveData {
	//
	// TODO put Peter's stuff here
	//
}

//
// single point for loading application data
//
+(void)loadData {
	//
	// TODO put Peter's stuff here
	//
	
	//
	// TEMP hardcode init instead of load
	//
	[TaskDAO databaseSetup];
//	Tasks = [[TaskDAO getAllTasks] mutableCopy];
	Tags = [[TaskDAO getAllTags] mutableCopy];
}

//
//
//
//+(NSMutableArray*)getSelectedTasks {
//	return Tasks;
//}

+(NSMutableArray*)getSelectedTags {
	return Tags;
}

@end
