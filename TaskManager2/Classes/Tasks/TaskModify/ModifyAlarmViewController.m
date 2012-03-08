//
//  ModifyAlarmViewController.m
//  TaskManager2
//
//  Created by Peter Chase on 11-05-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModifyAlarmViewController.h"
#import "CommonUI.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation ModifyAlarmViewController
@synthesize alarmToggle;
@synthesize alarmTime;
@synthesize alarmDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [alarmToggle release];
    [alarmTime release];
    [alarmDate release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the toolbar.
    [CommonUI addToolbarToViewController:self withTitle:@"Alarm"];
        
    // Set the alarm flag and enable date picker if necessary.
    self.alarmToggle.on = (self.alarmDate != nil);
    [self alarmToggleChanged:nil];
    
    // Set the alarm time.
    NSDate* alarm = self.alarmDate;
    if (alarm == nil) {
        NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *comp = [gregorian components:  (NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[NSDate date]];
        [comp setHour:12];
        [comp setMinute:0];
        [comp setSecond:0];
        alarm = [gregorian dateFromComponents:comp];
    }
    self.alarmTime.date = alarm;
}

- (IBAction)alarmToggleChanged:(id)sender {
    self.alarmTime.enabled = self.alarmToggle.on;
}

- (IBAction)cancelPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)donePressed:(id)sender {
	UIViewController* vc = [self parentViewController];
    if (vc == nil) {
        vc = self.presentingViewController;
    }

    if (vc != nil) {
        // Set the alarm on the parent view controller.
        if ([vc respondsToSelector:@selector(setAlarmDate:)]) {
            if (self.alarmToggle.on) {
                objc_msgSend(vc, sel_getUid("setAlarmDate:"), self.alarmTime.date);
            } else {
                objc_msgSend(vc, sel_getUid("setAlarmDate:"), nil);
            }
        }
        
        // Reload the data table on the parent view controller.
        if ([vc respondsToSelector:@selector(dataTable)]) {
            UITableView* dt = objc_msgSend(vc, sel_getUid("dataTable"));
            [dt reloadData];
        }
    }
    
	[self dismissModalViewControllerAnimated:YES];
}

@end
