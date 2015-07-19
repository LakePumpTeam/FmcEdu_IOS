//
//  LoadView.m
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/1.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "LoadView.h"

@implementation LoadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initView];

        // 关闭手势
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [_tapGestureRecognizer setDelegate:self];
        
        [self addGestureRecognizer:_tapGestureRecognizer];
        
    }
    
    return self;
}

- (void)initView
{
    // =======================================================================
    // 游标
    // =======================================================================
    NSInteger spaceXStart = 0;
    NSInteger spaceYStart = kNavigationBarHeight;
    
    // =======================================================================
    // 底层半透明浮窗
    // =======================================================================
    
    CGSize suspendedViewSize = [UIScreen mainScreen].bounds.size;
    _suspendView = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, suspendedViewSize.width, suspendedViewSize.height)];
    
    [_suspendView setBackgroundColor:[UIColor colorWithHex:0x333333 alpha:0.5f]];
    
    // 添加
    [_suspendView setUserInteractionEnabled:NO];
    [self addSubview:_suspendView];
    
}

- (void)tapView:(UITapGestureRecognizer *)tapGesture
{
    [self removeFromSuperview];
}

- (void)startLoadingView
{
    if (_activityIndicator)
    {
        [_activityIndicator startAnimating];
    }
    else
    {
        // =======================================================================
        // 加载中视图
        // =======================================================================
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [_activityIndicator setCenter:self.center];
        [_activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_activityIndicator];
        
        [_activityIndicator startAnimating];
    }
}

- (void)stopLoadingView
{
    if (_activityIndicator)
    {
        [_activityIndicator stopAnimating];
    }
    
    if (self) {
        [self removeFromSuperview];
    }
}

@end
