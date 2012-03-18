//
//  FilterTasksViewController.h
//  TaskManager2
//
//  Created by Peter Chase on 11-05-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FilterTasksViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView* dataTable;
    NSArray* tags;
    NSString* tagFilter;
    int statusFilter;
    BOOL startedFilter;
}

@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(nonatomic, retain) NSArray* tags;
@property(nonatomic, retain) NSString* tagFilter;
@property(assign) int statusFilter;
@property(assign) BOOL startedFilter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tagFilter:(NSString*)tag statusFilter:(int)status startFilter:(BOOL)startFilter;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end
