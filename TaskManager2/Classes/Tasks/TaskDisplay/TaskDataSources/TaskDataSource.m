//
//  TaskDataSource.m
//  TaskManager2
//
//  Created by Peter Chase on 12-03-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "TaskDataSource.h"
#import "Task.h"
#import "TaskDAO.h"

@interface TaskDataSource ()
- (void)setupFilteredTasks;
@end

@implementation TaskDataSource
@synthesize tasks = _tasks;
@synthesize parentId = _parentId;
@synthesize parentSystemId = _parentSystemId;
@synthesize tagFilter = _tagFilter;
@synthesize statusFilter = _statusFilter;
@synthesize startedFilter = _startedFilter;

- (void)dealloc {
    [_tasks release];
    [_parentSystemId release];
    [_tagFilter release];
    [super dealloc];
}

#pragma mark - Private methods
- (void)setupFilteredTasks {
    // Get all tasks for the status filter.
    NSArray* tmpTasks;
    if (self.statusFilter == TASK_STATUS_ALL) {
        tmpTasks = [TaskDAO getAllChildTasks:self.parentId :self.parentSystemId];
    } else {
        tmpTasks = [TaskDAO getAllChildTasks:self.parentId :self.parentSystemId :self.statusFilter];
    }
    
    if (self.tagFilter == nil && !self.startedFilter) {
        // If not tag filter or started filter.
        self.tasks = tmpTasks;
    } else {
        // Iterate tasks and filter using tag and started filters.
        NSMutableArray* postFilteredTasks = [[[NSMutableArray alloc] init] autorelease];
        for (Task *task in tmpTasks) {
            NSTimeInterval timeSinceStart = [task.startDate timeIntervalSinceNow];
            if (!self.startedFilter || timeSinceStart <= 0) {
                if (self.tagFilter == nil || [task.tags containsObject:self.tagFilter]) {
                    [postFilteredTasks addObject:task];
                }
            }            
        }
        self.tasks = postFilteredTasks;
    }
    
}

#pragma mark - UITableViewDataSource methods

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ((self.tagFilter != nil || self.statusFilter != 2) && section == 1) {
        return @"Filter";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.tagFilter != nil || self.statusFilter != 2 || self.startedFilter) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.tasks == nil) {
        [self setupFilteredTasks];
    }

    if (section == 0) {
        int count = [self.tasks count];
        return (count > 0) ? count : 1;
    } else {
        return 1;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tasks == nil) {
        [self setupFilteredTasks];
    }
    
    static NSString* reuseIdentifier = @"TaskDetailsSummary";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
    }
    
    if (indexPath.section == 1) {
        NSMutableString* filterStr = [NSMutableString stringWithCapacity:20];
        if (self.tagFilter != nil) {
            [filterStr appendFormat:@"[Tag = %@]  ", self.tagFilter];
        }
        if (self.statusFilter != 2) {
            if (self.statusFilter == 0) {
                [filterStr appendFormat:@"[Not Completed Tasks]"];
            } else {
                [filterStr appendFormat:@"[Completed Tasks]"];
            }
        }
        if (self.startedFilter) {
            [filterStr appendFormat:@"[Started Tasks]"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.text = @"Tasks filtered by:";
        cell.textLabel.textColor = [UIColor blackColor];
        
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];;
        cell.detailTextLabel.text = filterStr;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        cell.imageView.image = nil;
    } else {
        if ([self.tasks count] == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"0 tasks to display";
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.text = nil;
            cell.imageView.image = nil;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            Task* task = (Task*) [self.tasks objectAtIndex:indexPath.row];
            if (task != nil) {
                // Display the status color.
                NSDateFormatter *dateComparisonFormatter = [[[NSDateFormatter alloc] init] autorelease];
                [dateComparisonFormatter setDateFormat:@"yyyy-MM-dd"];
                if( [[dateComparisonFormatter stringFromDate:task.endDate] isEqualToString:[dateComparisonFormatter stringFromDate:[NSDate date]]]) {
                    UIImage* theImage = [UIImage imageNamed:@"yellow.png"];
                    cell.imageView.image = theImage;
                } else {                              
                    NSTimeInterval timeSinceStart = [task.startDate timeIntervalSinceNow];
                    NSTimeInterval timeSinceEnd = [task.endDate timeIntervalSinceNow];
                    if (task.status == 1 || timeSinceStart > 0) {
                        UIImage* theImage = [UIImage imageNamed:@"black.png"];
                        cell.imageView.image = theImage;
                    } else if (timeSinceEnd < 0) {
                        UIImage* theImage = [UIImage imageNamed:@"red.png"];
                        cell.imageView.image = theImage;
                    } else {
                        UIImage* theImage = [UIImage imageNamed:@"green.png"];
                        cell.imageView.image = theImage;
                    }
                }
                
                // Display the task title
                cell.textLabel.text = task.title;
                cell.textLabel.adjustsFontSizeToFitWidth = YES;
                cell.textLabel.minimumFontSize = 10;
                if (task.status == 1) {
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                } else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    
                }
                
                // Display the task description
                NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
                [formatter setDateStyle:NSDateFormatterLongStyle];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Due date: %@", [formatter stringFromDate:task.endDate]];
                if (task.status == 1) {
                    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                } else {
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
                }
            } else {
                NSLog(@"%d section: %d row: nil pointer", indexPath.section, indexPath.row);
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	Task* task = [self.tasks objectAtIndex:indexPath.row];
	[TaskDAO deleteTask:task.taskId :task.systemId];
	self.tasks = nil;
	[tableView reloadData]; 
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    if (toIndexPath.row >= 0 && toIndexPath.row < self.tasks.count) {
        int from = fromIndexPath.row;
        int to   = toIndexPath.row;
        if (from == to) {
            // Moved to same location, return.
            return;
        }
        
        // Get indexes from the full list based.
        NSMutableArray* fullList = nil;
        if (self.tagFilter == nil && self.statusFilter == 2 && !self.startedFilter) {
            fullList = [[self.tasks mutableCopy] autorelease];
        } else {
            // Get tasks from merged list.
            Task* fromTask = [self.tasks objectAtIndex:from];
            Task* toTask = [self.tasks objectAtIndex:to];
            
            fullList = [[[TaskDAO getAllChildTasks:self.parentId :self.parentSystemId] mutableCopy] autorelease];
            for (int i = 0; i < [fullList count]; i++) {                
                Task* tmpTask = [fullList objectAtIndex:i];
                if ((tmpTask.taskId == fromTask.taskId) && ([tmpTask.systemId isEqualToString:fromTask.systemId])) {
                    from = i;
                } else if ((tmpTask.taskId == toTask.taskId) && ([toTask.systemId isEqualToString:toTask.systemId])) {
                    to = i;
                }
            }
        }
        
        // Use commented out code with full list.
        Task *task = [fullList objectAtIndex:from];
        [task retain]; // Getting a bad access error when I insert task if I don't retain here
        
        [fullList removeObjectAtIndex:from];
        [fullList insertObject:task atIndex:to];
        
        [task release];
        
        for (int i = 0; i < [fullList count]; i++) {
            task = [fullList objectAtIndex:i];
            task.priority = i;
            [TaskDAO updateTaskPriority:task.taskId :task.systemId :i];
        }
    }
    
    self.tasks = nil;
    
	[tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.tasks != nil && self.tasks.count > 0) {
        return YES;
    }
    return NO;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.tasks != nil && self.tasks.count > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - Interface methods

-(void)loadState {
    NSString* tagFilter = [[NSUserDefaults standardUserDefaults] objectForKey:@"tagFilter"];
    NSInteger statusCodeFilter = [[NSUserDefaults standardUserDefaults] integerForKey:@"statusFilter"];
    BOOL startFilter = [[NSUserDefaults standardUserDefaults] boolForKey:@"startedFilter"];
    
    self.tagFilter = tagFilter;
    if (statusCodeFilter != 0) {
        self.statusFilter = statusCodeFilter - 1;
    } else {
        self.statusFilter = 2;
    }    
    self.startedFilter = startFilter;
}


@end
