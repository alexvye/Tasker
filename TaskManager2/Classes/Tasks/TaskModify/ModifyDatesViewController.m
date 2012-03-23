//
//  ModifyDatesViewController.m
//  TaskManager2
//
//  Created by Peter Chase on 11-02-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModifyDatesViewController.h"
#import "DateViewCell.h"
#import "DataManager.h"
#import "CommonUI.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation ModifyDatesViewController
@synthesize dateTable;
@synthesize datePicker;
@synthesize startDate;
@synthesize endDate;
@synthesize toolbar;

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.datePicker addTarget:self 
				   action:@selector(dateChanged:) 
		 forControlEvents:UIControlEventValueChanged];
    [CommonUI addToolbarToViewController:self withTitle:@"Start & End"];
    self.view.backgroundColor = [UIColor colorWithRed:(0xE2 / 255.0) 
                                                green:(0xE5 / 255.0) 
                                                 blue:(0xE9 / 255.0) 
                                                alpha:1.0];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)dealloc {
	[dateTable release];
	[datePicker release];
	[startDate release];
	[endDate release];
	[toolbar release];
    [super dealloc];
}

- (IBAction)dateChanged:(id)sender {
	if ([sender isKindOfClass:[UIDatePicker class]]) {
		NSIndexPath* indexPath = [self.dateTable indexPathForSelectedRow];
		if (indexPath != nil) {
			// Set the date value in the cell.
			DateViewCell* cell = (DateViewCell*) [self.dateTable cellForRowAtIndexPath:indexPath];

			// Set the date object.
			if (indexPath.row == 0) {
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *comp = [gregorian components:  (NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate: datePicker.date];
                [comp setHour:0];
                [comp setMinute:0];
                [comp setSecond:0];
                self.startDate = [gregorian dateFromComponents:comp];
                [gregorian release];                
				[cell setDate:self.startDate];
			} else {
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                NSDateComponents *comp = [gregorian components:  (NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate: datePicker.date];
                [comp setHour:23];
                [comp setMinute:59];
                [comp setSecond:59];
                self.endDate = [gregorian dateFromComponents:comp];
                [gregorian release];                
				[cell setDate:self.endDate];
			}
			
			if ([self.startDate compare:self.endDate] == NSOrderedDescending) {
				NSArray* cells = [self.dateTable visibleCells];
				for (DateViewCell* cell in cells) {
					cell.cellDate.textColor = [UIColor redColor];
				}
			} else {
				NSArray* cells = [self.dateTable visibleCells];
				for (DateViewCell* cell in cells) {
					cell.cellDate.textColor = [UIColor blackColor];
				}
			}
			
		}
	}
}

- (IBAction)cancelPressed:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)donePressed:(id)sender {
	// Check to make sure dates are not valid
	if ([self.startDate compare:self.endDate] == NSOrderedDescending) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error Saving Date" 
															message:@"The start date must be before the end date." 
														   delegate:self 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	} else {
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
            if ([vc respondsToSelector:@selector(task)]) {
                Task* task = objc_msgSend(vc, sel_getUid("task"));
                task.startDate = self.startDate;
                task.endDate = self.endDate;
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString *SectionsTableIdentifier = @"ModifyDateCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
	if (cell == nil) {
		// Highlight the first date.
		if (indexPath.row == 0 && indexPath.section == 0) {
			[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
			datePicker.date = self.startDate;
		}
		
		CGRect frame;
		frame.origin.x = 0;
		frame.origin.y = 0;
		frame.size.height = 50;
		frame.size.width = 320;
		cell = [[[DateViewCell alloc] initWithFrame:frame] autorelease];
	}

	// Set the date object in the cell.
	DateViewCell* dateCell = (DateViewCell*) cell;
	if (indexPath.row == 0) {
		[dateCell setTitle:@"Starts"];
		[dateCell setDate:self.startDate];
	} else {
		[dateCell setTitle:@"Ends"];
		[dateCell setDate:self.endDate];
	}

	return cell;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	// Set the date picker with the selected date.
	if (indexPath.row == 0) {
		self.datePicker.date = self.startDate;
	} else {
		self.datePicker.date = self.endDate; 
	}
	return indexPath;
}

@end
