//
//  SettingsVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/12.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SettingsVC.h"

#import "AlterPwdVC.h"
#import "NewNotificationSettingVC.h"
#import "VersionVC.h"
#import "AboutUsVC.h"

#import "LoginVC.h"

#define kTotalSessionCount    3

typedef NS_ENUM(NSInteger, BusineType) {
    eAlterPwdType,
    eNewNotificationType,
    eAbountType,
};

@interface SettingsVC ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@end

@implementation SettingsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupRootViewSubs:self.view];
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height-spaceYStart) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor=[UIColor clearColor];
    tableView.backgroundView = nil;
    [viewParent addSubview:tableView];
}

- (void)doLogOutAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否确定退出登陆？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
 
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == eAbountType)
    {
        return 80;
    }
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSInteger row = indexPath.row;

    switch (indexPath.section) {
        case eAlterPwdType:
        {
            AlterPwdVC *alterPwdVC = [[AlterPwdVC alloc] initWithName:@"修改密码"];
            [self.navigationController pushViewController: alterPwdVC animated:YES];
            break;
        }
        case eNewNotificationType:
        {
            NewNotificationSettingVC *alterPwdVC = [[NewNotificationSettingVC alloc] initWithName:@"新消息通知"];
            [self.navigationController pushViewController: alterPwdVC animated:YES];
            break;
        }
            
        case eAbountType:
        {
            if (row == 0)
            {
                VersionVC *versionVC = [[VersionVC alloc] initWithName:@"版本信息"];
                [self.navigationController pushViewController:versionVC animated:YES];
            }
            else if (row == 1)
            {
                AboutUsVC *alterPwdVC = [[AboutUsVC alloc] initWithName:@"关于我们"];
                [self.navigationController pushViewController: alterPwdVC animated:YES];
            }
           
            break;
        }
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kTotalSessionCount;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 2;
            break;
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reusedIdentifier = @"SettingsVCID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = kTextColor;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case eAlterPwdType:
            [cell.textLabel setText:@"修改登录密码"];

            break;
        case eNewNotificationType:
            [cell.textLabel setText:@"新信息通知设置"];

            break;
        case eAbountType:
            if (row == 0)
            {
                [cell.textLabel setText:@"版本信息"];

            }
            else if (row == 1)
            {
                [cell.textLabel setText:@"关于我们"];
            }

            break;

        default:
            break;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, tableView.width, 20);
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == eAbountType)
    {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, tableView.width, 80);
        view.backgroundColor = [UIColor clearColor];
        
        UIButton *logOutBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [logOutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [logOutBtn addTarget:self action:@selector(doLogOutAction) forControlEvents:UIControlEventTouchUpInside];
        logOutBtn.titleLabel.font = kSmallTitleFont;
        logOutBtn.frame = CGRectMake(40, 30, view.width - 40*2, view.height-40) ;
        logOutBtn.tintColor = [UIColor whiteColor];
        logOutBtn.backgroundColor = kBackgroundGreenColor;
        logOutBtn.layer.cornerRadius = 20;
        [view addSubview:logOutBtn];
        
        return view;

    }
    
    return nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        
    }
    else
    {
        // 清除登录缓存(保留手机号）
        NSString *cellPhone = [[[DataController getInstance] getUserLoginInfo ]objectForKey:kUserCellPhoneKey];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:cellPhone forKey:kUserCellPhoneKey];
        
        [[DataController getInstance] saveUserLoginInfo:dictionary];
        
        LoginVC *loginVC = [[LoginVC alloc] initWithName:@"登录"];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

@end
