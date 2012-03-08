//
//  MasterViewController.h
//  SplitViewTest
//
//  Created by Peter Chase on 12-01-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController {
    int parentTaskId;
}

@property (nonatomic, assign) int parentTaskId;
@property (strong, nonatomic) NSString* parentSystemId;
@property (strong, nonatomic) DetailViewController *detailViewController;

@end
