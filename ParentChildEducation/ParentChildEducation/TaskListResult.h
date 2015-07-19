//
//  TaskListResult.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/1.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface TaskListResult : SearchNetResult

@property (nonatomic, strong) NSMutableArray *taskList;

@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
