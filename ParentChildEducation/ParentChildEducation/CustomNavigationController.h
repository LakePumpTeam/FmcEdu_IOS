//
//  CustomNavigationController.h
//  CustomNavigation
//
//  Created by zlan.zhang on 15/5/6.
//  Copyright (c) 2015年 com.kl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationController : UINavigationController

// 是否支持右滑返回
- (void)canDragBack: (BOOL)isCanDragBack;

@end
