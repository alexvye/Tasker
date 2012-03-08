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
}

//
// single point for loading application data
//
+(void)loadData {
	[TaskDAO databaseSetup];
}

@end
