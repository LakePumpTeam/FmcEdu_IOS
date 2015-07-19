//
//  ParentsListResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/15.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface ParentsListResult : SearchNetResult

@property (nonatomic, strong) NSMutableArray *parentsAuditList;     // 城市列表
@property (nonatomic, strong) NSNumber *isLastPage;                 // 是否是最后一页

@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
