//
//  TitleDescriptionCell.m
//  TaskManager2
//
//  Created by Peter Chase on 11-03-05.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TitleDescriptionCell.h"

@interface TitleDescriptionCell ()

+(void)addString:(NSString*)text atlText:(NSString*)altText toLabel:(UILabel*)label;

@end



@implementation TitleDescriptionCell
@synthesize titleLabel;
@synthesize descriptionLabel;

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
	[titleLabel release];
	[descriptionLabel release];
    [super dealloc];
}

-(void) setTitle:(NSString*)aTitle {
	[TitleDescriptionCell addString:aTitle atlText:@"Title" toLabel:titleLabel];
}

-(void) setDescription:(NSString*)aDescription {
	[TitleDescriptionCell addString:aDescription atlText:@"Description" toLabel:descriptionLabel];
}

+(void)addString:(NSString*)text atlText:(NSString*)altText toLabel:(UILabel*)label {
	if (text == nil || text.length == 0) {
		label.text = altText;
		label.textColor = [UIColor lightGrayColor];
	} else {
		label.text = text;
		label.textColor = [UIColor colorWithRed:0.22 green:0.33 blue:0.53 alpha:1.0];
	}
}

@end
