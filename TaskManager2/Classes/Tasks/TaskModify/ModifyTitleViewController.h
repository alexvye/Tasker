//
//  ModifyTitleViewController.h
//  TaskManager2
//
//  Created by Peter Chase on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ModifyTitleViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView* dateTable;
	NSString* taskTitle;
	NSString* taskDescription;
}

@property(nonatomic, retain) IBOutlet UITableView* dateTable;
@property(nonatomic, retain) NSString* taskTitle;
@property(nonatomic, retain) NSString* taskDescription;

- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)aTitle description:(NSString*)aDescription;

@end
