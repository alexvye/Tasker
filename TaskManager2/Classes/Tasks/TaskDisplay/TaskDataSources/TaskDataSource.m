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
@synthesize count = _count;
@synthesize filtered = _filtered;

- (void)dealloc {
    [_tasks release];
    [_parentSystemId release];
    [_tagFilter release];
    [super dealloc];
}

#pragma mark - Private methods
- (void)setupFilteredTasks {
/*
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
*/    
}

#pragma mark - UITableViewDataSource methods
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1 && self.filtered) {
        return @"Filter";
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.count = [TaskDAO getFilteredTaskCountForParentId:self.parentId parentSystemId:self.parentSystemId forTag:self.tagFilter status:self.statusFilter andStarted:self.startedFilter];
    self.filtered = self.tagFilter != nil || self.statusFilter != 2 || self.startedFilter;

    if (self.tagFilter != nil || self.statusFilter != 2 || self.startedFilter) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return (self.count > 0) ? self.count : 1;
    } else {
        return 1;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        if (self.count == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"0 tasks to display";
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.text = nil;
            cell.imageView.image = nil;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            Task* task = [TaskDAO getFilteredTaskFor:indexPath.row parentId:self.parentId parentSystemId:self.parentSystemId forTag:self.tagFilter status:self.statusFilter andStarted:self.startedFilter];

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
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = nil;
                cell.detailTextLabel.text = nil;
                cell.imageView.image = nil;
                NSLog(@"%d section: %d row: nil pointer", indexPath.section, indexPath.row);
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Task* task = [TaskDAO getFilteredTaskFor:indexPath.row parentId:self.parentId parentSystemId:self.parentSystemId forTag:self.tagFilter status:self.statusFilter andStarted:self.startedFilter];
	[TaskDAO deleteTask:task.taskId :task.systemId];
    [TaskDAO renumberTaskPriorities:self.parentId :self.parentSystemId];
	[tableView reloadData]; 
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if (fromIndexPath.row == toIndexPath.row || fromIndexPath.section != 0 || toIndexPath.section != 0) {
        // Moved to the same location.
        [tableView reloadData];
    } else {
        [TaskDAO renumberTaskPriorities:self.parentId :self.parentSystemId];
        Task* fromTask = [TaskDAO getFilteredTaskFor:fromIndexPath.row parentId:self.parentId parentSystemId:self.parentSystemId forTag:self.tagFilter status:self.statusFilter andStarted:self.startedFilter];
        Task* toTask = [TaskDAO getFilteredTaskFor:toIndexPath.row parentId:self.parentId parentSystemId:self.parentSystemId forTag:self.tagFilter status:self.statusFilter andStarted:self.startedFilter];
        
        if (fromIndexPath.row < toIndexPath.row) {
            // Move down the list
            int newPriority = toTask.priority;
            [TaskDAO renumberTaskPrioritiesSubset:self.parentId :self.parentSystemId :(fromTask.priority+1) :(toTask.priority) :-1];
            [TaskDAO updateTaskPriority:fromTask.taskId :fromTask.systemId :newPriority];
        } else {
            // Move up the list
            int newPriority = toTask.priority;
            [TaskDAO renumberTaskPrioritiesSubset:self.parentId :self.parentSystemId :(toTask.priority) :(fromTask.priority-1) :1];
            [TaskDAO updateTaskPriority:fromTask.taskId :fromTask.systemId :newPriority];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.count > 0;
    }
    return NO;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.count > 0;
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

- (void)loadTasks {
    /*
    if (self.tasks == nil) {
        [self setupFilteredTasks];
    }
     */
}

@end
