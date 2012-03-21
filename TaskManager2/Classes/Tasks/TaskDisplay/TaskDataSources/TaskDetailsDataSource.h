//
//  TaskDetailsDataSource.h
//  TaskManager2
//
//  Created by Peter Chase on 12-03-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

@interface TaskDetailsDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, strong) Task* task;
@property (nonatomic, strong) NSArray* detailLabels;
@property (nonatomic, strong) UILabel* repeatLabel;
@property (nonatomic, strong) UITableView* dataTable;

- (IBAction)taskCompleted:(id)sender;
- (void)initLabels;

@end
