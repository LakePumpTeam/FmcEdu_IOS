//
//  NSMutableAttributedString+Append.h
//  Vacation
//
//  Created by Rafael on 15/4/22.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (Append)
/**
 * NSMutableAttributedString扩展
 @param font     对应 NSFontAttributeName属性
 @param color    对应 NSForegroundColorAttributeName属性
 @return
 */
- (void)appendString:(NSString *)string withFont:(UIFont *)font andTextColor:(UIColor *)color;

/**
 * NSMutableAttributedString size计算
 @param size     constrain size
 @param option
 @param context
 @return size
 */
- (CGSize)boundSizeWithSize:(CGSize)size options:(NSStringDrawingOptions)options context:(NSStringDrawingContext *)context NS_AVAILABLE_IOS(6_0);

/**
 * NSMutableAttributedString size计算
 * 默认option为
 *   NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
 @param size     constrain size
 @param context
 @return size
 */
- (CGSize)boundSizeWithSize:(CGSize)size context:(NSStringDrawingContext *)context;

@end
