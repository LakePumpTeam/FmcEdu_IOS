//
//  CustomNavigationView.m
//  CustomNavigation
//
//  Created by zlan.zhang on 15/5/6.
//  Copyright (c) 2015年 com.kl. All rights reserved.
//

#import "CustomNavigationView.h"

@implementation CustomNavigationView


// 返回
- (void)btnBack:(id)sender
{
    if (_parentVC)
    {
        [_parentVC.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
