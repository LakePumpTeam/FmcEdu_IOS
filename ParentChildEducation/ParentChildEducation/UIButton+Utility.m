//
//  UIButton+Utility.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "UIButton+Utility.h"

@implementation UIButton (Utility)

- (id)initWithFont:(UIFont *)initFont andTitle:(NSString *)initTitle andTtitleColor:(UIColor *)titleColor
{
    if((self = [self initWithFrame:CGRectZero]) != nil)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setFont:initFont];
        
        [self setTitle:initTitle forState:UIControlStateNormal];
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        
        CGSize labelSize = [initTitle sizeWithFontCompatible:initFont];
        [self setBounds:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    }
    
    return self;
}

- (id)initWithFont:(UIFont *)initFont andTitle:(NSString *)initTitle andTtitleColor:(UIColor *)titleColor andBorderColor:(UIColor *)borderColor andCornerRadius:(float)cornerRadius
{
    if((self = [self initWithFrame:CGRectZero]) != nil)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setFont:initFont];
        
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = borderColor.CGColor;
        self.layer.cornerRadius = cornerRadius;
        
        [self setTitle:initTitle forState:UIControlStateNormal];
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        CGSize labelSize = [initTitle sizeWithFontCompatible:initFont];
        [self setBounds:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    }
    
    return self;
}

- (id)initWithFont:(UIFont *)initFont andTitle:(NSString *)initTitle andTtitleColor:(UIColor *)titleColor andCornerRadius:(float)cornerRadius
{
    if((self = [self initWithFrame:CGRectZero]) != nil)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setFont:initFont];
        
        self.layer.cornerRadius = cornerRadius;
        
        [self setTitle:initTitle forState:UIControlStateNormal];
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        CGSize labelSize = [initTitle sizeWithFontCompatible:initFont];
        [self setBounds:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    }
    
    return self;
}

@end
