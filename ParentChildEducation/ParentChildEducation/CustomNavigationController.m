//
//  CustomNavigationController.m
//  CustomNavigation
//
//  Created by zlan.zhang on 15/5/6.
//  Copyright (c) 2015年 com.kl. All rights reserved.
//

#import "CustomNavigationController.h"

@implementation CustomNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 使导航有效
    [self setNavigationBarHidden:NO];
    // 隐藏导航条，但由于导航有效，系统的返回按钮有效、且可右滑返回
    [self.navigationBar setHidden:YES];
    
}
// 是否支持右滑返回
- (void)canDragBack: (BOOL)isCanDragBack
{
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (systemVersion > 7.0)
    {
        self.interactivePopGestureRecognizer.enabled = isCanDragBack;
    }
}

@end
