//
//  TaskDAO.m
//  NewTodos
//
//  Created by Peter Chase on 11-01-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TaskDAO.h"
#import <sqlite3.h>
#import "TaskAlarm.h"

static NSString* fileName = nil;

@interface TaskDAO ()

+ (void)setPriority:(Task*)task;
+ (NSString*)getDBPath;
+ (NSString*)getDateString:(NSDate*)date;
+ (NSDate*)getDateFromString:(NSString*)date;
+ (NSDate*)getEndOfDay;
+ (int)getNextTaskId:(NSString*)systemId;
+ (Task*)getTaskFromStatement:(sqlite3_stmt*)statement :(int)taskId :(NSString*)systemId;

@end


@implementation TaskDAO

#pragma mark - Private Methods

/**
 * Sets the priority to 0 and updates all current priorites.
 */
+ (void)setPriority:(Task*)task {
    task.priority = 0;
    NSArray* taskList = [[[TaskDAO getAllChildTasks:task.parentId :task.parentSystemId] mutableCopy] autorelease];
    for (int i = 0; i < [taskList count]; i++) {
        Task* tmpTask = [taskList objectAtIndex:i];
        tmpTask.priority = i+1;
        [TaskDAO updateTask:tmpTask];
    }
}

/**
 * This method is used to get the path to the database file.
 */
+ (NSString*)getDBPath {
	if (fileName == nil) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentDirectory = [paths objectAtIndex:0];
		fileName = [[documentDirectory stringByAppendingPathComponent:@"tasks.sqlite"] retain];
	}
	
	return fileName;
}

/**
 * This method is used to convert a date to a string.
 */
+ (NSString*)getDateString:(NSDate*)date {
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"yyyy-MM-dd HH:mm"];	
	return [format stringFromDate:date];
}

/** 
 * This method is used to convert a string to a date.
 */
+ (NSDate*)getDateFromString:(NSString*)date {
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"yyyy-MM-dd HH:mm"];	
	return [format dateFromString:date];
}

/**
 * This method is used to return the end of the current date.
 */
+ (NSDate*)getEndOfDay {
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *comp = [gregorian components:  (NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit) fromDate:[NSDate date]];
    [comp setHour:23];
    [comp setMinute:59];
    [comp setSecond:59];
    return [gregorian dateFromComponents:comp];
}

/** 
 * This method is used to get the next task id to save to the database.
 */
+ (int)getNextTaskId:(NSString*)systemId {
	int maxTaskId = 0;
	
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSString* sql = @"SELECT MAX(task_id) FROM task WHERE system_id = ?;";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Get the task id.
	sqlite3_bind_text(statement, 1, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) == SQLITE_ROW) {
		maxTaskId = sqlite3_column_int(statement, 0);
	}
	sqlite3_finalize(statement);
	
	sql = @"SELECT MAX(task_id) FROM task_update WHERE system_id = ?;";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Get the task id.
	sqlite3_bind_text(statement, 1, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) == SQLITE_ROW) {
		int newMaxTaskId = sqlite3_column_int(statement, 0);
		maxTaskId = (newMaxTaskId > maxTaskId) ? newMaxTaskId : maxTaskId;
	}
	sqlite3_finalize(statement);
    sqlite3_close(database);
	
	return maxTaskId + 1;
}

/**
 * This method is used to get the task object from the sql statement.
 */
+ (Task*)getTaskFromStatement:(sqlite3_stmt*)statement :(int)taskId :(NSString*)systemId {
	Task* task = [[[Task alloc] init] autorelease];
	
	task.taskId = taskId;
	task.systemId = systemId;
	task.parentId = sqlite3_column_int(statement, 2);
	char* parentSystemId = (char*)sqlite3_column_text(statement, 3);
	task.parentSystemId = [NSString stringWithUTF8String:(parentSystemId == nil) ? "" : parentSystemId];
	task.title = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 4)];
	char* description = (char*)sqlite3_column_text(statement, 5);
	task.description = [NSString stringWithUTF8String:(description == nil) ? "" : description];
	task.startDate = [TaskDAO getDateFromString:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 6)]];
	task.endDate = [TaskDAO getDateFromString:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 7)]];
	task.priority = sqlite3_column_int(statement, 8);
	task.status = sqlite3_column_int(statement, 9);
	task.recurranceType = (RecurranceType)sqlite3_column_int(statement, 10);
	task.recurranceValue = sqlite3_column_int(statement, 11);
	task.tags = [TaskDAO getTagsForTask:taskId :systemId];
	
	return task;
}

#pragma mark - Setup Methods

/**
 * This method is used to setup the database.
 */
+(void) databaseSetup{
	NSError *error;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:[TaskDAO getDBPath]]) {
		NSString *fileLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"tasks.sqlite"];
		if (![fileManager copyItemAtPath:fileLocation toPath:[TaskDAO getDBPath] error:&error]) {
			NSAssert1(0, @"Error creating database file: '%@'", [error localizedDescription]);
		}
        
        [TaskDAO addTag:@"Household"];
        [TaskDAO addTag:@"Family"];
        [TaskDAO addTag:@"Financial"];
        [TaskDAO addTag:@"Work"];
	}
}

#pragma mark - Single Task Methods

/**
 * This method is used to return a task for the passed in task ID.
 */
+(Task*) getTask:(int) taskId :(NSString*) systemId {
	Task* task = nil;

	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSString* sql = @"SELECT task_id, system_id, parent_task_id, parent_system_id, "
	                 "title, description, start_date, end_date, priority_id, status_id, "
	                 "recurrance_type, recurrance_value "
	                 "FROM task WHERE task.task_id = ? AND task.system_id = ?;";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Get the task.
	sqlite3_bind_int(statement, 1, taskId);
	sqlite3_bind_text(statement, 2, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) == SQLITE_ROW) {
		task = [TaskDAO getTaskFromStatement:statement :taskId :systemId];
	}
	sqlite3_finalize(statement);
    sqlite3_close(database);
	
	return task;
}

/**
 * This method is used to return a child task at the passed in index.
 */
+ (Task*)getChildTask:(int)taskId parentSystemId:(NSString*)systemId andIndex:(int)index {
    return nil;
}

// Returns a filter task at the passed in index
+ (Task*)getFilteredTaskFor:(int)index parentId:(int)parentId parentSystemId:(NSString*)parentSystemId forTag:(NSString*)tagFilter status:(int)statusFilter andStarted:(BOOL)startedFilter  {
    int tagId = [TaskDAO getTagId:tagFilter];

    // Open the database.
    sqlite3* database;
    if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
        NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
    }
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSMutableString* sql = [NSMutableString stringWithString:
                            @"SELECT task.task_id, task.system_id, task.parent_task_id, task.parent_system_id, "
                            "task.title, task.description, task.start_date, task.end_date, task.priority_id, task.status_id, "
                            "task.recurrance_type, task.recurrance_value FROM task "];
    if (tagId != -1) {
        [sql appendString:@", tag_link "];
    }
    [sql appendString:@"WHERE task.parent_task_id = ? " ];
    if (parentSystemId != nil) {
        [sql appendString:@"AND task.parent_system_id = ? "];
    }
    if (tagId != -1) {
        [sql appendString:@"AND tag_link.task_id = task.task_id AND tag_link.system_id = task.system_id AND tag_link.tag_id = ? "];
    }
    if (statusFilter != 2) {
        [sql appendString:@"AND task.status_id = ? "];
    }
    if (startedFilter) {
        [sql appendString:@"AND task.start_date <= ? "];
    }
	[sql appendString:@"ORDER BY task.priority_id "];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}

    int idx = 1;
    sqlite3_bind_int(statement, idx++, parentId);
    if (parentSystemId != nil) {
        sqlite3_bind_text(statement, idx++, [parentSystemId UTF8String], -1, SQLITE_TRANSIENT);
    }
    if (tagId != -1) {
        sqlite3_bind_int(statement, idx++, tagId);
    }
    if (statusFilter != 2) {
        sqlite3_bind_int(statement, idx++, statusFilter);
    }
    if (startedFilter) {
		sqlite3_bind_text(statement, idx++, [[TaskDAO getDateString:[TaskDAO getEndOfDay]] UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    Task* task = nil;
    for (int i = 0; i < index && sqlite3_step(statement) == SQLITE_ROW; i++) {
        // No OP iterate through.
    }
    if (sqlite3_step(statement) == SQLITE_ROW) {
        int taskId = sqlite3_column_int(statement, 0);
        NSString* systemId = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 1)];;
        task = [TaskDAO getTaskFromStatement:statement :taskId :systemId];
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return task;   
}

+ (int)getFilteredTaskCountForParentId:(int)parentId parentSystemId:(NSString*)parentSystemId forTag:(NSString*)tagFilter status:(int)statusFilter andStarted:(BOOL)startedFilter {
    int tagId = [TaskDAO getTagId:tagFilter];
    
    // Open the database.
    sqlite3* database;
    if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
        NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
    }
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSMutableString* sql = [NSMutableString stringWithString:
                            @"SELECT count(*) FROM task "];
    if (tagId != -1) {
        [sql appendString:@", tag_link "];
    }
    [sql appendString:@"WHERE task.parent_task_id = ? " ];
    if (parentSystemId != nil) {
        [sql appendString:@"AND task.parent_system_id = ? "];
    }
    if (tagId != -1) {
        [sql appendString:@"AND tag_link.task_id = task.task_id AND tag_link.system_id = task.system_id AND tag_link.tag_id = ? "];
    }
    if (statusFilter != 2) {
        [sql appendString:@"AND task.status_id = ? "];
    }
    if (startedFilter) {
        [sql appendString:@"AND task.start_date <= ? "];
    }
	[sql appendString:@"ORDER BY task.priority_id "];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
    
    int idx = 1;
    sqlite3_bind_int(statement, idx++, parentId);
    if (parentSystemId != nil) {
        sqlite3_bind_text(statement, idx++, [parentSystemId UTF8String], -1, SQLITE_TRANSIENT);
    }
    if (tagId != -1) {
        sqlite3_bind_int(statement, idx++, tagId);
    }
    if (statusFilter != 2) {
        sqlite3_bind_int(statement, idx++, statusFilter);
    }
    if (startedFilter) {
		sqlite3_bind_text(statement, idx++, [[TaskDAO getDateString:[TaskDAO getEndOfDay]] UTF8String], -1, SQLITE_TRANSIENT);
    }
   
    int count = 0;
    if (sqlite3_step(statement) == SQLITE_ROW) {
        count= sqlite3_column_int(statement, 0);
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return count; 
}

/**
 * This method is used to add a task to the database.
 */
+(Task*) addTask:(Task*) task {
	if (task != nil) {
        [TaskDAO setPriority:task];
        
		// Open the database.
		sqlite3* database;
		if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
			NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
		}
					  
		// Create the statement.
		sqlite3_stmt* statement;
		NSString* sql = @"INSERT INTO task (task_id, system_id, parent_task_id, parent_system_id, "
		                 "title, description, start_date, end_date, priority_id, status_id, recurrance_type, recurrance_value) "
		                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
			NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
		}
		
		// Get next task id.
		[task setTaskId:[TaskDAO getNextTaskId:[task systemId]]];
	
		// Add the task.
		sqlite3_bind_int(statement, 1, task.taskId);
		sqlite3_bind_text(statement, 2, [task.systemId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(statement, 3, task.parentId);
		sqlite3_bind_text(statement, 4, [task.parentSystemId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 5, [task.title UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 6, [task.description UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 7, [[TaskDAO getDateString:task.startDate] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 8, [[TaskDAO getDateString:task.endDate] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(statement, 9, task.priority);
		sqlite3_bind_int(statement, 10, task.status);
		sqlite3_bind_int(statement, 11, (int)task.recurranceType);
		sqlite3_bind_int(statement, 12, task.recurranceValue);
		if (sqlite3_step(statement) != SQLITE_DONE) {
			NSAssert1(0, @"Error adding to database: '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(statement);
		
		// Close the database.
		sqlite3_close(database);
		
		if (task.tags != nil) {
			[TaskDAO updateTagsForTask:task.tags :task.taskId :task.systemId];
		}
		
		[TaskDAO taskModified:task.taskId :task.systemId :NO];
	}
	
	return task;
}

/**
 * This method is used to update the task to the database.
 */
+(void) updateTask:(Task*) task {
	if (task != nil) {
		// Open the database.
		sqlite3* database;
		if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
			NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
		}

		// Create the statement.
		sqlite3_stmt* statement;
		NSString* sql = @"UPDATE task SET parent_task_id = ?, parent_system_id = ?, "
		                 "title = ?, description = ?, start_date = ?, end_date = ?, "
		                 "priority_id = ?, status_id = ?, recurrance_type = ?, recurrance_value = ? "
		                 "WHERE task_id = ? AND system_id = ?;";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
			NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
		}
		
		// Update the task.
		sqlite3_bind_int(statement, 1, task.parentId);
		sqlite3_bind_text(statement, 2, [task.parentSystemId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 3, [task.title UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 4, [task.description UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 5, [[TaskDAO getDateString:task.startDate] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 6, [[TaskDAO getDateString:task.endDate] UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(statement, 7, task.priority);
		sqlite3_bind_int(statement, 8, task.status);		
		sqlite3_bind_int(statement, 9, (int)task.recurranceType);
		sqlite3_bind_int(statement, 10, task.recurranceValue);
		sqlite3_bind_int(statement, 11, task.taskId);
		sqlite3_bind_text(statement, 12, [task.systemId UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) != SQLITE_DONE) {
			NSAssert1(0, @"Error updating the database: '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(statement);
		
		// Close the database.
		sqlite3_close(database);
		
		if (task.tags != nil) {
			[TaskDAO updateTagsForTask:task.tags :task.taskId :task.systemId];
		}
		
		[TaskDAO taskModified:task.taskId :task.systemId :NO];
	}
}

/**
 * This method is used to delete a task from the database.
 */
+(void) deleteTask:(int) taskId :(NSString*) systemId {
    // Remove all child tasks
    NSArray* childTasks = [TaskDAO getAllChildTasks:taskId :systemId];
    if (childTasks != nil) {
        for (Task* task in childTasks) {
            [TaskDAO deleteTask:task.taskId :task.systemId];
        }
    }
    
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSString* sql = @"DELETE FROM task WHERE task_id = ? AND system_id = ?";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Delete the task.
	sqlite3_bind_int(statement, 1, taskId);
	sqlite3_bind_text(statement, 2, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) != SQLITE_DONE) {
		NSAssert1(0, @"Error deleting the database: '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(statement);
	
	// Close the database.
	sqlite3_close(database);
	
	[TaskDAO removeTagsForTask:taskId :systemId];
	[TaskDAO taskModified:taskId :systemId :YES];
    TaskAlarm* alarm = [[[TaskAlarm alloc] init] autorelease];
    alarm.taskId = taskId;
    alarm.systemId = systemId;
    [TaskAlarm removeTaskAlarm:alarm];
}

/**
 * This method is used to set a new task's status.
 */
+(void) updateTaskStatus:(int)taskId :(NSString*)systemId :(int)status {
	Task* task = [TaskDAO getTask:taskId :systemId];
	if (task != nil) {
		task.status = status;
		[TaskDAO updateTask:task];
	}
}

/**
 * This method is used to set a new task's priority.
 */
+(void) updateTaskPriority:(int)taskId :(NSString*)systemId :(int)priority {
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}

    sqlite3_stmt* statement;
    NSString* sql = @"UPDATE task SET priority_id = ? "
                     "WHERE task_id = ? AND system_id = ?";
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
        NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_bind_int(statement, 1, priority);
    sqlite3_bind_int(statement, 2, taskId);
    sqlite3_bind_text(statement, 3, [systemId UTF8String], -1, SQLITE_TRANSIENT);
    
    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSAssert1(0, @"Error updating the database: '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
/*    
	Task* task = [TaskDAO getTask:taskId :systemId];
	if (task != nil) {
		task.priority = priority;
		[TaskDAO updateTask:task];
	}
 */
}

/**
 * This method is used to renumber the priorites for a task id and system id.
 */
+ (void)renumberTaskPriorities:(int)parentTaskId :(NSString*)parentSystemId {
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSMutableString* sql = [NSMutableString stringWithString:@"SELECT task.task_id, task.system_id FROM task "
                    "WHERE task.parent_task_id = ? "];
    if (parentSystemId != nil) {
        [sql appendString:@"AND task.parent_system_id = ? "];
    }
    [sql appendString:@"ORDER BY task.priority_id;"];

	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}

    sqlite3_bind_int(statement, 1, parentTaskId);
    if (parentSystemId != nil) {
        sqlite3_bind_text(statement, 2, [parentSystemId UTF8String], -1, SQLITE_TRANSIENT);
    }
    
    NSString* sql2 = @"UPDATE task SET priority_id = ? "
                     "WHERE task_id = ? AND system_id = ?";
    for (int i = 1; (sqlite3_step(statement) == SQLITE_ROW); i++) {
        int taskId = sqlite3_column_int(statement, 0);
        NSString* systemId = [NSString stringWithUTF8String:(char*)sqlite3_column_text(statement,1)];

        sqlite3_stmt* statement2;
        if (sqlite3_prepare_v2(database, [sql2 UTF8String], -1, &statement2, nil) != SQLITE_OK) {
            NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
        }
  
        sqlite3_bind_int(statement2, 1, i);
        sqlite3_bind_int(statement2, 2, taskId);
        sqlite3_bind_text(statement2, 3, [systemId UTF8String], -1, SQLITE_TRANSIENT);
        
        if (sqlite3_step(statement2) != SQLITE_DONE) {
            NSAssert1(0, @"Error updating the database: '%s'.", sqlite3_errmsg(database));
        }
       
        sqlite3_finalize(statement2);        
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
}

/**
 * This method is used to renumber the priorities of a subset of tasks.
 */
+ (void)renumberTaskPrioritiesSubset:(int)parentTaskId :(NSString *)parentSystemId :(int)fromPriority :(int)toPriority :(int)add {
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
    NSMutableString* sql = [NSMutableString stringWithString:
        @"UPDATE task SET priority_id = priority_id + ?  WHERE parent_task_id = ? " ];
    if (parentSystemId) {
        [sql appendString:@"AND parent_system_id = ? "];
    }
    [sql appendString:@"AND priority_id >= ? AND priority_id <= ?;"];
    
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
    
    int i = 1;
    sqlite3_bind_int(statement, i++, add);
    sqlite3_bind_int(statement, i++, parentTaskId);
    if (parentSystemId) {
        sqlite3_bind_text(statement, i++, [parentSystemId UTF8String], -1, SQLITE_TRANSIENT);
    }
    sqlite3_bind_int(statement, i++, fromPriority);
    sqlite3_bind_int(statement, i++, toPriority);

    if (sqlite3_step(statement) != SQLITE_DONE) {
        NSAssert1(0, @"Error updating the database: '%s'.", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
}

/**
 * This method is used to save that a task has been modified.
 */
+(void) taskModified:(int)taskId :(NSString*)systemId :(BOOL)isDeleted {
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSString* sql = @"DELETE FROM task_update WHERE task_id = ? AND system_id = ?";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Delete the task update record if it exists.
	sqlite3_bind_int(statement, 1, taskId);
	sqlite3_bind_text(statement, 2, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) != SQLITE_DONE) {
		NSAssert1(0, @"Error deleting the database: '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(statement);
	
	sqlite3_stmt* statement2;
	sql = @"INSERT INTO task_update (task_id, system_id, deleted_flag, date_updated) VALUES (?, ?, ?, ?);";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement2, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Insert the task update record.
	sqlite3_bind_int(statement2, 1, taskId);
	sqlite3_bind_text(statement2, 2, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(statement2, 3, isDeleted);
	sqlite3_bind_text(statement2, 4, [[TaskDAO getDateString:[NSDate date]] UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement2) != SQLITE_DONE) {
		NSAssert1(0, @"Error inserting into the database: '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(statement2);
	
	// Close the database.
	sqlite3_close(database);
}

/**
 * This method is used to get the date that the task was last modified.
 */
+(NSDate*) taskModifiedDate:(int)taskId :(NSString *)systemId {
	NSDate* date = nil;
	
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSString* sql = @"SELECT date_updated FROM task_update "
		"WHERE task_id = ? AND system_id = ?;";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Get the task.
	sqlite3_bind_int(statement, 1, taskId);
	sqlite3_bind_text(statement, 2, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) == SQLITE_ROW) {
		date = [TaskDAO getDateFromString:[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, 0)]];
	}
	sqlite3_finalize(statement);
    sqlite3_close(database);
	
	return date;
}

#pragma mark - Multiple Task Methods

/**
 * This method is used to return all tasks.
 */
+(NSArray*) getAllTasks {
	return [TaskDAO getAllChildTasks:NO_PARENT :nil];
}

/*
 * This method is used to return all the child tasks for a task.
 */
+(NSArray*) getAllChildTasks:(int)taskId :(NSString*)systemId {
	return [TaskDAO getAllChildTasks:taskId :systemId :NO_PARENT];
}	

/*
 * This method is used to return all the child tasks for a task with a specifix status.
 */
+(NSArray*) getAllChildTasks:(int)taskId :(NSString*)systemId :(int)status {	
	NSMutableArray* tasks = [[[NSMutableArray alloc] init] autorelease];
	
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSMutableString* sql = [[@"SELECT task_id, system_id, parent_task_id, parent_system_id, "
	"title, description, start_date, end_date, priority_id, status_id, "
	"recurrance_type, recurrance_value "
	"FROM task WHERE parent_task_id = ? " mutableCopy] autorelease];
	if (systemId != nil) {
		[sql appendString:@"AND parent_system_id = ? "];
	}
	if (status != -1) {
		[sql appendString:@"AND status_id = ? "];
	}
	[sql appendString:@"ORDER BY priority_id "];
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Get all the tasks.
	int index = 1;
	sqlite3_bind_int(statement, index++, taskId);
	if (systemId != nil) {
		sqlite3_bind_text(statement, index++, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	}
	if (status != -1) {
		sqlite3_bind_int(statement, index++, status);
	}
	while (sqlite3_step(statement) == SQLITE_ROW) {
		int taskId = sqlite3_column_int(statement, 0);
		NSString* systemId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
		
		Task* task = [TaskDAO getTaskFromStatement:statement :taskId :systemId];
		[tasks addObject:task];
	}
	sqlite3_finalize(statement);
    sqlite3_close(database);
	
	return tasks;
}

#pragma mark - Task's Tag Methods

/**
 * This method is used to return all the tags for a specific task.
 */
+(NSArray*) getTagsForTask:(int) taskId :(NSString*) systemId {
	NSMutableArray* tags = [[[NSMutableArray alloc] init] autorelease];
	
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSString* sql = @"SELECT tag.tag_desc FROM tag, tag_link "
    	             "WHERE tag_link.task_id = ? AND tag_link.system_id = ? "
					 "AND tag_link.tag_id = tag.tag_id";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Get all the tags for the task.
	sqlite3_bind_int(statement, 1, taskId);
	sqlite3_bind_text(statement, 2, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	while (sqlite3_step(statement) == SQLITE_ROW) {
		NSString* tag = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		[tags addObject:tag];
	}
	sqlite3_finalize(statement);
    sqlite3_close(database);
	
	return tags;
}

/**
 * This method removes all the task's tags.
 */
+(void) removeTagsForTask:(int) taskId :(NSString*) systemId {
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSString* sql = @"DELETE FROM tag_link "
	"WHERE task_id = ? AND system_id = ?;";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Remove the tag.
	sqlite3_bind_int(statement, 1, taskId);
	sqlite3_bind_text(statement, 2, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) != SQLITE_DONE) {
		NSAssert1(0, @"Error adding to database: '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(statement);
	
	// Close the database.
	sqlite3_close(database);
}

/**
 * This method removes all of a task's tags and add the passed in ones.
 */
+(void) updateTagsForTask:(NSArray*) tags :(int) taskId :(NSString*) systemId {
	[TaskDAO removeTagsForTask:taskId :systemId];
	
	for (int i = 0; i < [tags count]; i++) {
		NSString* tag = (NSString*) [tags objectAtIndex:i];
		[TaskDAO addTagToTask:tag :taskId :systemId];
	}
}

/**
 * This methos is used to add a tag to a task.
 */
+(void) addTagToTask:(NSString*) tag :(int) taskId :(NSString*) systemId {
	// If tag does not exist add it.
	if ([TaskDAO doesTagExist:tag] == NO) {
		[TaskDAO addTag:tag];
	}
	
	if (tag != nil) {
		// Open the database.
		sqlite3* database;
		if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
			NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
		}
		
		// Create the statement.
		sqlite3_stmt* statement;
		NSString* sql = @"INSERT INTO tag_link (task_id, system_id, tag_id) "
		"VALUES (?, ?, (SELECT tag_id FROM tag WHERE tag_desc = ?));";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
			NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
		}
		
		// Add the tag.
		sqlite3_bind_int(statement, 1, taskId);
		sqlite3_bind_text(statement, 2, [systemId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 3, [tag UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) != SQLITE_DONE) {
			NSAssert1(0, @"Error adding to database: '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(statement);		
		
		// Close the database.
		sqlite3_close(database);
	}
}

+(void) removeTagFromTask:(NSString*) tag :(int) taskId :(NSString*) systemId {
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSString* sql = @"DELETE FROM tag_link "
					"WHERE task_id = ? AND system_id = ? AND tag_id = (SELECT tag_id FROM tag WHERE tag_desc = ?);";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Remove the tag.
	sqlite3_bind_int(statement, 1, taskId);
	sqlite3_bind_text(statement, 2, [systemId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(statement, 3, [tag UTF8String], -1, SQLITE_TRANSIENT);
	if (sqlite3_step(statement) != SQLITE_DONE) {
		NSAssert1(0, @"Error adding to database: '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(statement);
	
	// Close the database.
	sqlite3_close(database);
}

#pragma mark - Tag Maintenance Methods

/**
 * This method is used to return all the tags.
 */
+(NSArray*) getAllTags {
	NSMutableArray* tags = [[[NSMutableArray alloc] init] autorelease];
	
	// Open the database.
	sqlite3* database;
	if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
		NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
	}
	
	// Create the statement.
	sqlite3_stmt* statement;
	NSString* sql = @"SELECT tag_desc FROM tag";
	if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
		NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
	}
	
	// Get all the tags.
	while (sqlite3_step(statement) == SQLITE_ROW) {
		NSString* tag = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		[tags addObject:tag];
	}
	sqlite3_finalize(statement);
    sqlite3_close(database);
	
	return tags;
}

/**
 * This method is used to add a tag to the database.
 */
+(void) addTag:(NSString*) tag {
	if (tag != nil && ![TaskDAO doesTagExist:tag]) {
		// Open the database.
		sqlite3* database;
		if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
			NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
		}
		
		// Create the statement.
		sqlite3_stmt* statement;
		NSString* sql = @"INSERT INTO tag (tag_id, tag_desc) "
		"VALUES ((SELECT MAX(tag_id) FROM tag) + 1, ?);";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
			NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
		}
		
		// Add the tag.
		sqlite3_bind_text(statement, 1, [tag UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) != SQLITE_DONE) {
			NSAssert1(0, @"Error adding to database: '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(statement);

		// Close the database.
		sqlite3_close(database);
	}
}

/**
 * This method is used to remove a tag from the database. It removes all entries for the tag in the link table.
 */
+(void) removeTag:(NSString*) tag {
	if (tag != nil) {
		// Open the database.
		sqlite3* database;
		if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
			NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
		}
		
		// Create the statement.
		sqlite3_stmt* statement;
		NSString* sql = @"DELETE FROM tag_link WHERE tag_id = (SELECT tag_id FROM tag WHERE tag_desc = ?);";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
			NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
		}
		
		// Add the tag.
		sqlite3_bind_text(statement, 1, [tag UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) != SQLITE_DONE) {
			NSAssert1(0, @"Error removing to database: '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(statement);
		
		// Create the statement.
		sql = @"DELETE FROM tag WHERE tag_desc = ?;";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
			NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
		}
		
		// Add the tag.
		sqlite3_bind_text(statement, 1, [tag UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) != SQLITE_DONE) {
			NSAssert1(0, @"Error removing to database: '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(statement);
		
		// Close the database.
		sqlite3_close(database);
	}
}

/**
 * This tag is used to update the description of a tag in the database.
 */
+(void) updateTag:(NSString*) newTag :(NSString*) oldTag {
	if (newTag != nil && oldTag != nil) {
        if ([newTag isEqualToString:oldTag]) {
            return;
        }
        
		if ([TaskDAO doesTagExist:newTag]) {
			[TaskDAO removeTag:oldTag];
			return;
		}
		
		// Open the database.
		sqlite3* database;
		if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
			NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
		}
		
		// Create the statement.
		sqlite3_stmt* statement;
		NSString* sql = @"UPDATE tag SET tag_desc = ? WHERE tag_desc = ?;";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
			NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
		}
		
		// Add the tag.
		sqlite3_bind_text(statement, 1, [newTag UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 2, [oldTag UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) != SQLITE_DONE) {
			NSAssert1(0, @"Error adding to database: '%s'.", sqlite3_errmsg(database));
		}
		sqlite3_finalize(statement);
		
		
		// Close the database.
		sqlite3_close(database);
	}
}

/**
 * This method is used to find out if a specified tag exists.
 */
+(BOOL) doesTagExist:(NSString*)tag {
	BOOL response = NO;
	if (tag != nil) {
		// Open the database.
		sqlite3* database;
		if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
			NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
		}
		
		// Create the statement.
		sqlite3_stmt* statement;
		NSString* sql = @"SELECT tag_id FROM tag WHERE UPPER(tag_desc) = ?";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
			NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
		}
		
		// Find out if the tag exists
		sqlite3_bind_text(statement, 1, [[tag uppercaseString] UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			response = YES;
		}
		sqlite3_finalize(statement);
		
		// Close the database.
		sqlite3_close(database);
	}
	return response;
}

/**
 * This methods returns the tag id.
 */
+(int) getTagId:(NSString*)tag {
    int response = -1;
    if (tag != nil) {
		// Open the database.
		sqlite3* database;
		if (sqlite3_open([[TaskDAO getDBPath] UTF8String], &database) != SQLITE_OK) {
			NSAssert1(0, @"Error opening the database: '%s'.", sqlite3_errmsg(database));
		}
		
		// Create the statement.
		sqlite3_stmt* statement;
		NSString* sql = @"SELECT tag_id FROM tag WHERE UPPER(tag_desc) = ?";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, nil) != SQLITE_OK) {
			NSAssert1(0, @"Error creating database statement: '%s'.", sqlite3_errmsg(database));
		}
		
		// Find out if the tag exists
		sqlite3_bind_text(statement, 1, [[tag uppercaseString] UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) == SQLITE_ROW) {
            response = sqlite3_column_int(statement, 0);
		}
		sqlite3_finalize(statement);
		
		// Close the database.
		sqlite3_close(database);
    }
    return response;
}

@end
