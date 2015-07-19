//
//  BusinessSearchNetResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/15.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface BusinessSearchNetResult : SearchNetResult

@property (nonatomic, strong) NSNumber *isSuccess;   // (1:成功 其他不成功）
@property (nonatomic, strong) NSString *businessMsg;

@end
