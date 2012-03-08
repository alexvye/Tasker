//
//  DataManager.h
//  TaskManager
//
//  Created by Alex Vye on 11-02-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// Data manager is intended to be a singleton to get access to data common across the application
//

@interface DataManager : NSObject {
}

+(double)getStatusFromStartDate:(NSDate*)startDate EndDate:(NSDate*)endDate;
+(void)saveData;
+(void)loadData;

@end
