//
//  UILabel+Utility.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Utility)

// 创建Label
- (id)initWithFont:(UIFont *)initFont andText:(NSString *)initText andColor:(UIColor *)textColor;

- (id)initWithFont:(UIFont *)initFont andText:(NSString *)initText andColor:(UIColor *)textColor withTag:(NSInteger)initTag;

- (id)initRedStart:(UIFont *)initFont;

@end
