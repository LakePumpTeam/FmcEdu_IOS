//
//  BBSNewsListResult.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface BBSNewsListResult : SearchNetResult

@property (nonatomic, strong) NSMutableArray *newsList;

@property (nonatomic, strong) NSNumber *isSuccess;              // (1:成功 其他不成功）
@property (nonatomic, strong) NSString *businessMsg;

@end
