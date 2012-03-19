//
//  TagsDataSource.h
//  TaskManager2
//
//  Created by Peter Chase on 12-03-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagsDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, strong) NSArray* tags;

- (void)loadTags;

@end
