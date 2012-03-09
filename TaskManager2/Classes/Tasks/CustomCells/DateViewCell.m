//
//  DateViewCell.m
//  TaskManager2
//
//  Created by Peter Chase on 11-03-01.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DateViewCell.h"


@implementation DateViewCell
@synthesize cellLabel;
@synthesize cellDate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self != nil) {
		self.cellLabel = [[[UILabel alloc] initWithFrame:CGRectMake(20, 10, 77, 21)] autorelease];
		self.cellLabel.textAlignment = UITextAlignmentLeft;
		self.cellLabel.backgroundColor = [UIColor clearColor];
		self.cellLabel.highlightedTextColor = [UIColor whiteColor];
		self.cellLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];

		self.cellDate = [[[UILabel alloc] initWithFrame:CGRectMake(88, 10, 192, 21)] autorelease];
		self.cellDate.textAlignment = UITextAlignmentRight;
		self.cellDate.backgroundColor = [UIColor clearColor];
		self.cellDate.highlightedTextColor = [UIColor whiteColor];
		self.cellDate.font = [UIFont fontWithName:@"Helvetica" size:17];

	    [self.contentView addSubview:cellLabel];
		[self.contentView addSubview:cellDate];
	}
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[cellLabel release];
	[cellDate release];
    [super dealloc];
}


- (void)setTitle:(NSString*)title {
//	cellLabel.text = title;
    self.textLabel.text = title;
}


- (void)setDate:(NSDate*)date {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:NSDateFormatterLongStyle];
//	cellDate.text = [formatter stringFromDate:date];
    self.detailTextLabel.text = [formatter stringFromDate:date];
}


- (NSDate*)getDate {
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateStyle:NSDateFormatterLongStyle];
	return [formatter dateFromString:cellDate.text];
}

@end
