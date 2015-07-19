//
//  NSCalendar+Utility.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/13.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "NSCalendar+Utility.h"

@implementation NSCalendar (Utility)

+ (NSCalendar *)defaultCalendar
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    return gregorianCalendar;
}

@end
