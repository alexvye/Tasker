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
#import "CommonUI.h"

@interface TaskDetailViewController () 

- (int)getNextDayInterval:(int)mask forDate:(NSDate*)date;
- (void)updateChildTasks:(Task*)updateTask;
- (NSDate*)mergeDateWithTime:(NSDate*)time andDate:(NSDate*)date;

@end


@implementation TaskDetailViewController
@synthesize dataSource = _dataSource;
@synthesize dataTable;

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
	[dataTable release];
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

#pragma mark - Private Methods

- (int)getNextDayInterval:(int)mask forDate:(NSDate*)date {
    // Get day of week: Sunday = 1, Monday = 2, etc
    int weekday = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:date] weekday];
    int firstDay = weekday - 1;
    
    for (int i = 0; i < 7; i++, weekday++) {
        int weekdayMask = 1 << ((weekday < 7) ? weekday : weekday - 7);
        if ((mask & weekdayMask) == weekdayMask) {
            break;
        }
        
    }
    
    return weekday - firstDay;
}

- (void)updateChildTasks:(Task*)updateTask {
    NSArray* childTasks = [TaskDAO getAllChildTasks:updateTask.taskId :updateTask.systemId];
    for (Task* childTask in childTasks) {
        childTask.startDate = updateTask.startDate;
        childTask.endDate = updateTask.endDate;
        childTask.status = updateTask.status;
        [TaskDAO updateTask:childTask];
        [self updateChildTasks:childTask];
    }
}

- (NSDate*)mergeDateWithTime:(NSDate*)time andDate:(NSDate*)date {
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];

    NSDateComponents* timeComp = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit) fromDate:time];
    NSDateComponents *dateComp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:date];            
    [dateComp setHour:[timeComp hour]];
    [dateComp setMinute:[timeComp minute]];
    [dateComp setSecond:[timeComp second]];
    return [gregorian dateFromComponents:dateComp];
}

#pragma mark - UI Event Methods

- (IBAction)editTask:(id)sender {
	TaskAddViewController *taskAddView = [[[TaskAddViewController alloc] 
										  initWithNibName:@"TaskAddViewController" bundle:nil] autorelease];
	taskAddView.task = self.dataSource.task;
	[self presentModalViewController:taskAddView animated:YES];
}

- (IBAction)taskCompleted:(id)sender {
    UILocalNotification* notification = [CommonUI getNotificationForTask:self.dataSource.task];
    
    if ([sender class] == [UISwitch class]) {
        UISwitch* completeSwitch = (UISwitch*) sender;
        if (self.dataSource.task.parentId != NO_PARENT || self.dataSource.task.recurranceType == NONE) {
            self.dataSource.task.status = completeSwitch.on;
            [TaskDAO updateTaskStatus:self.dataSource.task.taskId :self.dataSource.task.systemId :self.dataSource.task.status];
            if (completeSwitch.on && notification != nil) {
                [CommonUI cancelNotificationForTask:self.dataSource.task];
            }
        } else if (self.dataSource.task.recurranceType == DAILY) {
            if (completeSwitch.on) {
                completeSwitch.on = NO;
                int daysToAdd = [self getNextDayInterval:self.dataSource.task.recurranceValue forDate:self.dataSource.task.endDate];
                NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
                NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
                [comps setDay:daysToAdd];
                self.dataSource.task.startDate = [gregorian dateByAddingComponents:comps toDate:self.dataSource.task.endDate  options:0];
                self.dataSource.task.endDate = self.dataSource.task.startDate;
                [TaskDAO updateTask:self.dataSource.task];
                [self.dataTable reloadData];
                
                if (notification != nil) {
                    notification.fireDate = [self mergeDateWithTime:notification.fireDate andDate:self.dataSource.task.endDate];
                }
            }
        } else if (self.dataSource.task.recurranceType == WEEKLY) {
            if (completeSwitch.on) {
                completeSwitch.on = NO;
                NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
                NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
                [comps setDay:1];
                self.dataSource.task.startDate = [gregorian dateByAddingComponents:comps toDate:self.dataSource.task.endDate  options:0];
                [comps setDay:self.dataSource.task.recurranceValue * 7];
                self.dataSource.task.endDate = [gregorian dateByAddingComponents:comps toDate:self.dataSource.task.endDate  options:0];
                [TaskDAO updateTask:self.dataSource.task];
                [self.dataTable reloadData];
                
                if (notification != nil) {
                    notification.fireDate = [self mergeDateWithTime:notification.fireDate andDate:self.dataSource.task.endDate];
                }
            }
        } else if (self.dataSource.task.recurranceType == MONTHLY) {
            if (completeSwitch.on) {
                completeSwitch.on = NO;
                NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
                NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
                [comps setDay:1];
                self.dataSource.task.startDate = [gregorian dateByAddingComponents:comps toDate:self.dataSource.task.endDate  options:0];
                [comps setDay:0];
                [comps setMonth:self.dataSource.task.recurranceValue];
                self.dataSource.task.endDate = [gregorian dateByAddingComponents:comps toDate:self.dataSource.task.endDate  options:0];
                [TaskDAO updateTask:self.dataSource.task];
                [self.dataTable reloadData];
                
                if (notification != nil) {
                    notification.fireDate = [self mergeDateWithTime:notification.fireDate andDate:self.dataSource.task.endDate];
                }
            }
        }
        [self updateChildTasks:self.dataSource.task];
    }

}

#pragma mark - UITableViewDataSource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
            float height = 20.0f;
            for (UILabel* label in self.dataSource.detailLabels) {
                height += label.bounds.size.height;
            }
            return height;
        } else if (indexPath.row == 1 && [CommonUI getNotificationForTask:self.dataSource.task] != nil) {
            return 60.0;
		} else {
            UILabel* label = self.dataSource.repeatLabel;
            return label.bounds.size.height + 20.0f;
		}
	} else {
		return 60.0;
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
