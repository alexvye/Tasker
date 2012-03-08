//
//  StartEndDateCell.m
//  TaskManager2
//
//  Created by Peter Chase on 11-03-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StartEndDateCell.h"


@implementation StartEndDateCell
@synthesize startDateLabel;
@synthesize endDateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[startDateLabel release];
	[endDateLabel release];
    [super dealloc];
}


@end
