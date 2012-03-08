//
//  ModifyTitleViewController.m
//  TaskManager2
//
//  Created by Peter Chase on 11-03-02.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ModifyTitleViewController.h"
#import "EnterDataCellView.h"
#import "DataManager.h"
#import "CommonUI.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation ModifyTitleViewController
@synthesize dateTable;
@synthesize taskTitle;
@synthesize taskDescription;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil title:(NSString*)aTitle description:(NSString*)aDescription {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		self.taskTitle = aTitle;
		self.taskDescription = aDescription;
    }
    return self;
}

- (void)viewDidLoad {
    [CommonUI addToolbarToViewController:self withTitle:@"Title & Description"];
	[super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)dealloc {
	[dateTable release];
	[taskTitle release];
	[taskDescription release];
    [super dealloc];
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
        NSArray* cells = [self.dateTable visibleCells];
        for (EnterDataCellView* cell in cells) {
            if ([cell.dataField.placeholder isEqualToString:@"Title"]) {
                if ([vc respondsToSelector:@selector(task)]) {
                    Task* task = objc_msgSend(vc, sel_getUid("task"));
                    task.title = cell.dataField.text;
                }
            } else {
                if ([vc respondsToSelector:@selector(task)]) {
                    Task* task = objc_msgSend(vc, sel_getUid("task"));
                    task.description = cell.dataField.text;
                }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
	if (cell == nil) {
		CGRect frame;
		frame.origin.x = 0;
		frame.origin.y = 0;
		frame.size.height = 50;
		frame.size.width = 320;
		if (indexPath.row == 0) {
			cell = [[EnterDataCellView alloc] initWithFrame:frame type:@"Title" value:self.taskTitle];
			[[(EnterDataCellView*)cell dataField] becomeFirstResponder];
		} else {
			cell = [[EnterDataCellView alloc] initWithFrame:frame type:@"Description" value:self.taskDescription];
		}
	}

	return cell;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {

	return indexPath;
}


@end
