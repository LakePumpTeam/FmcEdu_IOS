//
//  NSDateFormatter+Unility.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/13.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "NSDateFormatter+Unility.h"

@implementation NSDateFormatter (Unility)

+ (NSDateFormatter *)defaultFormatter
{
    NSDateFormatter *defaultFormatter = [[NSDateFormatter alloc] init];

    NSLocale * gregorianLocale = [[NSLocale alloc] initWithLocaleIdentifier:NSCalendarIdentifierGregorian];
    [defaultFormatter setLocale:gregorianLocale];
    return defaultFormatter;
}

@end
