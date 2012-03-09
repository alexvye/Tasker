//
//  ModifyRecurranceValueViewController.m
//  TaskManager2
//
//  Created by Peter Chase on 11-03-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModifyRecurranceValueViewController.h"
#import "CommonUI.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define MAX_WEEKS	4
#define MAX_MONTHS	6

@implementation ModifyRecurranceValueViewController
@synthesize dataTable;
@synthesize repeatType;
@synthesize repeatValue;
@synthesize daysOfTheWeek;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.daysOfTheWeek = [[[NSArray alloc] initWithObjects:@"Sunday",@"Monday",@"Tuesday",
							   @"Wednesday",@"Thursday",@"Friday",@"Saturday",nil] autorelease];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if (self.repeatType == DAILY) {
        [CommonUI addToolbarToViewController:self withTitle:@"Select Days"];
        if (self.repeatValue == NO_PARENT) {
            self.repeatValue = 127;
        }
	} else if (self.repeatType == WEEKLY) {
        [CommonUI addToolbarToViewController:self withTitle:@"Number of Weeks"];
        if (self.repeatValue == NO_PARENT) {
            self.repeatValue = 1;
        }
	} else {
        [CommonUI addToolbarToViewController:self withTitle:@"Number of Months"];
        if (self.repeatValue == NO_PARENT) {
            self.repeatValue = 1;
        }
	}
}

- (void)dealloc {
	[dataTable release];
	[daysOfTheWeek release];
    [super dealloc];
}


- (IBAction)cancelPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)donePressed:(id)sender {
	UIViewController* vc = [self parentViewController];
    if (vc == nil) {
        vc = self.presentingViewController;
    }

    if (vc != nil) {
        int newRepeatValue;
        if (self.repeatType == DAILY) {
            NSArray* cells = [self.dataTable visibleCells];
            int rtn = 0;
            for (int i = 0; i < 7; i++) {
                UITableViewCell* cell = [cells objectAtIndex:i];
                if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                    rtn = rtn | (int) pow(2.0f, (float) i);
                }
            }
            newRepeatValue = rtn;
        } else {
            newRepeatValue = self.repeatValue;
        }
        if ([vc respondsToSelector:@selector(setRepeatValue:)]) {
            objc_msgSend(vc, sel_getUid("setRepeatValue:"), newRepeatValue);
        }

        if ([vc respondsToSelector:@selector(setRepeatType:)]) {
            objc_msgSend(vc, sel_getUid("setRepeatType:"), self.repeatType);
        }
        
        // Reload the data table on the parent view controller.
        if ([vc respondsToSelector:@selector(dataTable)]) {
            UITableView* dt = objc_msgSend(vc, sel_getUid("dataTable"));
            [dt reloadData];
        }
    }
    
	[self dismissModalViewControllerAnimated:YES];
}
	

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.repeatType == DAILY) {
		return self.daysOfTheWeek.count;
	} else if (self.repeatType == WEEKLY) {
		return MAX_WEEKS;
	} else {
		return MAX_MONTHS;
	}
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString *repeatDaysCell = @"ModifyRepeatDaysCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:repeatDaysCell];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:repeatDaysCell] autorelease];
	}
	
	if (self.repeatType == DAILY) {
		int index = pow(2.0, (float) [indexPath row]);
		if (index == (self.repeatValue & index)) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		cell.textLabel.text = [daysOfTheWeek objectAtIndex:[indexPath row]];
	} else {
		if ((indexPath.row + 1) == self.repeatValue) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
	}

	return cell;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	if (self.repeatType == DAILY) {
		UITableViewCell* cell = [[tableView visibleCells] objectAtIndex:indexPath.row];
		if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	} else {
		for (UITableViewCell* cell in [tableView visibleCells]) {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		UITableViewCell* cell = [[tableView visibleCells] objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		self.repeatValue = indexPath.row + 1;
	}
	return indexPath;
}


@end
