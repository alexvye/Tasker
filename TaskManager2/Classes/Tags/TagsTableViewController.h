//
//  TagsTableViewController.h
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagsTableViewController : UIViewController {
	UITableView* dataTable;
    UIBarButtonItem* editTableButton;
    UIBarButtonItem* saveTableButton;
}

@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(nonatomic, retain) UIBarButtonItem* editTableButton;
@property(nonatomic, retain) UIBarButtonItem* saveTableButton;

-(IBAction)editButtonPressed:(UIButton*)aButton;
-(IBAction)saveButtonPressed:(UIButton*)aButton;

@end
