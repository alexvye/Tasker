//
//  TagsTableViewController.m
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TagsTableViewController.h"
#import "TagsAddViewController.h"
#import "DataManager.h"
#import "TaskDAO.h"

@implementation TagsTableViewController
@synthesize dataSource = _dataSource;
@synthesize dataTable = _dataTable;
@synthesize editTableButton;
@synthesize saveTableButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        self.dataSource = [[[TagsDataSource alloc] init] autorelease];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self != nil) {        
        self.dataSource = [[[TagsDataSource alloc] init] autorelease];
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataTable.dataSource = self.dataSource;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTags:)];
	self.navigationItem.rightBarButtonItem = plusButton;
	[plusButton release];
    
    // Create the edit button.
    self.editTableButton = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonPressed:)] autorelease];
    self.saveTableButton = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)] autorelease];
    self.navigationItem.leftBarButtonItem = self.editTableButton;        
}

- (void)viewWillAppear:(BOOL)animated {
	[self.dataTable reloadData];
	[super viewWillAppear:animated];
}

-(IBAction)editButtonPressed:(UIButton*)aButton {
    [[self dataTable] setEditing:YES animated:YES];
    self.navigationItem.leftBarButtonItem = self.saveTableButton;
}

-(IBAction)saveButtonPressed:(UIButton*)aButton {
    [[self dataTable] setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = self.editTableButton;
}
 
 -(IBAction) addTags: (UIButton*) aButton {
	 TagsAddViewController *tagsAddView = [[[TagsAddViewController alloc] 
											initWithNibName:@"TagsAddViewController" 
											         bundle:nil] autorelease];
	 
     self.dataSource.tags = nil;
	 [self presentModalViewController:tagsAddView animated:YES];     
 }

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	UITableViewCell *cell = [self.dataTable cellForRowAtIndexPath:indexPath];
	if (cell != nil) {
		TagsAddViewController *tagsUpdateView = [[[TagsAddViewController alloc] 
											   initWithNibName:@"TagsAddViewController" 
											   bundle:nil] autorelease];
		tagsUpdateView.newTagFlag = NO;
		tagsUpdateView.prevTag = cell.textLabel.text;
        self.dataSource.tags = nil;
		[self presentModalViewController:tagsUpdateView animated:YES];
	}
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
    self.dataSource.tags = nil;
}


- (void)dealloc {
    [_dataSource release];
	[_dataTable release];
    [editTableButton release];
    [saveTableButton release];
    [super dealloc];
}


@end

