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
@synthesize dataTable;
@synthesize editTableButton;
@synthesize saveTableButton;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTags:)];
	self.navigationItem.rightBarButtonItem = plusButton;
	[plusButton release];
    
    // Create the edit button.
    self.editTableButton = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editButtonPressed:)] autorelease];
    self.saveTableButton = [[[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)] autorelease];
    self.navigationItem.leftBarButtonItem = self.editTableButton;        
    
    dataTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    dataTable.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
	[DataManager loadData];
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
	 //
	 // push the view controller
	 //
	 TagsAddViewController *tagsAddView = [[[TagsAddViewController alloc] 
											initWithNibName:@"TagsAddViewController" 
											         bundle:nil] autorelease];
	 
	 // 
	 // Pass the selected object to the new view controller.
	 //
	 [self presentModalViewController:tagsAddView animated:YES];
 }


#pragma mark -
#pragma mark Table view data source

- (void) deselect
{	
	[self.dataTable deselectRowAtIndexPath:[self.dataTable indexPathForSelectedRow] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[DataManager getSelectedTags] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    [[cell textLabel] setText:(NSString*) [[DataManager getSelectedTags] objectAtIndex:[indexPath row]]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
		
	//
	// Set the background and selected background images for the text.
	// Since we will round the corners at the top and bottom of sections, we
	// need to conditionally choose the images based on the row index and the
	// number of rows in the section.
	//
	UIImage *rowBackground;
	UIImage *selectionBackground;
	NSInteger sectionRows = [[DataManager getSelectedTags] count];
	NSInteger row = [indexPath row];
	if (row == 0 && row == sectionRows - 1) {
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
	[TaskDAO removeTag:[[DataManager getSelectedTags] objectAtIndex:indexPath.row]];
	[[DataManager getSelectedTags] removeObjectAtIndex:[indexPath row]];
	[self.dataTable reloadData]; 
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	UITableViewCell *cell = [self.dataTable cellForRowAtIndexPath:indexPath];
	if (cell != nil) {
		TagsAddViewController *tagsUpdateView = [[[TagsAddViewController alloc] 
											   initWithNibName:@"TagsAddViewController" 
											   bundle:nil] autorelease];
		tagsUpdateView.newTagFlag = NO;
		tagsUpdateView.prevTag = cell.textLabel.text;
		[self presentModalViewController:tagsUpdateView animated:YES];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[dataTable release];
    [editTableButton release];
    [saveTableButton release];
    [super dealloc];
}


@end

