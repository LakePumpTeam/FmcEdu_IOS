//
//  UIColor+Utility.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utility)

+ (UIColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithARGB:(NSInteger)ARGBValue;

@end
