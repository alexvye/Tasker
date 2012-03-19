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
#import "Task.h"

@implementation TaskTableViewController
@synthesize dataTable;
@synthesize dataSource = _dataSource;
@synthesize toolbar;
@synthesize editTableButton;
@synthesize saveTableButton;
@synthesize filterTableButton;
@synthesize flexible;

#pragma mark - UIViewController methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        self.dataSource = [[[TaskDataSource alloc] init] autorelease];
        self.dataSource.parentId = NO_PARENT;
		self.dataSource.parentSystemId = nil;
        self.dataSource.startedFilter = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {        
        self.dataSource = [[[TaskDataSource alloc] init] autorelease];
        self.dataSource.parentId = NO_PARENT;
		self.dataSource.parentSystemId = nil;        
        self.dataSource.startedFilter = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the parent task index.
    self.dataTable.dataSource = self.dataSource;
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.dataSource loadState];
	[self.dataTable reloadData];
}

#pragma mark - Button Pressed Events

- (IBAction)editButtonPressed:(id)sender {
    [[self dataTable] setEditing:YES animated:YES];
    NSArray* items = [[[NSArray alloc] initWithObjects:self.saveTableButton, self.flexible, self.filterTableButton, nil] autorelease];
    [self.toolbar setItems:items];
}

- (IBAction)saveButtonPressed:(id)sender {
    [[self dataTable] setEditing:NO animated:YES];
    NSArray* items = [[[NSArray alloc] initWithObjects:self.editTableButton, self.flexible, self.filterTableButton, nil] autorelease];
    [self.toolbar setItems:items];
}

- (IBAction)addTask:(id)sender {
	TaskAddViewController *taskAddView = [[[TaskAddViewController alloc] 
                                          initWithNibName:@"TaskAddViewController" bundle:nil] autorelease];
	taskAddView.newTask = YES;
    taskAddView.parentId = self.dataSource.parentId;
    taskAddView.parentSystemId = self.dataSource.parentSystemId;

    self.dataSource.tasks = nil;
	[self presentModalViewController:taskAddView animated:YES];
}

- (IBAction)addStatusFilter:(id)sender {
	FilterTasksViewController* filterTask = [[[FilterTasksViewController alloc] 
                                             initWithNibName:@"FilterTasksViewController" 
                                             bundle:nil 
                                             tagFilter:self.dataSource.tagFilter 
                                             statusFilter:self.dataSource.statusFilter
                                             startFilter:self.dataSource.startedFilter] autorelease];
	
    self.dataSource.tasks = nil;
	[self presentModalViewController:filterTask animated:YES];
}
#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [self.dataSource.tasks count] > 0) {
        return indexPath;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.dataSource.tasks.count > indexPath.row) {
        TaskDetailViewController *taskDetailView = [[[TaskDetailViewController alloc] 
                                                    initWithNibName:@"TaskDetailViewController" bundle:nil] autorelease];

        Task* task = (Task*) [self.dataSource.tasks objectAtIndex:[indexPath row]];
        taskDetailView.task = task;
        
        self.dataSource.tasks = nil;
        [self.navigationController pushViewController:taskDetailView animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        [self addStatusFilter:self.filterTableButton];
    }
}

#pragma mark - Memory management methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
    self.dataSource.tasks = nil;
}

- (void)dealloc {
	[dataTable release];
    [_dataSource release];
    [toolbar release];
    [editTableButton release];
    [saveTableButton release];
    [filterTableButton release];
    [flexible release];
    [super dealloc];
}


@end

