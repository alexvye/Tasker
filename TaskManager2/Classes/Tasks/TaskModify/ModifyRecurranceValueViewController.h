//
//  ModifyRecurranceValueViewController.h
//  TaskManager2
//
//  Created by Peter Chase on 11-03-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface ModifyRecurranceValueViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView* dataTable;
	RecurranceType repeatType;
	int repeatValue;
@private
	NSArray* daysOfTheWeek;
}

@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(assign) RecurranceType repeatType;
@property(assign) int repeatValue;
@property(nonatomic, retain) NSArray* daysOfTheWeek;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end
