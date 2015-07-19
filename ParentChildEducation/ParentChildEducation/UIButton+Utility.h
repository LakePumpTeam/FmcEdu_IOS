//
//  UIButton+Utility.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Utility)

- (id)initWithFont:(UIFont *)initFont andTitle:(NSString *)initTitle andTtitleColor:(UIColor *)titleColor;

// 带圆角、边框
- (id)initWithFont:(UIFont *)initFont andTitle:(NSString *)initTitle andTtitleColor:(UIColor *)titleColor andBorderColor:(UIColor *)borderColor andCornerRadius:(float)cornerRadius;

// 带圆角
- (id)initWithFont:(UIFont *)initFont andTitle:(NSString *)initTitle andTtitleColor:(UIColor *)titleColor andCornerRadius:(float)cornerRadius;

@end
