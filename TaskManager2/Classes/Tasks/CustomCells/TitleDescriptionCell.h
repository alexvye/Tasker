//
//  TitleDescriptionCell.h
//  TaskManager2
//
//  Created by Peter Chase on 11-03-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TitleDescriptionCell : UITableViewCell {
	UILabel* titleLabel;
	UILabel* descriptionLabel;
}

@property(nonatomic, retain) IBOutlet UILabel* titleLabel;
@property(nonatomic, retain) IBOutlet UILabel* descriptionLabel;


-(void) setTitle:(NSString*)aTitle;
-(void) setDescription:(NSString*)aDescription;

@end
