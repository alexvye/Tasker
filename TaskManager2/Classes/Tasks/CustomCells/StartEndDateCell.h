//
//  StartEndDateCell.h
//  TaskManager2
//
//  Created by Peter Chase on 11-03-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StartEndDateCell : UITableViewCell {
	UILabel* startDateLabel;
	UILabel* endDateLabel;
}

@property(nonatomic, retain) IBOutlet UILabel* startDateLabel;
@property(nonatomic, retain) IBOutlet UILabel* endDateLabel;

@end
