//
//  TaskDetailResult.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/14.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface TaskDetailResult : SearchNetResult

@property (nonatomic, strong) NSNumber *studentId;
@property (nonatomic, strong) NSNumber *taskId;
@property (nonatomic, strong) NSString *title;
//@property (nonatomic, strong, getter=taskStatus) NSNumber *status;               // (0：查询未完成任务； 1：查询已完成任务)
@property (nonatomic, strong) NSString *task;
@property (nonatomic, strong) NSString *studentName;
@property (nonatomic, strong) NSString *deadline;

@property (nonatomic, strong) NSMutableArray *commentList;
@property (nonatomic, strong) NSNumber *completeStatus;               // (0：查询未完成任务； 1：查询已完成任务)

@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
