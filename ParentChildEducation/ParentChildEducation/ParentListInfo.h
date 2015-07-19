//
//  ParentListInfo.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/15.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParentListInfo : NSObject

@property (nonatomic, strong, getter = cityId) NSNumber *parentId;
@property (nonatomic, strong, getter = cellPhone) NSString *cellPhone;
@property (nonatomic, strong, getter = parentName) NSString *parentName;
@property (nonatomic, strong) NSString *auditStatus; // 审核状态（1 已审核通过 0 待审核 2 已拒绝）

@end
