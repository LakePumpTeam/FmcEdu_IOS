//
//  UITextField+Utility.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/8.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (Utility)

/*!
 *  设置Placeholder
 *
 *  @param placeholder         文案
 *  @param placeholderColor    颜色
 *  @param placeholderFontSize 字体大小
 */
- (void)setPlaceholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor placeholderFontSize:(UIFont *)placeholderFontSize;

/*!
 *  创建
 *
 *  @param initFrame
 *  @param initFontSize  字体
 *  @param textColor 颜色
 *
 *  @return UITextField
 */
- (id)initWithFrame:(CGRect)initFrame initFontSize:(UIFont *)initFontSize textColor:(UIColor *)textColor;

// 是否可以继续输入
- (BOOL)shouldChangeInRange:(NSRange)range withString:(NSString *)string andLength:(NSInteger)maxLength;

@end
