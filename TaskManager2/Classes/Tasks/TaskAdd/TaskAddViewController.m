//
//  TaskAddViewController.m
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskAddViewController.h"
#import "TaskDetailViewController.h"
#import "ModifyDatesViewController.h"
#import "ModifyAlarmViewController.h"
#import "ModifyTitleViewController.h"
#import "ModifyRecurranceViewController.h"
#import "ModifyTasksTagsViewController.h"
#import "MasterViewController.h"
#import "TitleDescriptionCell.h"
#import "StartEndDateCell.h"
#import "DataManager.h"
#import "CommonUI.h"
#import "TaskDAO.h"
#import "Task.h"

@interface TaskAddViewController ()

- (void)updateChildTasks:(Task*)updateTask;

@end

@implementation TaskAddViewController
@synthesize popover = _popover;
@synthesize dataTable;
@synthesize newTask;
@synthesize task;
@synthesize parentId;
@synthesize parentSystemId;
@synthesize alarmDate;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.newTask = NO;
        self.alarmDate = nil;
    }
    return self;
}

- (void)dealloc {
    [_popover release];
	[dataTable release];
	[task release];
    [parentSystemId release];
    [alarmDate release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	if (self.newTask) {
        // Create new task object.
		self.task = [[[Task alloc] init] autorelease];
        if (self.parentId != NO_PARENT) {
            Task* parentTask = [TaskDAO getTask:self.parentId :self.parentSystemId];
            self.task.startDate = parentTask.startDate;
            self.task.endDate = parentTask.endDate;
            self.task.tags = [TaskDAO getTagsForTask:self.parentId :self.parentSystemId];
        }
        self.task.parentId = self.parentId;
        self.task.parentSystemId = self.parentSystemId;
        [CommonUI addToolbarToViewController:self withTitle:@"New Task"];
	} else {
        // Set the parent key
        self.parentId = self.task.parentId;
        self.parentSystemId = self.task.parentSystemId;
        [CommonUI addToolbarToViewController:self withTitle:@"Edit Task"];

        // Load the notification alarm for the task if one exists.
        UILocalNotification* notification = [CommonUI getNotificationForTask:self.task];
        if (notification != nil) {
            self.alarmDate = notification.fireDate;
        }
	}
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[DataManager loadData];
	[self.dataTable reloadData];
	[super viewWillAppear:animated];
}

- (IBAction)cancelPressed:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)donePressed:(id)sender {
	if (task.title == nil || task.title.length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Title" 
														message:@"Must enter a title in order to save the task." 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];	
	} else {
		if (self.newTask) {
			[TaskDAO addTask:self.task];
		} else {
			[TaskDAO updateTask:self.task];
            [self updateChildTasks:self.task];
		}
        
        if (self.alarmDate != nil) {
            NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
            
            NSDateComponents* alarmComp = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit) fromDate:self.alarmDate];
            NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:task.endDate];            
            [comp setHour:[alarmComp hour]];
            [comp setMinute:[alarmComp minute]];
            [comp setSecond:[alarmComp second]];
            self.alarmDate = [gregorian dateFromComponents:comp];

            [CommonUI scheduleNotification:self.alarmDate forTask:self.task];
        } else {
            [CommonUI cancelNotificationForTask:self.task];
        }
        [CommonUI renewAllTimers];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            MasterViewController* mvc = (MasterViewController*)self.popover.delegate;
            [mvc.dataTable reloadData];
            [self.popover dismissPopoverAnimated:YES];
        } else {
            [self dismissModalViewControllerAnimated:YES];
        }
	}
}

- (void)updateChildTasks:(Task*)updateTask {
    NSArray* childTasks = [TaskDAO getAllChildTasks:updateTask.taskId :updateTask.systemId];
    for (Task* childTask in childTasks) {
        childTask.startDate = updateTask.startDate;
        childTask.endDate = updateTask.endDate;
        [TaskDAO updateTask:childTask];
        [self updateChildTasks:childTask];
    }
}

- (void)updateTitle {
	ModifyTitleViewController *modifyTitleView = [[[ModifyTitleViewController alloc] 
												   initWithNibName:@"ModifyTitleViewController" 
												   bundle:nil 
												   title:task.title 
												   description:task.description] autorelease];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController pushViewController:modifyTitleView animated:YES];
    } else {
        [self presentModalViewController:modifyTitleView animated:YES];
    }
}

- (void)updateDate {
	ModifyDatesViewController *modifyDatesView = [[[ModifyDatesViewController alloc] 
										  initWithNibName:@"ModifyDatesViewController" 
												   bundle:nil] autorelease];

	modifyDatesView.startDate = task.startDate;
	modifyDatesView.endDate = task.endDate;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController pushViewController:modifyDatesView animated:YES];
    } else {
        [self presentModalViewController:modifyDatesView animated:YES];
    }
}

- (void)updateAlarm {
	ModifyAlarmViewController *modifyAlarmView = [[[ModifyAlarmViewController alloc] 
                                                   initWithNibName:@"ModifyAlarmViewController" 
												   bundle:nil] autorelease];
    modifyAlarmView.alarmDate = self.alarmDate;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController pushViewController:modifyAlarmView animated:YES];
    } else {
        [self presentModalViewController:modifyAlarmView animated:YES];
    }
}

- (void)updateRepeat {
	ModifyRecurranceViewController* modifyRepeatView = [[[ModifyRecurranceViewController alloc]
														 initWithNibName:@"ModifyRecurranceViewController" 
														 bundle:nil] autorelease];
    
	modifyRepeatView.repeatType = task.recurranceType;
	modifyRepeatView.repeatValue = task.recurranceValue;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController pushViewController:modifyRepeatView animated:YES];
    } else {
        [self presentModalViewController:modifyRepeatView animated:YES];
    }
}

- (void)updateTags {
	ModifyTasksTagsViewController* modifyTagsView = [[[ModifyTasksTagsViewController alloc]
														 initWithNibName:@"ModifyTasksTagsViewController" 
														 bundle:nil] autorelease];
    
	modifyTagsView.tasksTags = task.tags;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController pushViewController:modifyTagsView animated:YES];
    } else {
        [self presentModalViewController:modifyTagsView animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    if (self.task.parentId == NO_PARENT) {
        return 5;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0 || [indexPath section] == 1) {
		return 60.0f;
	} else {
		return 44.0f;
	}
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	if ([indexPath section] == 0) {
		static NSString *titleDescriptionCell = @"TitleDescriptionCell";
		TitleDescriptionCell* cell = (TitleDescriptionCell*)
			[tableView dequeueReusableCellWithIdentifier:titleDescriptionCell];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TitleDescriptionCell" owner:self options:nil];
			cell = (TitleDescriptionCell*)[nib objectAtIndex:0];
		}
		
		[cell setTitle:self.task.title];
		[cell setDescription:self.task.description];

		return cell;
	} else if (self.parentId == NO_PARENT && [indexPath section] == 1) {
		static NSString *startEndDateCell = @"StartEndDateCell";
		StartEndDateCell* cell = (StartEndDateCell*)
			[tableView dequeueReusableCellWithIdentifier:startEndDateCell];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StartEndDateCell" owner:self options:nil];
			cell = [nib objectAtIndex:0];
		}
		
		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
		[formatter setDateStyle:NSDateFormatterLongStyle];
		cell.startDateLabel.text = [formatter stringFromDate:self.task.startDate];
		cell.endDateLabel.text = [formatter stringFromDate:self.task.endDate];
		
		return cell;
	} else  {		
		static NSString *addTaskCell = @"AddTaskCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addTaskCell];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:addTaskCell] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
        if (indexPath.section == 2) {
            cell.textLabel.text = @"Alert";
            if (self.alarmDate == nil) {
                cell.detailTextLabel.text = @"Not set";
            } else {
                NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
                [format setTimeStyle:NSDateFormatterShortStyle];
                cell.detailTextLabel.text = [format stringFromDate:self.alarmDate];
            }
		} else if (indexPath.section == 3) {
			NSArray* list = [[[NSArray alloc] initWithObjects:@"None",@"Daily",@"Weekly",@"Monthly",nil] autorelease];
			cell.textLabel.text = @"Repeat";
			cell.detailTextLabel.text = [list objectAtIndex:task.recurranceType];
		} else if ((self.parentId != NO_PARENT && indexPath.section == 1) || indexPath.section == 4) {
			int size = (task.tags == nil) ? 0 : task.tags.count;
			cell.textLabel.text = @"Tags";
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%i Tag(s)", size];
		}
		
		return cell;
	}
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	if (indexPath.section == 0) {
		[self updateTitle];
	} else if (self.parentId == NO_PARENT && indexPath.section == 1) {
		[self updateDate];
    } else if (indexPath.section == 2) {
        [self updateAlarm];
	} else if (indexPath.section == 3) {
		[self updateRepeat];
	} else if ((self.parentId != NO_PARENT && indexPath.section == 1) || indexPath.section == 4) {
		[self updateTags];
	}
	return indexPath;
}

@end
