//
//  TaskDetailViewController.h
//  TaskManager2
//
//  Created by Alex Vye on 11-02-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "TaskDetailsDataSource.h"

@interface TaskDetailViewController : UIViewController<UITableViewDelegate>
@property(nonatomic, strong) TaskDetailsDataSource* dataSource;
@property(nonatomic, strong) IBOutlet UITableView* dataTable;

- (IBAction)editTask:(id)sender;

@end
