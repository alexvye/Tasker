//
//  TaskDetailViewController.h
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView* dataTable;
	Task* task;
@private
	float height;
	float repeatHeight;
	NSMutableArray* labels;
	UILabel* repeatLabel;
	
}

@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(nonatomic, retain) Task* task;
@property(nonatomic, retain) NSMutableArray* labels;
@property(nonatomic, retain) UILabel* repeatLabel;

- (IBAction)editTask:(id)sender;
- (IBAction)taskCompleted:(id)sender;

@end
