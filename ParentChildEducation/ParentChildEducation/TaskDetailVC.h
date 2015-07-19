//
//  TaskDetailVC.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/14.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "BaseNameVC.h"

@interface TaskDetailVC : BaseNameVC

@property (nonatomic, strong) NSNumber *taskId;         // 任务id
@property (nonatomic, strong) NSNumber *studentId;
@property (nonatomic, assign) BOOL completeStatus;

@end
