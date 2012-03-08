//
//  EnterDataCellView.m
//  TaskManager2
//
//  Created by Peter Chase on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EnterDataCellView.h"


@implementation EnterDataCellView
@synthesize dataField;

- (id)initWithFrame:(CGRect)frame type:(NSString*)aType value:(NSString*)aValue {
	if (self = [super initWithFrame:frame]) {
		CGRect bounds = self.bounds;
		bounds.origin.x += 10;
		bounds.size.width = 300;
		self.dataField = [[[UITextField alloc] initWithFrame:bounds] autorelease];
		self.dataField.borderStyle = UITextBorderStyleNone;
		self.dataField.font = [UIFont systemFontOfSize:16];
		self.dataField.adjustsFontSizeToFitWidth = YES;
		self.dataField.minimumFontSize = 14.0;
		self.dataField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.dataField.delegate = self;
		self.dataField.placeholder = aType;
		self.dataField.text = aValue;
		self.dataField.returnKeyType = UIReturnKeyDefault;
		self.dataField.keyboardType = UIKeyboardTypeDefault;
		self.dataField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		self.dataField.autocorrectionType = UITextAutocorrectionTypeNo;
		self.dataField.clearButtonMode = UITextFieldViewModeAlways;
		self.dataField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
	    [self.contentView addSubview:self.dataField];
	}
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[dataField release];
    [super dealloc];
}


@end
