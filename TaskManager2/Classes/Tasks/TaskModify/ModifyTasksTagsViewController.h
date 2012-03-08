//
//  ModifyTasksTagsViewController.h
//  TaskManager2
//
//  Created by Peter Chase on 11-03-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ModifyTasksTagsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView* dataTable;
	NSArray* tags;
	NSArray* tasksTags;
}

@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(nonatomic, retain) NSArray* tags;
@property(nonatomic, retain) NSArray* tasksTags;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end
