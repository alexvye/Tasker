//
//  ModifyAlarmViewController.h
//  TaskManager2
//
//  Created by Peter Chase on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ModifyAlarmViewController : UIViewController {
    UISwitch* alarmToggle;
    UIDatePicker* alarmTime;
    NSDate* alarmDate;
}

@property(nonatomic, retain) IBOutlet UISwitch* alarmToggle;
@property(nonatomic, retain) IBOutlet UIDatePicker* alarmTime;
@property(nonatomic, retain) NSDate* alarmDate;

- (IBAction)alarmToggleChanged:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)donePressed:(id)sender;

@end
