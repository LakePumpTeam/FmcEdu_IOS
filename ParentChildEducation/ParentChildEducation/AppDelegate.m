//
//  AppDelegate.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//


#import "AppDelegate.h"

#import "CustomNavigationController.h"
#import "RegisterAssociatedInforVC.h"
#import "AlterAssociatedInforVC.h"

// VC
#import "MainVC.h"
#import "LoginVC.h"

#import "LoginResult.h"

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "HttpMock.h"

#import "UIPopoverListView.h"
#import "PopTableViewCell.h"
#import "OptionInfo.h"

typedef NS_ENUM(NSInteger, ControllTag) {
    eSearchPwdAlertTag = 100,
    eNoPassAuditAlertTag,
    eLoginFailureAlertTag,
};

#define kPopCellHeight                              50

@interface AppDelegate ()<NetworkPtc, UIPopoverListViewDataSource, UIPopoverListViewDelegate>

@property (nonatomic, strong) LoginResult *loginResult;

// 选择列表（家长：学生列表，老师：班级列表）
@property (nonatomic, strong) UIPopoverListView *optionlistview;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // =======================================================================
    // 网络拦截设置
    // =======================================================================
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [HttpMock initMock];

    // =======================================================================
    // 推送设置
    // =======================================================================
    [self doBPushSettings:launchOptions];
    
    _window = [[UIWindow alloc] init];
    
    // 背景色
    _window.backgroundColor = kBackgroundGreenColor;
    
    if (kSystemVersion < 7.0)
    {
        [_window setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight+kNavigationBarHeight)];
    }
    else
    {
        [_window setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    }

    [_window makeKeyAndVisible];

    // 开始自动登录
    [self getStartLogin];
    
    return YES;
}

- (void)doBPushSettings:(NSDictionary *)launchOptions
{
    // iOS8 下需要使⽤用新的 API
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound
        | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 入口逻辑

// =======================================================================
// 登录请求
// =======================================================================
- (void)getStartLogin
{
    // =======================================================================
    // 取本地用户登录信息
    // =======================================================================
    NSMutableDictionary *userLoginInfo = [[DataController getInstance] getUserLoginInfo];
    NSString *cellPhone = [userLoginInfo objectForKey:kUserCellPhoneKey];
    NSString *userLoginPwd = [userLoginInfo objectForKey:kUserPwdKey];

    if (cellPhone == nil || userLoginPwd == nil)
    {
        // 进入登陆界面
        [self goLoginVC];
    }
    else
    {
        
        // =======================================================================
        // 请求参数：userAccount 登录账号 password 登录密码
        // =======================================================================
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObjectSafe:base64Encode(cellPhone) forKey:kUserCellPhoneKey];
        [parameters setObjectSafe:base64Encode(userLoginPwd) forKey:kUserPwdKey];
        
        // 发送请求
        [NetWorkTask postRequest:kRequestLogin
                     forParamDic:parameters
                    searchResult:[[LoginResult alloc] init]
                     andDelegate:self forInfo:kRequestLogin
                      isMockData:kIsMock_RequestLogin];
    }
   
}

// 进入主界面
- (void)goMain
{
    // 老师
    if ([_loginResult.userRole integerValue] == 1)
    {
        // =======================================================================
        // 进入主界面
        // =======================================================================
        [self goMainVC];

    }
    // 家长
    else
    {
        // =======================================================================
        // 审核状态判断 int 1：通过 2：未通过 0：正在审核
        // =======================================================================
        
        // 审核成功，可直接登录
        if ([_loginResult.auditState integerValue] == 1)
        {
            // =======================================================================
            // 进入主界面
            // =======================================================================
            
            [self goMainVC];
            
        }
        // 未通过
        else if ([_loginResult.auditState integerValue] == 2)
        {
            NSString *tintMsg = @"审核失败";
            if ([_loginResult.businessMsg isStringSafe] && [_loginResult.businessMsg isKindOfClass:[NSString class]])
            {
                tintMsg = _loginResult.businessMsg;
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:tintMsg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"修改关联信息", nil];
            
            
            alertView.tag = eNoPassAuditAlertTag;
            [alertView show];
            
        }
        // 正在审核
        else if ([_loginResult.auditState integerValue] == 0)
        {
            // 弹框提示
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"正在审核..." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        // 状态不明
        else
        {
            if ([_loginResult.businessMsg isStringSafe])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:_loginResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }
    }
    
}

// 进入主界面
- (void)goMainVC
{
    MainVC *mainVC = [[MainVC alloc] init];
    CustomNavigationController *navigationVC = [[CustomNavigationController alloc] initWithRootViewController:mainVC];
    _window.rootViewController = navigationVC;
}

// 进入登录页面
- (void)goLoginVC
{
    LoginVC *loginVC = [[LoginVC alloc] init];
    CustomNavigationController *navigationVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
    _window.rootViewController = navigationVC;
}

- (void)goRelatedInfoVC
{
    NSMutableDictionary *userLoginInfo = [[DataController getInstance] getUserLoginInfo];
    NSNumber *userId = [userLoginInfo objectForKey:kUserIdKey];

    AlterAssociatedInforVC *loginVC = [[AlterAssociatedInforVC alloc] initWithName:@"关联信息"];
    loginVC.userId = userId;
    loginVC.fromType = 1;
    
    CustomNavigationController *navigationVC = [[CustomNavigationController alloc] initWithRootViewController:loginVC];
    _window.rootViewController = navigationVC;
}

#pragma mark - 网络请求回调

- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        _loginResult = (LoginResult *)searchResult;
        
        // 接口成功
        if ([_loginResult.status intValue] == 0)
        {
            // 登录成功
            if ([_loginResult.isSuccess integerValue] == 0) {
                
                // 判断是否有多个学生，或者多个班级
                if (_loginResult.optionList && _loginResult.optionList.count > 1)
                {
                    // 弹出选择列表
                    CGFloat xWidth = kScreenWidth - 40.0f;
                    CGFloat yHeight = kPopCellHeight * (_loginResult.optionList.count + 1);
                    CGFloat yOffset = kNavigationBarHeight + 20;
                    
                    CGFloat subsHeight = kScreenHeight-kNavigationBarHeight-80;
                    
                    if (yHeight > subsHeight) {
                        yHeight = subsHeight;
                    }
                    
                    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(20, yOffset, xWidth, yHeight)];
                    poplistview.delegate = self;
                    poplistview.datasource = self;
                    
                    // 老师
                    if ([_loginResult.userRole integerValue] == 1)
                    {
                        [poplistview setTitle:@"请选择班级"];
                    }
                    // 家长
                    else
                    {
                        [poplistview setTitle:@"请选择学生"];
                    }
                    _optionlistview = poplistview;
                    [_optionlistview show];
                }
                else
                {
                    // 只有一个班级，或者学生
                    if (_loginResult.optionList && _loginResult.optionList.count == 1)
                    {
                        OptionInfo *selectInfo = _loginResult.optionList[0];
                        NSNumber *optionId = selectInfo.optionId;
                        NSNumber *classId = selectInfo.classId;
                        
                        [kSaveData setObject:optionId forKey:kOptionIdKey];
                        [kSaveData setObject:classId forKey:kClassIdKey];
                        
                        [kSaveData synchronize];
                    }
                    
                    [self goMain];
                }
            }
            // 失败
            else
            {
                // 清空登录信息
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [[DataController getInstance] saveUserLoginInfo:dictionary];
                
                if ([_loginResult.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:_loginResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常，请联系后台管理员" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
            
        }
        // 接口失败
        else
        {
            if ([_loginResult.msg isKindOfClass:[NSString class]] && [_loginResult.msg isStringSafe])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:_loginResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常，请联系后台管理员" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常，请联系后台管理员" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)getSearchNetBackWithFailure:(id)customInfo
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    
    // 审核失败，进入关联信息页面重新提交审核
    if (alertView.tag == eNoPassAuditAlertTag)
    {
        [self goRelatedInfoVC];
    }
    // 登录失败，进入登录页面
    else
    {
        [self goLoginVC];
    }

}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (popoverListView == _optionlistview)
    {
        static NSString *identifier = @"ProvsListViewCell";
        OptionInfo *objectInfo = _loginResult.optionList[row];
        
        PopTableViewCell *cell = [[PopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:identifier];
        cell.textLabel.text = objectInfo.optionName;
        cell.textLabel.textColor = [UIColor colorWithHex:0x999999 alpha:1.0] ;
        cell.textLabel.font = kSmallTitleFont ;
        cell.imageView.image = [UIImage imageNamed:@"unselect"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
        
        return cell;
    }
    
    return nil;
}

- (NSInteger)popoverListView:(UIPopoverListView *)popoverListView
       numberOfRowsInSection:(NSInteger)section
{
    if (popoverListView == _optionlistview)
    {
        return _loginResult.optionList.count;
    }
    
    return 0;
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    OptionInfo *selectInfo = _loginResult.optionList[indexPath.row];
    NSNumber *optionId = selectInfo.optionId;
    NSNumber *classId = selectInfo.classId;
    
    [kSaveData setObject:optionId forKey:kOptionIdKey];
    [kSaveData setObject:classId forKey:kClassIdKey];
    
    [kSaveData synchronize];
    
    [self goMain];
    
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
