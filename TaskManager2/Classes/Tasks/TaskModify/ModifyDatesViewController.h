//
//  ModifyDatesViewController.h
//  TaskManager2
//
//  Created by Peter Chase on 11-02-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ModifyDatesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView* dateTable;
	UIDatePicker* datePicker;
	NSDate* startDate;
	NSDate* endDate;
	UIToolbar* toolbar;
}

@property(nonatomic, retain) IBOutlet UITableView* dateTable;
@property(nonatomic, retain) IBOutlet UIDatePicker* datePicker; 
@property(nonatomic, retain) NSDate* startDate;
@property(nonatomic, retain) NSDate* endDate;
@property(nonatomic, retain) UIToolbar* toolbar;

- (IBAction)dateChanged:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end
