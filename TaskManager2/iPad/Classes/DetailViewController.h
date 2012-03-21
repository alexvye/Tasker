//
//  DetailViewController.h
//  SplitViewTest
//
//  Created by Peter Chase on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDetailsDataSource.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) TaskDetailsDataSource* dataSource;
@property (strong, nonatomic) IBOutlet UITableView *dataTable;

@end
