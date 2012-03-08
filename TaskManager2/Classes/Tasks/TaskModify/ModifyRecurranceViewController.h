//
//  ModifyRecurranceViewController.h
//  TaskManager2
//
//  Created by Peter Chase on 11-03-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface ModifyRecurranceViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView* dataTable;
	RecurranceType repeatType;
	int repeatValue;
}

@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(assign) RecurranceType repeatType;
@property(assign) int repeatValue;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end
