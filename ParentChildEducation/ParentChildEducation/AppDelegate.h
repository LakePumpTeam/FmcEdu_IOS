//
//  AppDelegate.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//


// =========================================================================
// 取缓存的登录信息，发送登录请求。
//                成功：进入主界面(MainVC)；
//                失败：清除缓存，提示登录失效，进入登录页面(LoginVC)
// =========================================================================


#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

