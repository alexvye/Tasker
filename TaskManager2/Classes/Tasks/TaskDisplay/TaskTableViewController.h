//
//  TaskTableViewController.h
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDataSource.h"

@interface TaskTableViewController : UIViewController<UITableViewDelegate> {
	UITableView* dataTable;
    UIToolbar* toolbar;
    UIBarButtonItem* editTableButton;
    UIBarButtonItem* saveTableButton;
    UIBarButtonItem* filterTableButton;
    UIBarButtonItem *flexible;
}

@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(nonatomic, strong) IBOutlet TaskDataSource* dataSource;
@property(nonatomic, retain) IBOutlet UIToolbar* toolbar;
@property(nonatomic, retain) UIBarButtonItem* editTableButton;
@property(nonatomic, retain) UIBarButtonItem* saveTableButton;
@property(nonatomic, retain) UIBarButtonItem* filterTableButton;
@property(nonatomic, retain) UIBarButtonItem* flexible;

- (IBAction)editButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)addTask:(id)sender;
- (IBAction)addStatusFilter:(id)sender;

@end
