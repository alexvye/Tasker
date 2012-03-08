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
@synthesize tasks;
@synthesize tags;
@synthesize parentId;
@synthesize parentSystemId;
@synthesize filter;
@synthesize statusFilter;
@synthesize editTableButton;
@synthesize saveTableButton;
@synthesize filterTableButton;

#pragma mark - UIViewControllerMethods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        self.parentId = NO_PARENT;
		self.parentSystemId = nil;
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
	self.navigationItem.rightBarButtonItem = plusButton;
    self.navigationItem.title = @"Tasks";

    // Create the edit button.
    self.editTableButton = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonPressed:)] autorelease];
    self.saveTableButton = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)] autorelease];
    self.filterTableButton = [[[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(addStatusFilter:)] autorelease];
    self.editTableButton.width = self.filterTableButton.width;
    
    NSArray* items = [[[NSArray alloc] initWithObjects:self.editTableButton, self.filterTableButton, nil] autorelease];
    [self.toolbar setItems:items];

    dataTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataTable.backgroundColor = [UIColor clearColor];
    dataTable.rowHeight = 60;
    
}

-(void)saveState {    
    [[NSUserDefaults standardUserDefaults] setObject:self.filter forKey:@"tagFilter"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.statusFilter+1 forKey:@"statusFilter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)loadState {
    NSString* tagFilter = [[NSUserDefaults standardUserDefaults] objectForKey:@"tagFilter"];
    NSInteger statusCodeFilter = [[NSUserDefaults standardUserDefaults] integerForKey:@"statusFilter"];
    
    self.filter = tagFilter;
    if (statusCodeFilter != 0) {
        self.statusFilter = statusCodeFilter - 1;
    } else {
        self.statusFilter = 2;
    }    
}

#pragma mark - Button Pressed Events

- (IBAction)editButtonPressed:(UIButton*)aButton {
    [[self dataTable] setEditing:YES animated:YES];
    NSArray* items = [[[NSArray alloc] initWithObjects:self.saveTableButton, self.filterTableButton, nil] autorelease];
    [self.toolbar setItems:items];
}

- (IBAction)saveButtonPressed:(UIButton*)aButton {
    [[self dataTable] setEditing:NO animated:YES];
    NSArray* items = [[[NSArray alloc] initWithObjects:self.editTableButton, self.filterTableButton, nil] autorelease];
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
                                             statusFilter:self.statusFilter];
	
	// 
	// Pass the selected object to the new view controller.
	//
	[self presentModalViewController:filterTask animated:YES];
	[filterTask release];
}

- (void) setupFilteredTasks {
    NSArray *tmpTasks = [TaskDAO getAllChildTasks:self.parentId :self.parentSystemId];
    if (filter != nil) {
        self.tasks = [[[NSMutableArray alloc] init] autorelease];
        for (Task *task in tmpTasks) {
            if ([[task tags] containsObject:filter]) {
                [self.tasks addObject:task];
            }
        }
    } else {
        self.tasks = [[tmpTasks mutableCopy] autorelease];
    }
    
    if (self.statusFilter != 2) {
        NSMutableArray* filteredTasks = [[[NSMutableArray alloc] init] autorelease];
        for (Task* task in self.tasks) {
            if (self.statusFilter == task.status) {
                [filteredTasks addObject:task];
            }
        }
        self.tasks = filteredTasks;
    }
    
    [self saveState];
}

- (void)setupTags {
    if (self.tags == nil) {
        self.tags = [[TaskDAO getAllTags] autorelease];
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
	
    UIView *viewBase = self.view;
    TaskManager2AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    viewBase = [delegate.tabBarController view];

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
    if (self.filter != nil || self.statusFilter != 2) {
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
        NSString *filterStr = @"";
        if (self.filter != nil) {
            filterStr = [filterStr stringByAppendingFormat:@"[Tag = %@]  ", self.filter];
        }
        if (self.statusFilter != 2) {
            if (self.statusFilter == 0) {
                filterStr = [filterStr stringByAppendingString:@"[Not Completed Tasks]"];
            } else {
                filterStr = [filterStr stringByAppendingString:@"[Completed Tasks]"];
            }
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;

        cell.textLabel.text = @"Tasks filtered by:";
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];

        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];;
        cell.detailTextLabel.text = filterStr;
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.imageView.image = nil;
    } else {
        if ([self.tasks count] == 0) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"0 tasks to display";
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.text = nil;
            cell.imageView.image = nil;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
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
                    cell.textLabel.backgroundColor = [UIColor clearColor];
                } else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.textLabel.backgroundColor = [UIColor clearColor];
                }
                
                // Display the task description
                NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
                [formatter setDateStyle:NSDateFormatterLongStyle];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Due date: %@", [formatter stringFromDate:task.endDate]];
                if (task.status == 1) {
                    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                } else {
                    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];;
                    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                }
            } else {
                NSLog(@"%d section: %d row: nil pointer", indexPath.section, indexPath.row);
            }
        }
    }
    
    //
    // Set the background and selected background images for the text.
    // Since we will round the corners at the top and bottom of sections, we
    // need to conditionally choose the images based on the row index and the
    // number of rows in the section.
    //
    UIImage *rowBackground;
    UIImage *selectionBackground;
    NSInteger sectionRows = [self.tasks count];
    NSInteger row = [indexPath row];
	if (indexPath.section == 0) {
        if (([self.tasks count] == 0) || (row == 0 && row == sectionRows - 1)) {
            rowBackground = [UIImage imageNamed:@"topAndBottomRow.png"];
            selectionBackground = [UIImage imageNamed:@"topAndBottomRowSelected.png"];
        } else if (row == 0) {
            rowBackground = [UIImage imageNamed:@"topRow.png"];
            selectionBackground = [UIImage imageNamed:@"topRowSelected.png"];
        } else if (row == sectionRows - 1) {
            rowBackground = [UIImage imageNamed:@"bottomRow.png"];
            selectionBackground = [UIImage imageNamed:@"bottomRowSelected.png"];
        } else {
            rowBackground = [UIImage imageNamed:@"middleRow.png"];
            selectionBackground = [UIImage imageNamed:@"middleRowSelected.png"];
        }
    } else {
        rowBackground = [UIImage imageNamed:@"topAndBottomRow.png"];
        selectionBackground = [UIImage imageNamed:@"topAndBottomRowSelected.png"];
    }
        
    cell.backgroundView = [[[UIImageView alloc] init] autorelease];
    cell.selectedBackgroundView =[[[UIImageView alloc] init] autorelease];
    ((UIImageView *)cell.backgroundView).image = rowBackground;
    ((UIImageView *)cell.selectedBackgroundView).image = selectionBackground;
    
    return cell;
}


//
// Override to support editing the table view.
//
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	Task* task = [self.tasks objectAtIndex:indexPath.row];
	[TaskDAO deleteTask:task.taskId :task.systemId];
	[self.tasks removeObjectAtIndex:[indexPath row]];
	[self.dataTable reloadData]; 
}

//
// Override to support rearranging the table view.
//
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if (toIndexPath.row != [self.tasks count]) {
        int from = fromIndexPath.row;
        int to   = toIndexPath.row;
        if (from == to) {
            return;
        }
        
        // Get indexes from the full list based.
        NSMutableArray* fullList = nil;
        if (self.filter == nil && self.statusFilter == 2) {
            fullList = self.tasks;
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

    if (self.filter != nil || self.statusFilter != 2) {
        self.tasks = [[TaskDAO getAllChildTasks:self.parentId :self.parentSystemId] mutableCopy];
        [self setupFilteredTasks];
    }
    
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
    [tasks release];
    [tags release];
    [parentSystemId release];
    [filter release];
    [super dealloc];
}


@end

