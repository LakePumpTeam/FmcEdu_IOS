//
//  UITextView+Utility.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/25.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "UITextView+Utility.h"

@implementation UITextView (Utility)

// 是否可以继续输入
- (BOOL)shouldChangeInRange:(NSRange)range withString:(NSString *)string andLength:(NSInteger)maxLength
{
    // 当前内容长度
    NSString *content = [self text];
    NSInteger contentLength = (content != nil) ? [content length] : 0;
    
    // 计算总长度
    NSInteger totalLenght = contentLength + [string length] - range.length;
    if(totalLenght > maxLength)
    {
        return NO;
    }
    
    return YES;
}

@end
