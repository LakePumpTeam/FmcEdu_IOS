//
//  NSObject+Utility.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/3.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

@interface NSObject (Utility)

// 成员变量转换成字典
- (void)serializeSimpleObject:(NSMutableDictionary *)dictionary;

// 自动解析Json
- (void)parseJsonAutomatic:(NSDictionary *)dictionaryJson forInfo:(id)customInfo;

@end
