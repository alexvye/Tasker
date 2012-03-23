//
//  MasterViewController.m
//  SplitViewTest
//
//  Created by Peter Chase on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "FilterTasksViewController.h"
#import "Task.h"
#import "TaskDAO.h"

@interface MasterViewController () {
    BOOL first;
}

@end

@implementation MasterViewController
@synthesize detailViewController = _detailViewController;
@synthesize typeSelect = _typeSelect;
@synthesize dataTable = _dataTable;
@synthesize toolbar = _toolbar;
@synthesize filterButton = _filterButton;
@synthesize editButton = _editButton;
@synthesize doneButton = _doneButton;
@synthesize flexible = _flexible;
@synthesize taskDataSource = _taskDataSource;
@synthesize tagDataSource = _tagDataSource;
@synthesize filterPopover = _filterPopover;
@synthesize selectedTask = _selectedTask;


#pragma mark - UIViewController methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.filterButton = [[[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(changeFilter:)] autorelease];
        self.editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable:)] autorelease];
        self.doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editTableDone:)] autorelease];
        self.flexible = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

        self.taskDataSource = [[[TaskDataSource alloc] init] autorelease];
        self.taskDataSource.parentId = NO_PARENT;
		self.taskDataSource.parentSystemId = nil;        
        self.taskDataSource.startedFilter = NO;

        self.tagDataSource = [[[TagsDataSource alloc] init] autorelease];
        
        self.title = NSLocalizedString(@"Tasks", @"Tasks");
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        
        first = YES;
    }
    return self;
}
							
- (void)dealloc
{
    [_detailViewController release];
    [_typeSelect release];
    [_dataTable release];
    [_toolbar release];
    [_filterButton release];
    [_editButton release];
    [_doneButton release];
    [_flexible release];
    [_taskDataSource release];
    [_tagDataSource release];
    [_filterPopover release];
    [_selectedTask release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    self.tagDataSource.tags = nil;
    if (self.filterPopover != nil && ![self.filterPopover isPopoverVisible]) {
        self.filterPopover = nil;
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.dataTable.dataSource = self.taskDataSource;
    [self.taskDataSource loadState];

//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    NSArray* items = [[[NSArray alloc] initWithObjects:self.filterButton, self.flexible, self.editButton, nil] autorelease];
    [self.toolbar setItems:items];

    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (first) {
        first = NO;
    } else {
        [self.detailViewController setDetailItem:self.selectedTask];
        [self.taskDataSource loadState];
        if (self.typeSelect.segmentedControlStyle == 0) {
            [self.dataTable reloadData];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - UI event methods
- (IBAction)insertNewObject:(id)sender {
    if (self.typeSelect.selectedSegmentIndex == 0) {
        NSLog(@"TASK ADD");
    } else {
        NSLog(@"TAG ADD");
    }
}

- (IBAction)typeChange:(id)sender {
    if (self.typeSelect.selectedSegmentIndex == 0) {
        self.dataTable.dataSource = self.taskDataSource;
    } else {
        self.dataTable.dataSource = self.tagDataSource;
    }
    [self.dataTable reloadData];
}

- (IBAction)changeFilter:(id)sender {
    if (self.filterPopover != nil && [self.filterPopover isPopoverVisible]) {
        [self.filterPopover dismissPopoverAnimated:YES];
    } else {
        NSString* tagFilter = [[NSUserDefaults standardUserDefaults] objectForKey:@"tagFilter"];
        NSInteger statusFilter = [[NSUserDefaults standardUserDefaults] integerForKey:@"statusFilter"];
        BOOL startFilter = [[NSUserDefaults standardUserDefaults] boolForKey:@"startedFilter"];
        
        if (statusFilter != 0) {
            statusFilter = statusFilter - 1;
        } else {
            statusFilter = 2;
        }    

        FilterTasksViewController* ftvc = [[[FilterTasksViewController alloc] initWithNibName:@"FilterTasksViewController" bundle:nil tagFilter:tagFilter statusFilter:statusFilter startFilter:startFilter] autorelease];
        
        self.filterPopover = [[[UIPopoverController alloc] initWithContentViewController:ftvc] autorelease];
        self.filterPopover.popoverContentSize = ftvc.view.frame.size;
        self.filterPopover.delegate = self;
        ftvc.popover = self.filterPopover;
        [self.filterPopover presentPopoverFromBarButtonItem:sender 
                                        permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    
    }
}

- (IBAction)editTable:(id)sender {
    [[self dataTable] setEditing:YES animated:YES];
    NSArray* items = [[[NSArray alloc] initWithObjects:self.filterButton, self.flexible, self.doneButton, nil] autorelease];
    [self.toolbar setItems:items];
}

- (IBAction)editTableDone:(id)sender {
    [[self dataTable] setEditing:NO animated:YES];
    NSArray* items = [[[NSArray alloc] initWithObjects:self.filterButton, self.flexible, self.editButton, nil] autorelease];
    [self.toolbar setItems:items];
}

#pragma mark - UITableViewDelegate methods

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.typeSelect.selectedSegmentIndex == 0) {
        if (indexPath.section == 0 && self.taskDataSource.count > 0) {
            return indexPath;
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            return indexPath;
        }
        
        return nil;
    } else {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.typeSelect.selectedSegmentIndex == 0) {
        if (indexPath.section == 0 && self.taskDataSource.count > indexPath.row) {
            Task* task = [TaskDAO getFilteredTaskFor:indexPath.row parentId:self.taskDataSource.parentId parentSystemId:self.taskDataSource.parentSystemId forTag:self.taskDataSource.tagFilter status:self.taskDataSource.statusFilter andStarted:self.taskDataSource.startedFilter];
            [self.detailViewController setDetailItem:task]; 
            
            MasterViewController* mvc = [[[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil] autorelease];
            mvc.detailViewController = self.detailViewController;
            mvc.taskDataSource.parentId = task.taskId;
            mvc.taskDataSource.parentSystemId = task.systemId;
            mvc.selectedTask = task;

            [self.navigationController pushViewController:mvc animated:YES];
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            [self changeFilter:self.filterButton];
        }
    }
}

#pragma mark - UIPopoverControllerDelegate methods
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.taskDataSource loadState];
    if (self.typeSelect.segmentedControlStyle == 0) {
        [self.dataTable reloadData];
    }    
}

@end
