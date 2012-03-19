//
//  TagsDataSource.m
//  TaskManager2
//
//  Created by Peter Chase on 12-03-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagsDataSource.h"
#import "TaskDAO.h"

@implementation TagsDataSource
@synthesize tags = _tags;

- (void)dealloc {
    [_tags release];
    [super dealloc];
}

- (void)loadTags {
    if (self.tags == nil) {
        self.tags = [TaskDAO getAllTags];
    }
}

#pragma mark - UITableViewDataSource delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    [self loadTags];
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    [self loadTags];
    [[cell textLabel] setText:(NSString*) [self.tags objectAtIndex:[indexPath row]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self loadTags];
	[TaskDAO removeTag:[self.tags objectAtIndex:indexPath.row]];
    self.tags = nil;
	[tableView reloadData]; 
}

@end
