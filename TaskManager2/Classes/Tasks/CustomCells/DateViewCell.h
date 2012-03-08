//
//  DateViewCell.h
//  TaskManager2
//
//  Created by Peter Chase on 11-03-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DateViewCell : UITableViewCell {
	UILabel* cellLabel;
	UILabel* cellDate;
}

@property(nonatomic, retain) IBOutlet UILabel* cellLabel;
@property(nonatomic, retain) IBOutlet UILabel* cellDate;

- (void)setTitle:(NSString*)title;
- (void)setDate:(NSDate*)date;
- (NSDate*)getDate;

@end
