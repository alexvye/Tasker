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
@synthesize dataTable;
@synthesize tags;
@synthesize tagFilter;
@synthesize statusFilter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tagFilter:(NSString*)tag statusFilter:(int)status {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tags = [TaskDAO getAllTags];
        self.tagFilter = tag;
        self.statusFilter = status;
    }
    return self;
}

- (void)dealloc {
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
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)donePressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:self.tagFilter forKey:@"tagFilter"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.statusFilter+1 forKey:@"statusFilter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
	[self dismissModalViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.tags count] + 1;
    } else {
        return 3;
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
    } else {
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
    } else {
        self.statusFilter = indexPath.row;
    }
    
	return indexPath;
}

@end
