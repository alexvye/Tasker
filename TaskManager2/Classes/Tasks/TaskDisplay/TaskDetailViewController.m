//
//  TaskDetailViewController.m
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "TaskTableViewController.h"
#import "TaskAddViewController.h"
#import "DataManager.h"
#import "TaskDAO.h"
#import "TaskAlarm.h"
#import "CommonUI.h"


@implementation TaskDetailViewController
@synthesize dataSource = _dataSource;
@synthesize dataTable = _dataTable;

#pragma mark - UIViewController Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        // Add the button bar.
        UIBarButtonItem *plusButton = [[[UIBarButtonItem alloc] 
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemEdit 
                                       target:self 
                                       action:@selector(editTask:)] autorelease];
        self.navigationItem.title = @"View Task";
        self.navigationItem.rightBarButtonItem = plusButton;
        
        self.dataSource = [[[TaskDetailsDataSource alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc {
    [_dataSource release];
	[_dataTable release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataTable.dataSource = self.dataSource;
    [self.dataSource initLabels];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    static BOOL first = YES;
    if (first) {
        first = NO;
    } else {
        self.dataSource.task = [TaskDAO getTask:self.dataSource.task.taskId :self.dataSource.task.systemId];
        [self.dataSource initLabels];
        [self.dataTable reloadData];
    }
}

#pragma mark - UI Event Methods

- (IBAction)editTask:(id)sender {
	TaskAddViewController *taskAddView = [[[TaskAddViewController alloc] 
										  initWithNibName:@"TaskAddViewController" bundle:nil] autorelease];
	taskAddView.task = self.dataSource.task;
	[self presentModalViewController:taskAddView animated:YES];
}

#pragma mark - UITableViewDataSource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.task == nil) {
        return tableView.rowHeight;
    }
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
            float height = 20.0f;
            for (UILabel* label in self.dataSource.detailLabels) {
                height += label.bounds.size.height;
            }
            return height;
        } else if (indexPath.row == 1 && ([CommonUI getNotificationForTask:self.dataSource.task] != nil || [TaskAlarm getAlarmForTask:self.dataSource.task] != nil)) {
            return tableView.rowHeight;
		} else {
            CGRect frame = self.dataSource.repeatLabel.frame;
            frame.size = tableView.contentSize;
            self.dataSource.repeatLabel.frame = frame;
            [self.dataSource.repeatLabel sizeToFit];
            
            return self.dataSource.repeatLabel.frame.size.height + 20.0f;
		}
	} else {
		return tableView.rowHeight;
	}
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 2) {
        return indexPath;
    }
    return nil;
}    

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        TaskTableViewController *childTaskView = [[[TaskTableViewController alloc] 
                                              initWithNibName:@"TaskTableViewController" bundle:nil] autorelease];
        childTaskView.dataSource.parentId = self.dataSource.task.taskId;
        childTaskView.dataSource.parentSystemId = self.dataSource.task.systemId;
        
        [self.navigationController pushViewController:childTaskView animated:YES];
    }
}


@end
