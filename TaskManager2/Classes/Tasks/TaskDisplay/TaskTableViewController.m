//
//  TaskTableViewController.m
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskTableViewController.h"
#import "TaskAddViewController.h"
#import "FilterTasksViewController.h"
#import "TaskDetailViewController.h"
#import "TaskManager2AppDelegate.h"
#import "DataManager.h"
#import "Task.h"
#import "TaskDAO.h"

@interface TaskTableViewController ()

-(void)saveState;
-(void)loadState;
    
@end


@implementation TaskTableViewController
@synthesize dataTable;
@synthesize toolbar;
@synthesize editTableButton;
@synthesize saveTableButton;
@synthesize filterTableButton;
@synthesize flexible;
@synthesize tasks;
@synthesize tags;
@synthesize parentId;
@synthesize parentSystemId;
@synthesize filter;
@synthesize statusFilter;
@synthesize startedFilter;

#pragma mark - UIViewControllerMethods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        self.parentId = NO_PARENT;
		self.parentSystemId = nil;
        self.startedFilter = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {        
        self.parentId = NO_PARENT;
		self.parentSystemId = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadState];

    // Display the the button bar.
	UIBarButtonItem *plusButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTask:)] autorelease];
    self.editTableButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)] autorelease];
    self.saveTableButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)] autorelease];
	self.navigationItem.rightBarButtonItem = plusButton;
    self.navigationItem.title = @"Tasks";

    // Create the edit button.
    self.filterTableButton = [[[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(addStatusFilter:)] autorelease];
    self.flexible = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    NSArray* items = [[[NSArray alloc] initWithObjects:self.editTableButton, self.flexible, self.filterTableButton, nil] autorelease];
    [self.toolbar setItems:items];

    dataTable.rowHeight = 60;
    
}

-(void)saveState {    
    [[NSUserDefaults standardUserDefaults] setObject:self.filter forKey:@"tagFilter"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.statusFilter+1 forKey:@"statusFilter"];
    [[NSUserDefaults standardUserDefaults] setBool:self.startedFilter forKey:@"startedFilter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)loadState {
    NSString* tagFilter = [[NSUserDefaults standardUserDefaults] objectForKey:@"tagFilter"];
    NSInteger statusCodeFilter = [[NSUserDefaults standardUserDefaults] integerForKey:@"statusFilter"];
    BOOL startFilter = [[NSUserDefaults standardUserDefaults] boolForKey:@"startedFilter"];
    
    self.filter = tagFilter;
    if (statusCodeFilter != 0) {
        self.statusFilter = statusCodeFilter - 1;
    } else {
        self.statusFilter = 2;
    }    
    self.startedFilter = startFilter;
}

#pragma mark - Button Pressed Events

- (IBAction)editButtonPressed:(UIButton*)aButton {
    [[self dataTable] setEditing:YES animated:YES];
    NSArray* items = [[[NSArray alloc] initWithObjects:self.saveTableButton, self.flexible, self.filterTableButton, nil] autorelease];
    [self.toolbar setItems:items];
}

- (IBAction)saveButtonPressed:(UIButton*)aButton {
    [[self dataTable] setEditing:NO animated:YES];
    NSArray* items = [[[NSArray alloc] initWithObjects:self.editTableButton, self.flexible, self.filterTableButton, nil] autorelease];
    [self.toolbar setItems:items];
}

- (IBAction)addTask:(UIButton*)aButton {
	//
	// push the view controller
	//
	TaskAddViewController *taskAddView = [[TaskAddViewController alloc] 
                                          initWithNibName:@"TaskAddViewController" bundle:nil];
	taskAddView.newTask = YES;
    taskAddView.parentId = self.parentId;
    taskAddView.parentSystemId = self.parentSystemId;
	
	// 
	// Pass the selected object to the new view controller.
	//
	[self presentModalViewController:taskAddView animated:YES];
	[taskAddView release];
}

- (IBAction) addFilters: (UIButton*) aButton {
	[self popupActionSheet];
}

- (IBAction)addStatusFilter:(UIButton*)aButton {
	//
	// push the view controller
	//
	FilterTasksViewController* filterTask = [[FilterTasksViewController alloc] 
                                             initWithNibName:@"FilterTasksViewController" 
                                             bundle:nil 
                                             tagFilter:self.filter 
                                             statusFilter:self.statusFilter
                                             startFilter:self.startedFilter];
	
	// 
	// Pass the selected object to the new view controller.
	//
	[self presentModalViewController:filterTask animated:YES];
	[filterTask release];
}

- (void) setupFilteredTasks {
    // Get all tasks for the status filter
    NSArray* tmpTasks;
    if (self.statusFilter == TASK_STATUS_ALL) {
        tmpTasks = [TaskDAO getAllChildTasks:self.parentId :self.parentSystemId];
    } else {
        tmpTasks = [TaskDAO getAllChildTasks:self.parentId :self.parentSystemId :self.statusFilter];
    }
    
    if (self.filter == nil && !self.startedFilter) {
        self.tasks = tmpTasks;
    } else {
        NSMutableArray* postFilteredTasks = [[[NSMutableArray alloc] init] autorelease];
        for (Task *task in tmpTasks) {
            NSTimeInterval timeSinceStart = [task.startDate timeIntervalSinceNow];
            if (!self.startedFilter || timeSinceStart <= 0) {
                if (self.filter == nil || [task.tags containsObject:filter]) {
                    [postFilteredTasks addObject:task];
                }
            }            
        }
        self.tasks = postFilteredTasks;
    }
    
    [self saveState];
}

- (void)setupTags {
    if (self.tags == nil) {
        self.tags = [TaskDAO getAllTags];
    }
}

#pragma mark - Action Sheet Methods

//
// Display the action sheet
//
-(void)popupActionSheet {
    UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:@"Please select the tag to filter by"
								 delegate:self
								 cancelButtonTitle:nil
								 destructiveButtonTitle:nil
								 otherButtonTitles:nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	
    //
    // loop and add all the tags to the action sheet
    //
    [self setupTags];
	for(NSString* tag in self.tags) {
		[popupQuery addButtonWithTitle:tag];
	}
	
    //
    // cancel button has to be last item
    //
	[popupQuery addButtonWithTitle:@"All"];
	
    TaskManager2AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    UIView* viewBase = [delegate.tabBarController view];

    [popupQuery showInView:viewBase];  
    [popupQuery release];  
}

//
// This method is called when you click an item on the action item
//
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self setupTags];
    if ([actionSheet.title isEqualToString:@"Please select the tag to filter by"]) {
        if (buttonIndex < [self.tags count]) {
            filter = [self.tags objectAtIndex:buttonIndex]; 
        } else {
            filter = nil;
        }
    } else {
        self.statusFilter = buttonIndex;
    }

    [self setupFilteredTasks];
    [self.dataTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
	
    [self loadState];
	[self setupFilteredTasks];
	[self.dataTable reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (void) deselect {	
	[self.dataTable deselectRowAtIndexPath:[self.dataTable indexPathForSelectedRow] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.filter != nil || self.statusFilter != 2 || self.startedFilter) {
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
        if (self.filter != nil) {
            [filterStr appendFormat:@"[Tag = %@]  ", self.filter];
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


//
// Override to support editing the table view.
//
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	Task* task = [self.tasks objectAtIndex:indexPath.row];
	[TaskDAO deleteTask:task.taskId :task.systemId];
	self.tasks = nil;
	[self.dataTable reloadData]; 
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ((self.filter != nil || self.statusFilter != 2) && section == 1) {
        return @"Filter";
    }
    return nil;
}

//
// Override to support rearranging the table view.
//
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
        if (self.filter == nil && self.statusFilter == 2 && !self.startedFilter) {
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

	[self.dataTable reloadData];
}

//
// Override to support conditional rearranging of the table view.
//
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.tasks != nil && [self.tasks count] > 0) {
        return YES;
    }
    return NO;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.tasks != nil && [self.tasks count] > 0) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [self.tasks count] > 0) {
        return indexPath;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//
	// push the view controller
	//
	TaskDetailViewController *taskDetailView = [[TaskDetailViewController alloc] 
										  initWithNibName:@"TaskDetailViewController" bundle:nil];
	[taskDetailView autorelease];

    if (indexPath.section == 0 && [self.tasks count] > 0) {
        Task* task = (Task*) [self.tasks objectAtIndex:[indexPath row]];
        taskDetailView.task = task;
        
        // 
        // Pass the selected object to the new view controller.
        //
        [self.navigationController pushViewController:taskDetailView animated:YES];
    }
}

#pragma mark - Memory management methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
    self.tasks = nil;
    self.tags = nil;
}


- (void)dealloc {
	[dataTable release];
    [toolbar release];
    [editTableButton release];
    [saveTableButton release];
    [filterTableButton release];
    [flexible release];
    [tasks release];
    [tags release];
    [parentSystemId release];
    [filter release];
    [super dealloc];
}


@end

