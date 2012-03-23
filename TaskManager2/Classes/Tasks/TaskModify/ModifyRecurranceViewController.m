//
//  ModifyRecurranceViewController.m
//  TaskManager2
//
//  Created by Peter Chase on 11-03-03.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModifyRecurranceViewController.h"
#import "ModifyRecurranceValueViewController.h"
#import "CommonUI.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation ModifyRecurranceViewController
@synthesize dataTable;
@synthesize repeatType;
@synthesize repeatValue;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [CommonUI addToolbarToViewController:self withTitle:@"Repeat Task"];
}

- (void)dealloc {
	[dataTable release];
    [super dealloc];
}

- (IBAction)cancelPressed:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)donePressed:(id)sender {
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
        NSArray* cells = [self.dataTable visibleCells];
        int i = 0;
        for (UITableViewCell* cell in cells) {
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                if ([vc respondsToSelector:@selector(task)]) {
                    Task* task = objc_msgSend(vc, sel_getUid("task"));
                    task.recurranceType = i;
                }
                
                if ([vc respondsToSelector:@selector(task)]) {
                    Task* task = objc_msgSend(vc, sel_getUid("task"));
                    task.recurranceValue = self.repeatValue;
                }
                break;
            }
            i++;
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
	return 4;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString *modifyRepeatType = @"ModifyRepeatTypeCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:modifyRepeatType];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:modifyRepeatType] autorelease];
	}

	NSArray* list = [[[NSArray alloc] initWithObjects:@"None",@"Daily",@"Weekly",@"Monthly",nil] autorelease];
	if ([indexPath row] == self.repeatType) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = [list objectAtIndex:[indexPath row]];

	return cell;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	NSArray* cells = [tableView visibleCells];
	for (UITableViewCell* cell in cells) {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	if ([indexPath row] == DAILY || indexPath.row == MONTHLY || indexPath.row == WEEKLY) {
		ModifyRecurranceValueViewController *repeatValueView = [[ModifyRecurranceValueViewController alloc] 
													initWithNibName:@"ModifyRecurranceValueViewController" bundle:nil];
		[repeatValueView autorelease];
		
		
		repeatValueView.repeatType = indexPath.row;
        repeatValueView.repeatValue = self.repeatValue;
		if (indexPath.row != self.repeatType) {
			repeatValueView.repeatValue = -1;
		}
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.navigationController pushViewController:repeatValueView animated:YES];
        } else {
            [self presentModalViewController:repeatValueView animated:YES];
        }
	} 
		
	return indexPath;
}


@end
