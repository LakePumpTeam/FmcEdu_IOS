//
//  UILabel+Utility.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "UILabel+Utility.h"

@implementation UILabel (Utility)

// 创建Label
- (id)initWithFont:(UIFont *)initFont andText:(NSString *)initText andColor:(UIColor *)textColor
{
    if((self = [self initWithFrame:CGRectZero]) != nil)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFont:initFont];
        [self setText:initText];
        [self setTextColor:textColor];
        [self setTextAlignment:NSTextAlignmentCenter];
        CGSize labelSize = [initText sizeWithFontCompatible:initFont];
        [self setBounds:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    }
    
    return self;
}

// 创建Label
- (id)initWithFont:(UIFont *)initFont andText:(NSString *)initText andColor:(UIColor *)textColor withTag:(NSInteger)initTag
{
    if((self = [self initWithFrame:CGRectZero]) != nil)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFont:initFont];
        [self setText:initText];
        [self setTextColor:textColor];
        [self setTextAlignment:NSTextAlignmentCenter];
        CGSize labelSize = [initText sizeWithFontCompatible:initFont];
        [self setBounds:CGRectMake(0, 0, labelSize.width, labelSize.height)];
        self.tag = initTag;
        
    }
    
    return self;
}

- (id)initRedStart:(UIFont *)initFont;
{
    if((self = [self initWithFrame:CGRectZero]) != nil)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setFont:initFont];
        [self setText:@"*"];
        [self setTextColor:[UIColor redColor]];
        [self setTextAlignment:NSTextAlignmentCenter];
        CGSize labelSize = [@"*" sizeWithFontCompatible:initFont];
        [self setBounds:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    }
    
    return self;
}

@end
