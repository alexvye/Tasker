//
//  MasterViewController.h
//  SplitViewTest
//
//  Created by Peter Chase on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDataSource.h"
#import "TagsDataSource.h"

@class DetailViewController;

@interface MasterViewController : UIViewController<UITableViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) IBOutlet UISegmentedControl* typeSelect;
@property (strong, nonatomic) IBOutlet UITableView* dataTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem* filterButton;
@property (strong, nonatomic) TaskDataSource* taskDataSource;
@property (strong, nonatomic) TagsDataSource* tagDataSource;
@property (nonatomic, strong) UIPopoverController* filterPopover;

- (IBAction)insertNewObject:(id)sender;
- (IBAction)typeChange:(id)sender;
- (IBAction)changeFilter:(id)sender;

@end
