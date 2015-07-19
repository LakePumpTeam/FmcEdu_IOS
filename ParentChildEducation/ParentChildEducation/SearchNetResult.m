//
//  SearchNetResult.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"
#import "NSObject+Utility.h"

@implementation SearchNetResult

// 解析所有数据
- (void)parseAllNetResult:(NSDictionary *)jsonDictionary forInfo:(id)customInfo
{
    // 业务数据
    NSDictionary *dictionaryData = [jsonDictionary objectForKey:@"data"];
    
    if(dictionaryData != nil && [dictionaryData isKindOfClass:[NSDictionary class]])
    {
        // 解析简单数据
        [self parseNetResult:dictionaryData forInfo:customInfo];
    }
    
    _status = [jsonDictionary objectForKey:@"status"];
    _msg = [jsonDictionary objectForKey:@"msg"];
    
}

// 解析业务数据
- (void)parseNetResult:(NSDictionary *)jsonDictionary forInfo:(id)customInfo
{
    // 开始自动化解析
    [self parseJsonAutomatic:jsonDictionary forInfo:customInfo];
}

@end
