//
//  TaskAddViewController.h
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskAddViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView* dataTable;
	BOOL newTask;
	Task* task;
	int parentId;
	NSString* parentSystemId;
    NSDate* alarmDate;
}

@property(nonatomic, strong) UIPopoverController* popover;
@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(assign) BOOL newTask;
@property(nonatomic, copy) Task* task;
@property(assign) int parentId;
@property(nonatomic, retain) NSString* parentSystemId;
@property(nonatomic, retain) NSDate* alarmDate;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

- (void)updateTitle;
- (void)updateDate;
- (void)updateAlarm;
- (void)updateRepeat;
- (void)updateTags;

@end
