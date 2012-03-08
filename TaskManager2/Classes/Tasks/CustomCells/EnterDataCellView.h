//
//  EnterDataCellView.h
//  TaskManager2
//
//  Created by Peter Chase on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EnterDataCellView : UITableViewCell<UITextFieldDelegate> {
	UITextField* dataField;
}

@property(nonatomic, retain) IBOutlet UITextField* dataField;

- (id)initWithFrame:(CGRect)frame type:(NSString*)aType value:(NSString*)aValue;

@end
