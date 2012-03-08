//
//  TagsAddViewController.h
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TagsAddViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
	UITableView* dataTable;
	NSString* prevTag;
	BOOL newTagFlag;
}

@property(nonatomic, retain) IBOutlet UITableView* dataTable;
@property(nonatomic, retain) NSString* prevTag;
@property(assign) BOOL newTagFlag;

- (IBAction)cancelPressed:(UIButton*)aButton;
- (IBAction)donePressed:(UIButton*)aButton;

@end
