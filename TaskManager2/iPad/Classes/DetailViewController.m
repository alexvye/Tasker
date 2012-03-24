//
//  DetailViewController.m
//  SplitViewTest
//
//  Created by Peter Chase on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "TaskAddViewController.h"
#import "CommonUI.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
@synthesize editPopover = _editPopover;
@synthesize detailItem = _detailItem;
@synthesize dataSource = _dataSource;
@synthesize dataTable = _dataTable;
@synthesize masterPopoverController = _masterPopoverController;

- (void)dealloc
{
    [_editPopover release];
    [_detailItem release];
    [_dataSource release];
    [_dataTable release];
    [_masterPopoverController release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release]; 
        _detailItem = [newDetailItem retain]; 

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.
    self.dataSource.task = self.detailItem;
    [self.dataSource initLabels];
    [self.dataTable reloadData];

    if (self.detailItem) {
        self.dataSource.task = self.detailItem;
        [self.dataTable reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataTable.dataSource = self.dataSource;
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];

    UIBarButtonItem* editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTask:)] autorelease];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Details", @"Details");
        self.dataSource = [[[TaskDetailsDataSource alloc] init] autorelease];
    }
    return self;
}

- (IBAction)editTask:(id)sender {
    if (self.detailItem) {
        Task* task = (Task*)self.detailItem;
        TaskAddViewController* taskAddView = nil;

        taskAddView = [[[TaskAddViewController alloc] initWithNibName:@"TaskAddViewController" bundle:nil] autorelease];
        taskAddView.newTask = NO;
        taskAddView.task = task;
        taskAddView.parentId = task.parentId;
        taskAddView.parentSystemId = task.parentSystemId;
            
        UINavigationController* navBar = [[[UINavigationController alloc] initWithRootViewController:taskAddView] autorelease];
        navBar.view.frame = taskAddView.view.frame;
        navBar.navigationBar.hidden = TRUE;
        
        self.editPopover = [[[UIPopoverController alloc] initWithContentViewController:navBar] autorelease];
        taskAddView.popover = self.editPopover;
        self.editPopover.popoverContentSize = navBar.view.frame.size;
        self.editPopover.delegate = self;
        [self.editPopover presentPopoverFromBarButtonItem:sender 
                                permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Tasks", @"Tasks");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UITableViewDataSource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.task == nil) {
        return tableView.rowHeight;
    }
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
            float height = 20.0f;
            for (UILabel* label in self.dataSource.detailLabels) {
                height += label.bounds.size.height;
            }
            return height;
        } else if (indexPath.row == 1 && [CommonUI getNotificationForTask:self.dataSource.task] != nil) {
            return tableView.rowHeight;
		} else {
            CGRect frame = self.dataSource.repeatLabel.frame;
            frame.size = tableView.contentSize;
            self.dataSource.repeatLabel.frame = frame;
            [self.dataSource.repeatLabel sizeToFit];
            
            return self.dataSource.repeatLabel.frame.size.height + 20.0f;
		}
	} else {
		return tableView.rowHeight;
	}
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
