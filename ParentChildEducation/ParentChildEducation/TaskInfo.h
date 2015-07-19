//
//  TaskInfo.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/1.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskInfo : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *studentId;
@property (nonatomic, strong) NSString *studentName;
@property (nonatomic, strong) NSString *deadline;
@property (nonatomic, strong) NSNumber *completeStatus;               // (0：查询未完成任务； 1：查询已完成任务)

@property (nonatomic, strong) NSNumber *taskId;

@end
