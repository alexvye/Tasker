//
//  ModifyTasksTagsViewController.m
//  TaskManager2
//
//  Created by Peter Chase on 11-03-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModifyTasksTagsViewController.h"
#import "TaskDAO.h"
#import "CommonUI.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation ModifyTasksTagsViewController
@synthesize dataTable;
@synthesize tags;
@synthesize tasksTags;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tags = [TaskDAO getAllTags];
    }
    return self;
}

- (void)dealloc {
	[dataTable release];
	[tags release];
	[tasksTags release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [CommonUI addToolbarToViewController:self withTitle:@"Select Tags"];
}

- (IBAction)cancelPressed:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)donePressed:(id)sender {
    NSMutableArray* newTagList = [[[NSMutableArray alloc] initWithCapacity:self.tags.count] autorelease];
    for (UITableViewCell* cell in [self.dataTable visibleCells]) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            NSIndexPath* indexPath = [self.dataTable indexPathForCell:cell];
            [newTagList addObject:[tags objectAtIndex:[indexPath row]]];
        }
    }
    
    UIViewController* vc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        vc = [self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count-2)];
    } else{
        vc = [self parentViewController];
    }
    
    if (vc == nil) {
        vc = self.presentingViewController;
    }

    if (vc != nil) {
        // Set the task's tags.
        if ([vc respondsToSelector:@selector(task)]) {
            Task* task = objc_msgSend(vc, sel_getUid("task"));
            task.tags = newTagList;
        }
        
        // Reload the data table on the parent view controller.
        if ([vc respondsToSelector:@selector(dataTable)]) {
            UITableView* dt = objc_msgSend(vc, sel_getUid("dataTable"));
            [dt reloadData];
        }
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return [tags count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString *modifyTaskCell = @"ModifyTaskCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:modifyTaskCell];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:modifyTaskCell] autorelease];
	}

	NSString* tag = [tags objectAtIndex:[indexPath row]];
	cell.textLabel.text = tag;
	if (self.tasksTags == nil || self.tasksTags.count == 0 || [self.tasksTags indexOfObject:tag] == NSNotFound) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}

	return cell;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	NSArray* cells = [tableView visibleCells];
	UITableViewCell* cell = [cells objectAtIndex:[indexPath row]];
	if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	return indexPath;
}


@end
