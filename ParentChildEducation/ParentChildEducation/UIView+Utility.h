//
//  UIView+Utility.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Utility)

//  将View的左边移动到指定位置
@property (nonatomic) CGFloat left;

//  将View的顶端移动到指定位置
@property (nonatomic) CGFloat top;

//  将View的右边移动到指定位置
@property (nonatomic) CGFloat right;

//  将View的底端移动到指定位置
@property (nonatomic) CGFloat bottom;

//  更改View的宽度
@property (nonatomic) CGFloat width;

//  更改View的高度
@property (nonatomic) CGFloat height;

//  更改View的位置
@property (nonatomic) CGPoint origin;

//  更改View的尺寸
@property (nonatomic) CGSize size;

//  更改View中心点的位置x
@property (nonatomic) CGFloat centerX;

//  更改View中心点的位置x
@property (nonatomic) CGFloat centerY;

// 设置UIView的X == setLeft
- (void)setViewX:(CGFloat)newX;

// 设置UIView的Y == setTop
- (void)setViewY:(CGFloat)newY;

// 设置UIView的Origin == setOrigin
- (void)setViewOrigin:(CGPoint)newOrigin;

// 设置UIView的width == setWidth
- (void)setViewWidth:(CGFloat)newWidth;

// 设置UIView的height == setHeight
- (void)setViewHeight:(CGFloat)newHeight;

// 设置UIView的Size == setSize
- (void)setViewSize:(CGSize)newSize;

//! 清除所有的子View
- (void)removeAllSubviews;

// =======================================================================
// 创建Button
// =======================================================================
- (id)initWithFrame:(CGRect)initFrame andCornerRadius:(float)cornerRadius andBorderColor:(UIColor *)borderColor andBorderWidth:(float)borderWidth;

// 分割线
- (id)initSepartorViewWithFrame:(CGRect)initFrame;


@end
