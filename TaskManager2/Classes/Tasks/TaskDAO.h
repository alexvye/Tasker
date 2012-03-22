//
//  TaskDAO.h
//  NewTodos
//
//  Created by Peter Chase on 11-01-22.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"

#define TASK_STATUS_ALL     2


@interface TaskDAO : NSObject {
}

+(void) databaseSetup;

// Single Task methods
+ (Task*)getTask:(int)taskId :(NSString*)systemId;
+ (Task*)getChildTask:(int)taskId parentSystemId:(NSString*)systemId andIndex:(int)index;
+ (Task*)addTask:(Task*)task;
+ (Task*)getFilteredTaskFor:(int)index parentId:(int)parentId parentSystemId:(NSString*)parentSystemId forTag:(NSString*)tagFilter status:(int)statusFilter andStarted:(BOOL)startedFilter;
+ (int)getFilteredTaskCountForParentId:(int)parentId parentSystemId:(NSString*)parentSystemId forTag:(NSString*)tagFilter status:(int)statusFilter andStarted:(BOOL)startedFilter;
+ (void)updateTask:(Task*)task;
+ (void)deleteTask:(int)taskId :(NSString*)systemId;
+ (void)updateTaskStatus:(int)taskId :(NSString*)systemId :(int)status;
+ (void)updateTaskPriority:(int)taskId :(NSString*)systemId :(int)priority;
+ (void)renumberTaskPriorities:(int)parentTaskId :(NSString*)parentSystemId;
+ (void)renumberTaskPrioritiesSubset:(int)parentTaskId :(NSString *)parentSystemId :(int)fromPriority :(int)toPriority :(int)add;
+ (void)taskModified:(int)taskId :(NSString*)systemId :(BOOL)isDeleted;
+ (NSDate*)taskModifiedDate:(int)taskId :(NSString *)systemId;

// Multiple task methods
+ (NSArray*)getAllTasks;
+ (NSArray*)getAllChildTasks:(int)taskId :(NSString*)systemId;
+ (NSArray*)getAllChildTasks:(int)taskId :(NSString*)systemId :(int)status;

// Task's tag methods
+ (NSArray*)getTagsForTask:(int)taskId :(NSString*)systemId;
+ (void)removeTagsForTask:(int)taskId :(NSString*)systemId;
+ (void)updateTagsForTask:(NSArray*)tags :(int)taskId :(NSString*)systemId;
+ (void)addTagToTask:(NSString*)tag :(int)taskId :(NSString*)systemId;
+ (void)removeTagFromTask:(NSString*)tag :(int)taskId :(NSString*)systemId;

// Tag maintenance methods
+(NSArray*) getAllTags;
+(void) addTag:(NSString*) tag;
+(void) removeTag:(NSString*) tag;
+(void) updateTag:(NSString*) newTag :(NSString*) oldTag;
+(BOOL) doesTagExist:(NSString*)tag;
+(int) getTagId:(NSString*)tag;

@end
