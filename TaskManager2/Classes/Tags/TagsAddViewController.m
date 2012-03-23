//
//  TagsAddViewController.m
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TagsAddViewController.h"
#import "EnterDataCellView.h"
#import "MasterViewController.h"
#import "CommonUI.h"
#import "TaskDAO.h"

@implementation TagsAddViewController
@synthesize popover = _popover;
@synthesize dataTable;
@synthesize newTagFlag;
@synthesize prevTag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self != nil) {
		self.newTagFlag = true;
		self.prevTag = nil;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	if (self.newTagFlag) {
		[CommonUI addToolbarToViewController:self withTitle:@"New Tag"];
	} else {
		[CommonUI addToolbarToViewController:self withTitle:@"Edit Tag"];
	}
    [super viewDidLoad];
}
/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait ||
			toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
			toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
*/
- (void)dealloc {
    [_popover release];
	[dataTable release];
	[prevTag release];
    [super dealloc];
}

- (IBAction)cancelPressed:(UIButton*)aButton {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)donePressed:(UIButton*)aButton {
	NSArray* cells = [self.dataTable visibleCells];
	NSString* newTag = nil;
	for (EnterDataCellView* cell in cells) {
		newTag = [cell.dataField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		break;
	}
	
	if (newTag == nil || newTag.length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Tag" 
														message:@"Must enter a value in order to save the tag." 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if (self.newTagFlag) {
		if ([TaskDAO doesTagExist:newTag]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Tag" 
															message:@"The entered tag already exists." 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		} else {
			[TaskDAO addTag:newTag];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                MasterViewController* mvc = (MasterViewController*)self.popover.delegate;
                mvc.tagDataSource.tags = nil;
                [mvc.dataTable reloadData];
                [self.popover dismissPopoverAnimated:YES];
            } else {
                [self dismissModalViewControllerAnimated:YES];
            }
		}
	} else {
		[TaskDAO updateTag:newTag :self.prevTag];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            MasterViewController* mvc = (MasterViewController*)self.popover.delegate;
            mvc.tagDataSource.tags = nil;
            [mvc.dataTable reloadData];
            [self.popover dismissPopoverAnimated:YES];
        } else {
            [self dismissModalViewControllerAnimated:YES];
        }
	}
}	

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString *tagAddCell = @"TagAddCell";
	EnterDataCellView* cell = (EnterDataCellView*)
		[tableView dequeueReusableCellWithIdentifier:tagAddCell];
	if (cell == nil) {
		cell = [[[EnterDataCellView alloc] initWithFrame:self.view.bounds type:@"Tag" value:nil] autorelease];
	}

	if (!self.newTagFlag) {
		cell.dataField.text = self.prevTag;
	}
	
	return cell;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	return indexPath;
}

@end
