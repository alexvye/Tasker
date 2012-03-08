//
//  TaskTableViewController.h
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskTableViewController : UIViewController<UITableViewDataSource, UIActionSheetDelegate> {
	UITableView* dataTable;
    UIToolbar* toolbar;
    UIBarButtonItem* editTableButton;
    UIBarButtonItem* saveTableButton;
    UIBarButtonItem* filterTableButton;
    NSMutableArray* tasks;
	int parentId;
	NSString* parentSystemId;
    NSString* filter;
    int statusFilter;
}

@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(nonatomic, retain) IBOutlet UIToolbar* toolbar;
@property(nonatomic, retain) UIBarButtonItem* editTableButton;
@property(nonatomic, retain) UIBarButtonItem* saveTableButton;
@property(nonatomic, retain) UIBarButtonItem* filterTableButton;
@property(nonatomic, retain) NSMutableArray* tasks;
@property(nonatomic, assign) int parentId;
@property(nonatomic, retain) NSString* parentSystemId;
@property(nonatomic, retain) NSString* filter;
@property(nonatomic, assign) int statusFilter;

- (IBAction)editButtonPressed:(UIButton*)aButton;
- (IBAction)saveButtonPressed:(UIButton*)aButton;
- (IBAction)addTask:(UIButton*)aButton;
- (IBAction)addFilters:(UIButton*)aButton;
- (IBAction)addStatusFilter:(UIButton*)aButton;
- (void)popupActionSheet;
- (void)setupFilteredTasks;

@end
