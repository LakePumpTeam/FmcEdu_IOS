//
//  NSMutableDictionary+Utility.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/9.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "NSMutableDictionary+Utility.h"

@implementation NSMutableDictionary (Utility)

// 设置Key/Value
- (void)setObjectSafe:(id)anObject forKey:(id < NSCopying >)aKey
{
    if(anObject != nil)
    {
        [self setObject:anObject forKey:aKey];
    }
    else
    {
        if ([self objectForKey:aKey])
        {
            [self removeObjectForKey:aKey];
        }
    }
}

@end
