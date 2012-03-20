//
//  FilterTasksViewController.m
//  TaskManager2
//
//  Created by Peter Chase on 11-05-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterTasksViewController.h"
#import "TaskDAO.h"
#import "CommonUI.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation FilterTasksViewController
@synthesize popover = _popover;
@synthesize dataTable;
@synthesize tags;
@synthesize tagFilter;
@synthesize statusFilter;
@synthesize startedFilter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tagFilter:(NSString*)tag statusFilter:(int)status startFilter:(BOOL)startFilter {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tags = [TaskDAO getAllTags];
        self.tagFilter = tag;
        self.statusFilter = status;
        self.startedFilter = startFilter;
    }
    return self;
}

- (void)dealloc {
    [_popover release];
    [dataTable release];
    [tags release];
    [tagFilter release];
    [super dealloc];
}

- (void)viewDidLoad {
    [CommonUI addToolbarToViewController:self withTitle:@"Task Filter"];
    [super viewDidLoad];
}

- (IBAction)cancelPressed:(id)sender {
    if ([UIDevice currentDevice].model == UIUserInterfaceIdiomPhone ) {
        [self dismissModalViewControllerAnimated:YES];
    }  else {
        [self.popover dismissPopoverAnimated:YES];
    }
}

- (IBAction)donePressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.tagFilter forKey:@"tagFilter"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.statusFilter+1 forKey:@"statusFilter"];
    [[NSUserDefaults standardUserDefaults] setBool:self.startedFilter forKey:@"startedFilter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([UIDevice currentDevice].model == UIUserInterfaceIdiomPhone ) {
        [self dismissModalViewControllerAnimated:YES];
    }  else {
        [self.popover dismissPopoverAnimated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.tags count] + 1;
    } else if (section == 1) {
        return 3;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* reuseIdentifier = @"FilterTaskCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row < [self.tags count]) {
            cell.textLabel.text = [self.tags objectAtIndex:indexPath.row];
            if ([self.tagFilter isEqualToString:(NSString*)[tags objectAtIndex:indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            cell.textLabel.text = @"All";
            if (self.tagFilter == nil) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Not completed";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Completed";
        } else {
            cell.textLabel.text = @"All";
        }
        
        if (indexPath.row == self.statusFilter) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Started Tasks";
            cell.accessoryType = (self.startedFilter) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } else {
            cell.textLabel.text = @"All";
            cell.accessoryType = (self.startedFilter) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        }
    }
    
    return  cell;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSArray* visibleCells = [tableView visibleCells];
    for (UITableViewCell* cell in visibleCells) {
        NSIndexPath* cellIP = [tableView indexPathForCell:cell];
        if (cell != nil && cellIP != nil && indexPath.section == cellIP.section) {
            if (indexPath.row == cellIP.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row < [tags count]) {
            self.tagFilter = [tags objectAtIndex:indexPath.row];
        } else {
            self.tagFilter = nil;
        }
    } else  if (indexPath.section == 1)  {
        self.statusFilter = indexPath.row;
    } else {
        self.startedFilter = (indexPath.row == 0);
    }
    
	return indexPath;
}

@end
