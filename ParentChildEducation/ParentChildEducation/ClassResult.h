//
//  ClassResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/11.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//接口名：requestClasses

//输入参数
//filterKey 过滤关键字
//cityId  城市id
//pageSize 每页条数
//pageIndex 页数（从1开始）

@interface ClassResult : SearchNetResult

@property (nonatomic, strong) NSMutableArray *classList;    // 学校列表
@property (nonatomic, strong) NSNumber *isLastPage;     // 是否是最后一页

@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
