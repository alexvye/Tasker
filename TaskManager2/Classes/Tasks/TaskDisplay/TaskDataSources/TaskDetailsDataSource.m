//
//  TaskDetailsDataSource.m
//  TaskManager2
//
//  Created by Peter Chase on 12-03-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskDetailsDataSource.h"
#import "CommonUI.h"
#import "TaskDAO.h"

@interface TaskDetailsDataSource ()
- (UILabel*)getUILabel:(NSString*)text frame:(CGRect)frame andFont:(UIFont*)font;
- (NSArray*)getDetailLabels;
- (UILabel*)getRepeatLabel;
@end

@implementation TaskDetailsDataSource
@synthesize task = _task;
@synthesize detailLabels = _detailLabels;
@synthesize repeatLabel = _repeatLabel;

- (void)dealloc {
    [_task release];
    [_detailLabels release];
    [_repeatLabel release];
    [super dealloc];
}

#pragma mark - Private methods
- (UILabel*)getUILabel:(NSString*)text frame:(CGRect)frame andFont:(UIFont*)font {
    UILabel* label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    
    label.autoresizingMask =  (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    label.font = font;
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    [label sizeToFit];
    
    return label;
}

- (NSArray*)getDetailLabels {
	CGRect frame = CGRectMake(20.0f, 10.0f, 280.0f, 20.0f);
    NSMutableArray* labels = [[[NSMutableArray alloc] init] autorelease];
	if (self.task.title != nil && self.task.title.length > 0) {
        UILabel* titleLabel = [self getUILabel:self.task.title frame:frame andFont:[UIFont boldSystemFontOfSize:17]];
        [labels addObject:titleLabel];
		frame.origin.y += titleLabel.bounds.size.height;
	}
	
	if (self.task.description != nil && self.task.description.length > 0) {
        UILabel* titleLabel = [self getUILabel:self.task.description frame:frame andFont:[UIFont italicSystemFontOfSize:15]];
        [labels addObject:titleLabel];
		frame.origin.y += titleLabel.bounds.size.height;
	}
    
    // Set up the date formatter.
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:NSDateFormatterLongStyle];
    
    NSString* startDateStr = [NSString stringWithFormat:@"From %@", [formatter stringFromDate:self.task.startDate]];
    UILabel* startDateLabel = [self getUILabel:startDateStr frame:frame andFont:[UIFont systemFontOfSize:12]];
    startDateLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
    [labels addObject:startDateLabel];
	frame.origin.y += startDateLabel.bounds.size.height;

    NSString* endDateStr = [NSString stringWithFormat:@"From %@", [formatter stringFromDate:self.task.endDate]];
    UILabel* endDateLabel = [self getUILabel:endDateStr frame:frame andFont:[UIFont systemFontOfSize:12]];
    endDateLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
    [labels addObject:endDateLabel];
	frame.origin.y += endDateLabel.bounds.size.height;

    return labels;
}

- (UILabel*)getRepeatLabel {
    if (self.task == nil || self.task.recurranceType == NONE) {
        return nil;
    }
    
    NSMutableString* repeatString = [[[NSMutableString alloc] init] autorelease];
    
    if (self.task.recurranceType == DAILY) {
		[repeatString appendString:@"Repeats every:"];
		if ((self.task.recurranceValue & 1) == 1) {
			[repeatString appendString:@"\n    Sunday"];
		}
		if ((self.task.recurranceValue & 2) == 2) {
			[repeatString appendString:@"\n    Monday"];
		}
		if ((self.task.recurranceValue & 4) == 4) {
			[repeatString appendString:@"\n    Tuesday"];
		}
		if ((self.task.recurranceValue & 8) == 8) {
			[repeatString appendString:@"\n    Wednesday"];
		}
		if ((self.task.recurranceValue & 16) == 16) {
			[repeatString appendString:@"\n    Thursday"];
		}
		if ((self.task.recurranceValue & 32) == 32) {
			[repeatString appendString:@"\n    Friday"];
		}
		if ((self.task.recurranceValue & 64) == 64) {
			[repeatString appendString:@"\n    Saturday"];
		}
    } else if (self.task.recurranceType == WEEKLY) {
        [repeatString appendFormat:@"Repeats every %d week(s)", self.task.recurranceValue];
    } else if (self.task.recurranceType == MONTHLY) {
        [repeatString appendFormat:@"Repeats every %d month(s)", self.task.recurranceValue];
    }
    
    CGRect frame = CGRectMake(20, 10, 280, 20);
    UILabel* rptLabel = [self getUILabel:repeatString frame:frame andFont:[UIFont systemFontOfSize:12]];
    rptLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];

    return rptLabel;
}

- (void)initLabels {
    self.detailLabels = [self getDetailLabels];
    self.repeatLabel = [self getRepeatLabel];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        int rows = 1;
        if (self.task != nil && self.task.recurranceType != NONE) {
            rows++;
        }
        if ([CommonUI getNotificationForTask:self.task] != nil) {
            rows++;
        }
        return rows;
    }
    return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    UITableViewCell* cell = nil;
    
    if (indexPath.section == 0) {
        UILocalNotification* notification = [CommonUI getNotificationForTask:self.task];
        if (indexPath.row == 1 && notification != nil) {
            static NSString *cellIdentifier = @"TaskDetailsAlarm";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
            [timeFormatter setDateStyle:NSDateFormatterNoStyle];
            [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
            
            cell.textLabel.text = @"Alert";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ", [timeFormatter stringFromDate:notification.fireDate]];
        } else {
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
            }
            
            if ([indexPath row] == 0) {
                for (UILabel* label in [self getDetailLabels]) {
                    [cell addSubview:label];
                }
            } else {
                [cell addSubview:self.repeatLabel];
            }
        }
    } else if (indexPath.section == 1) {
        static NSString* SectionsTableIdentifier = @"TaskCompleteCell";
        cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SectionsTableIdentifier] autorelease];
            cell.textLabel.text = @"Task Completed";
            
            CGRect frame = CGRectMake(0.0, 0.0, 94.0, 27.0);
            UISwitch* switchCtl = [[[UISwitch alloc] initWithFrame:frame] autorelease];
            [switchCtl addTarget:self action:@selector(taskCompleted:) forControlEvents:UIControlEventValueChanged];
            
            // in case the parent view draws with a custom color or gradient, use a transparent color
            switchCtl.backgroundColor = [UIColor clearColor];
            switchCtl.accessibilityLabel = NSLocalizedString(@"StandardSwitch", @"");
            switchCtl.tag = 1;
            switchCtl.on = self.task.status;
            cell.accessoryView = switchCtl;
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

@end
