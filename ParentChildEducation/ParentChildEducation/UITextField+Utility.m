//
//  UITextField+Utility.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/8.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "UITextField+Utility.h"

@implementation UITextField (Utility)

- (id)initWithFrame:(CGRect)initFrame initFontSize:(UIFont *)initFontSize textColor:(UIColor *)textColor
{
    self = [super initWithFrame:initFrame];
    
    if (self)
    {
//        self.textColor = textColor;
//        self.font = initFontSize;
//        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//        self.returnKeyType = UIReturnKeyDone;
//        self.clearButtonMode = UITextFieldViewModeWhileEditing;
//        [self setKeyboardType:UIKeyboardTypeDefault];
//        self.backgroundColor = [UIColor whiteColor];
//        [self setClearsOnBeginEditing:NO];
    }
    
    return self;
}

// 设置Placeholder
- (void)setPlaceholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor placeholderFontSize:(UIFont *)placeholderFontSize
{
    if (kSystemVersion > 6.0) {
        self.attributedPlaceholder =[[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:placeholderColor,NSFontAttributeName:placeholderFontSize}];
    }
    else {
        self.placeholder = placeholder;
    }
}

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
