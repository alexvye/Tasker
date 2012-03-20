//
//  TaskDataSource.h
//  TaskManager2
//
//  Created by Peter Chase on 12-03-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, strong) NSArray* tasks;
@property (nonatomic, assign) int parentId;
@property (nonatomic, strong) NSString* parentSystemId;
@property (nonatomic, strong) NSString* tagFilter;
@property (nonatomic, assign) int statusFilter;
@property (nonatomic, assign) BOOL startedFilter;

- (void)loadTasks;
- (void)loadState;

@end
