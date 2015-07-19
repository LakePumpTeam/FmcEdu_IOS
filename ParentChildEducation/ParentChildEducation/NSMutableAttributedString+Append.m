//
//  NSMutableAttributedString+Append.m
//  Vacation
//
//  Created by Rafael on 15/4/22.
//  Copyright (c) 2015年 Qunar.com. All rights reserved.
//

#import "NSMutableAttributedString+Append.h"

@implementation NSMutableAttributedString (Append)

- (void)appendString:(NSString *)string withFont:(UIFont *)font andTextColor:(UIColor *)color
{
    if (![string isStringSafe]) {
        return;
    }
    NSMutableAttributedString *tmpAttStr = [[NSMutableAttributedString alloc] initWithString:string];
    if (font != nil) {
        [tmpAttStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    }
    if (color != nil) {
        [tmpAttStr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, string.length)];
    }
    [self appendAttributedString:tmpAttStr.copy];
}

- (CGSize)boundSizeWithSize:(CGSize)size context:(NSStringDrawingContext *)context
{
    return [self boundSizeWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:context];
}


- (CGSize)boundSizeWithSize:(CGSize)size options:(NSStringDrawingOptions)options context:(NSStringDrawingContext *)context
{
    CGRect brect = [self boundingRectWithSize:size options:options context:context];
    CGSize bsize = CGSizeMake((CGFloat)ceil((double)brect.size.width), (CGFloat)ceil((double)brect.size.height));
    return bsize;
}

@end
