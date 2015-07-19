//
//  ProvResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/11.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"
#import "CityInfo.h"

//输入参数
//filterKey 过滤关键字
//pageSize 每页条数
//pageIndex 页数（从1开始）

@interface ProvResult : SearchNetResult

@property (nonatomic, strong) NSMutableArray *provinces;    // 城市列表
@property (nonatomic, strong) NSNumber *isLastPage;     // 是否是最后一页

@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
