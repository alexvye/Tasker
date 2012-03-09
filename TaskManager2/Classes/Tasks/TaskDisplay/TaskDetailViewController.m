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
- (void)initLabels;
- (void)updateChildTasks:(Task*)updateTask;
- (NSDate*)mergeDateWithTime:(NSDate*)time andDate:(NSDate*)date;

@end


@implementation TaskDetailViewController
@synthesize task;
@synthesize dataTable;
@synthesize labels;
@synthesize repeatLabel;

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

        // Initialize the labels.
        self.labels = nil;
        self.repeatLabel = nil;
        height = 0.0f;
        repeatHeight = 0.0f;
    }
    return self;
}

- (void)dealloc {
	[dataTable release];
	[task release];
	[labels release];
	[repeatLabel release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initLabels];
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
  
- (void)initLabels {
	// Remove the labels if already initialized
    if (labels != nil) {
        self.labels = nil;
        self.repeatLabel = nil;
		self.task = [TaskDAO getTask:self.task.taskId :self.task.systemId];
        [self.dataTable reloadData];
	}
    
    self.labels = [[[NSMutableArray alloc] init] autorelease];
	CGRect frame = CGRectMake(20.0f, 10.0f, 280.0f, 20.0f);
	if (self.task.title != nil && self.task.title.length > 0) {
		UILabel* taskLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
        taskLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		taskLabel.font = [UIFont boldSystemFontOfSize:17];
		taskLabel.text = self.task.title;
        taskLabel.backgroundColor = [UIColor clearColor];
		taskLabel.numberOfLines = 0;
		[taskLabel sizeToFit];
		[labels addObject:taskLabel];
		frame.origin.y += taskLabel.bounds.size.height;
	}
	
	if (self.task.description != nil && self.task.description.length > 0) {
		UILabel* taskLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
        taskLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		taskLabel.font = [UIFont italicSystemFontOfSize:15];
		taskLabel.text = self.task.description;
        taskLabel.backgroundColor = [UIColor clearColor];
		taskLabel.numberOfLines = 0;
		[taskLabel sizeToFit];
		[labels addObject:taskLabel];
		frame.origin.y += taskLabel.bounds.size.height;
	}
    
    // Set up the date formatter.
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:NSDateFormatterLongStyle];
	
	UILabel* startDateLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
    startDateLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
	startDateLabel.font = [UIFont systemFontOfSize:12];
	startDateLabel.text = [NSString stringWithFormat:@"From %@", [formatter stringFromDate:self.task.startDate]];
	startDateLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
    startDateLabel.backgroundColor = [UIColor clearColor];
	[startDateLabel sizeToFit];
	[labels addObject:startDateLabel];
	frame.origin.y += startDateLabel.bounds.size.height;
	
	UILabel* endDateLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
    endDateLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
	endDateLabel.font = [UIFont systemFontOfSize:12];
	endDateLabel.text = [NSString stringWithFormat:@"To %@", [formatter stringFromDate:self.task.endDate]];
	endDateLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
    endDateLabel.backgroundColor = [UIColor clearColor];
	[endDateLabel sizeToFit];
	[labels addObject:endDateLabel];
	frame.origin.y += endDateLabel.bounds.size.height;
	
	height = frame.origin.y + 10;
	
	if (self.task.recurranceType == NONE) {
		repeatLabel = nil;
	} else if (self.task.recurranceType == DAILY) {
		NSMutableString* text = [[[NSMutableString alloc] initWithCapacity:50] autorelease];
		[text appendString:@"Repeats every:"];
		if ((self.task.recurranceValue & 1) == 1) {
			[text appendString:@"\n    Sunday"];
		}
		if ((self.task.recurranceValue & 2) == 2) {
			[text appendString:@"\n    Monday"];
		}
		if ((self.task.recurranceValue & 4) == 4) {
			[text appendString:@"\n    Tuesday"];
		}
		if ((self.task.recurranceValue & 8) == 8) {
			[text appendString:@"\n    Wednesday"];
		}
		if ((self.task.recurranceValue & 16) == 16) {
			[text appendString:@"\n    Thursday"];
		}
		if ((self.task.recurranceValue & 32) == 32) {
			[text appendString:@"\n    Friday"];
		}
		if ((self.task.recurranceValue & 64) == 64) {
			[text appendString:@"\n    Saturday"];
		}
		CGRect frame = CGRectMake(20, 10, 280, 20);
		repeatLabel = [[UILabel alloc] initWithFrame:frame];
        repeatLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		repeatLabel.font = [UIFont systemFontOfSize:12];
		repeatLabel.text = text;
		repeatLabel.numberOfLines = 0;
		repeatLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
        repeatLabel.backgroundColor = [UIColor clearColor];
		[repeatLabel sizeToFit];
		repeatHeight = repeatLabel.bounds.size.height + 20;
	} else if (self.task.recurranceType == WEEKLY) {
		CGRect frame = CGRectMake(20, 10, 280, 20);
		repeatLabel = [[UILabel alloc] initWithFrame:frame];
        repeatLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		repeatLabel.font = [UIFont systemFontOfSize:12];
		repeatLabel.text = [NSString stringWithFormat:@"Repeats every %d week", self.task.recurranceValue];
		repeatLabel.numberOfLines = 0;
		repeatLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
        repeatLabel.backgroundColor = [UIColor clearColor];
		[repeatLabel sizeToFit];
		repeatHeight = repeatLabel.bounds.size.height + 20;
	} else if (self.task.recurranceType == MONTHLY) {
		CGRect frame = CGRectMake(20, 10, 280, 20);
		repeatLabel = [[UILabel alloc] initWithFrame:frame];
        repeatLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
		repeatLabel.font = [UIFont systemFontOfSize:12];
		repeatLabel.text = [NSString stringWithFormat:@"Repeats every %d month", self.task.recurranceValue];
		repeatLabel.numberOfLines = 0;
		repeatLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
        repeatLabel.backgroundColor = [UIColor clearColor];
		[repeatLabel sizeToFit];
		repeatHeight = repeatLabel.bounds.size.height + 20;
	}

	[self.dataTable reloadData];
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
	taskAddView.task = self.task;
	[self presentModalViewController:taskAddView animated:YES];
}

- (IBAction)taskCompleted:(id)sender {
    UILocalNotification* notification = [CommonUI getNotificationForTask:task];
    
    if ([sender class] == [UISwitch class]) {
        UISwitch* completeSwitch = (UISwitch*) sender;
        if (task.parentId != NO_PARENT || task.recurranceType == NONE) {
            task.status = completeSwitch.on;
            [TaskDAO updateTaskStatus:task.taskId :self.task.systemId :self.task.status];
            if (completeSwitch.on && notification != nil) {
                [CommonUI cancelNotificationForTask:task];
            }
        } else if (task.recurranceType == DAILY) {
            if (completeSwitch.on) {
                completeSwitch.on = NO;
                int daysToAdd = [self getNextDayInterval:task.recurranceValue forDate:self.task.endDate];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                [comps setDay:daysToAdd];
                self.task.startDate = [gregorian dateByAddingComponents:comps toDate:self.task.endDate  options:0];
                self.task.endDate = self.task.startDate;
                [TaskDAO updateTask:self.task];
                [self initLabels];
                [self.dataTable reloadData];
                [comps release]; 
                [gregorian release];
                
                if (notification != nil) {
                    notification.fireDate = [self mergeDateWithTime:notification.fireDate andDate:self.task.endDate];
                }
            }
        } else if (task.recurranceType == WEEKLY) {
            if (completeSwitch.on) {
                completeSwitch.on = NO;
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                [comps setDay:1];
                self.task.startDate = [gregorian dateByAddingComponents:comps toDate:self.task.endDate  options:0];
                [comps setDay:self.task.recurranceValue * 7];
                self.task.endDate = [gregorian dateByAddingComponents:comps toDate:self.task.endDate  options:0];
                [TaskDAO updateTask:self.task];
                [self initLabels];
                [self.dataTable reloadData];
                [comps release]; 
                [gregorian release];
                
                if (notification != nil) {
                    notification.fireDate = [self mergeDateWithTime:notification.fireDate andDate:self.task.endDate];
                }
            }
        } else if (task.recurranceType == MONTHLY) {
            if (completeSwitch.on) {
                completeSwitch.on = NO;
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *comps = [[NSDateComponents alloc] init];
                [comps setDay:1];
                self.task.startDate = [gregorian dateByAddingComponents:comps toDate:self.task.endDate  options:0];
                [comps setDay:0];
                [comps setMonth:self.task.recurranceValue];
                self.task.endDate = [gregorian dateByAddingComponents:comps toDate:self.task.endDate  options:0];
                [TaskDAO updateTask:self.task];
                [self initLabels];
                [self.dataTable reloadData];
                [comps release]; 
                [gregorian release];
                
                if (notification != nil) {
                    notification.fireDate = [self mergeDateWithTime:notification.fireDate andDate:self.task.endDate];
                }
            }
        }
        [self updateChildTasks:self.task];
    }

}

#pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        int rows = 1;
        if (repeatLabel != nil) {
            rows++;
        }
        if ([CommonUI getNotificationForTask:task] != nil) {
            rows++;
        }
        return rows;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			return height;
        } else if (indexPath.row == 1 && [CommonUI getNotificationForTask:task] != nil) {
            return 60.0;
		} else {
			return repeatHeight;
		}
	} else {
		return 60.0;
	}
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = nil;

    if (indexPath.section == 0) {
        UILocalNotification* notification = [CommonUI getNotificationForTask:task];
        if (indexPath.row == 1 && notification != nil) {
            static NSString *cellIdentifier = @"TaskDetailsAlarm";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }

            NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
            [timeFormatter setDateStyle:NSDateFormatterNoStyle];
            [timeFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
            cell.textLabel.text = @"Alert";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ",
                                         [timeFormatter stringFromDate:notification.fireDate]];
        } else {
//            static NSString *SectionsTableIdentifier = @"TaskDetailsCell";
//            cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            }

            if ([indexPath row] == 0) {
                for (UILabel* label in labels) {
                    [cell addSubview:label];
                }
            } else {
                [cell addSubview:repeatLabel];
            }
        }
    } else if (indexPath.section == 1) {
        static NSString* SectionsTableIdentifier = @"TaskCompleteCell";
        cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SectionsTableIdentifier] autorelease];
            cell.textLabel.text = @"Task Completed";

            CGRect frame = CGRectMake(198.0, 17.0, 94.0, 27.0);
            UISwitch* switchCtl = [[[UISwitch alloc] initWithFrame:frame] autorelease];
            [switchCtl addTarget:self action:@selector(taskCompleted:) forControlEvents:UIControlEventValueChanged];

            // in case the parent view draws with a custom color or gradient, use a transparent color
            switchCtl.backgroundColor = [UIColor clearColor];

            [switchCtl setAccessibilityLabel:NSLocalizedString(@"StandardSwitch", @"")];

            switchCtl.tag = 1;	// tag this view for later so we can remove it from recycled table cells
            switchCtl.on = self.task.status;
            [cell.contentView addSubview:switchCtl];
        }
    } else {
        static NSString* reuseIdentifier = @"TaskDetailsChildTaskCell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
        }

        NSString* label = [NSString stringWithFormat:@"%d child task(s)", 
                           [[TaskDAO getAllChildTasks:self.task.taskId :self.task.systemId] count]];
        cell.textLabel.text = label;
    }

    return cell;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 2) {
        return indexPath;
    }
    return nil;
}    

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        //
        // push the view controller
        //
        TaskTableViewController *childTaskView = [[TaskTableViewController alloc] 
                                              initWithNibName:@"TaskTableViewController" bundle:nil];
        childTaskView.parentId = self.task.taskId;
        childTaskView.parentSystemId = self.task.systemId;
        
        // 
        // Pass the selected object to the new view controller.
        //
        [self.navigationController pushViewController:childTaskView animated:YES];
        [childTaskView release];
    }
}


@end
