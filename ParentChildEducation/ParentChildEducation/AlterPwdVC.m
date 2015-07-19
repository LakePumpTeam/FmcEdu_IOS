//
//  AlterPwdVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/12.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "AlterPwdVC.h"
#import "LoginVC.h"
#import "SaltResult.h"

typedef NS_ENUM(NSInteger, ControllTag)
{
    eAlterPwdSuccessAlertTag = 100,
};

@interface AlterPwdVC ()<UITextFieldDelegate, NetworkPtc, UIAlertViewDelegate>

@property (nonatomic, strong) UITextField *oldPwdTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *confirmPwdTextField;
@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, strong) NSString *oldPwdString;
@property (nonatomic, strong) NSString *pwdString;
@property (nonatomic, strong) NSString *confirmPwdString;

// 各项输入的状态
@property (nonatomic, assign) BOOL oldPwdIsOk;
@property (nonatomic, assign) BOOL pwdIsSame;

@property (nonatomic, strong) NSString *saltString;

@end

@implementation AlterPwdVC

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _oldPwdIsOk = NO;
        _pwdIsSame = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupRootViewSubs:self.view];
    
    // 添加手势，触摸即键盘消失
    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc]                                                initWithTarget:self                                                 action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:dismissKeyboardTap];
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 10;
    
    if (kSystemVersion > 7)
    {
        spaceYStart += kNavigationBarHeight;
    }
    
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 旧密码输入
    // =======================================================================
    UIView *oldPasswordView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    oldPasswordView.backgroundColor = [UIColor whiteColor];
    
    [viewParent addSubview:oldPasswordView];
    
    // 子视图
    [self setupViewSubsOldPwdCell:oldPasswordView];
    
    // 调整Y
    spaceYStart += oldPasswordView.height;
    
    
    // =======================================================================
    // 密码输入
    // =======================================================================
    UIView *passwordView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    passwordView.backgroundColor = [UIColor whiteColor];
    [viewParent addSubview:passwordView];
    
    // 子视图
    [self setupViewSubsPwdCell:passwordView];
    
    // 调整Y
    spaceYStart += passwordView.height;
    
    // =======================================================================
    // 确认密码输入
    // =======================================================================
    UIView *confirmPasswordView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    confirmPasswordView.backgroundColor = [UIColor whiteColor];
    
    [viewParent addSubview:confirmPasswordView];
    
    // 子视图
    [self setupViewSubsConfirmPwdCell:confirmPasswordView];
    
    // 调整Y
    spaceYStart += confirmPasswordView.height;
    
    // =======================================================================
    // 提交审核
    // =======================================================================
    
    // 调整Y
    spaceYStart += 55;
    
    UIButton *submitButton = [[UIButton alloc] initWithFont:kTitleFont andTitle:@"提交" andTtitleColor:kWhiteColor andCornerRadius:20.0];
    submitButton.backgroundColor = [UIColor lightGrayColor];
    submitButton.enabled = NO;
    
    submitButton.frame = CGRectMake(40, spaceYStart, kScreenWidth-40*2, kButtonHeight);
    [submitButton addTarget:self action:@selector(doSubmitAction) forControlEvents:UIControlEventTouchUpInside];
    
    [viewParent addSubview:submitButton];
    _submitButton = submitButton;
}

// 旧密码cell
- (void)setupViewSubsOldPwdCell:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // 调整Y
    spaceYStart += 1;
    
    // =======================================================================
    // 设置密码
    // =======================================================================
    
    if (_oldPwdTextField == nil)
    {
        UITextField *phoneCodeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        // 特殊设置
        phoneCodeTextField.secureTextEntry = YES;
        
        [phoneCodeTextField setTextColor:kTextColor];
        [phoneCodeTextField setFont:kSmallTitleFont];
        [phoneCodeTextField setPlaceholder:@"请输入旧密码"
                          placeholderColor:kTextColor
                       placeholderFontSize:kSmallTitleFont];
        [phoneCodeTextField setDelegate:self];
        [phoneCodeTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [phoneCodeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [phoneCodeTextField setReturnKeyType:UIReturnKeyDone];
        [phoneCodeTextField addTarget:self action:@selector(oldPasswordChanged:) forControlEvents:UIControlEventEditingChanged];
        [phoneCodeTextField addTarget:self action:@selector(oldPasswordFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // 保存
        [viewParent addSubview:phoneCodeTextField];
        
        _oldPwdTextField = phoneCodeTextField;
        
    }
    [_oldPwdTextField setFrame:CGRectMake(kLeftMargin, spaceYStart, viewParent.width-kLeftMargin, viewParent.height-spaceYStart)];
    
}

// 密码cell
- (void)setupViewSubsPwdCell:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // 调整Y
    spaceYStart += 1;
    
    // =======================================================================
    // 设置密码
    // =======================================================================
    
    if (_pwdTextField == nil)
    {
        UITextField *phoneCodeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        // 特殊设置
        phoneCodeTextField.secureTextEntry = YES;
        
        [phoneCodeTextField setTextColor:kTextColor];
        [phoneCodeTextField setFont:kSmallTitleFont];
        [phoneCodeTextField setPlaceholder:@"请输入新密码，需为6-16位字符"
                          placeholderColor:kTextColor
                       placeholderFontSize:kSmallTitleFont];
        [phoneCodeTextField setDelegate:self];
        [phoneCodeTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [phoneCodeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [phoneCodeTextField setReturnKeyType:UIReturnKeyDone];
        [phoneCodeTextField addTarget:self action:@selector(passwordChanged:) forControlEvents:UIControlEventEditingChanged];
        [phoneCodeTextField addTarget:self action:@selector(passwordFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // 保存
        [viewParent addSubview:phoneCodeTextField];
        
        _pwdTextField = phoneCodeTextField;
        
    }
    [_pwdTextField setFrame:CGRectMake(kLeftMargin, spaceYStart, viewParent.width-kLeftMargin, viewParent.height-spaceYStart)];
    
}

// 确认密码cell
- (void)setupViewSubsConfirmPwdCell:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // 调整Y
    spaceYStart += 1;
    
    // =======================================================================
    // 验证码输入
    // =======================================================================
    
    if (_confirmPwdTextField == nil)
    {
        UITextField *phoneCodeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        // 特殊设置
        phoneCodeTextField.secureTextEntry = YES;
        
        [phoneCodeTextField setTextColor:kTextColor];
        [phoneCodeTextField setFont:kSmallTitleFont];
        [phoneCodeTextField setPlaceholder:@"请再次确认密码"
                          placeholderColor:kTextColor
                       placeholderFontSize:kSmallTitleFont];
        [phoneCodeTextField setDelegate:self];
        [phoneCodeTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [phoneCodeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [phoneCodeTextField setReturnKeyType:UIReturnKeyDone];
        [phoneCodeTextField addTarget:self action:@selector(confirmPwdChanged:) forControlEvents:UIControlEventEditingChanged];
        [phoneCodeTextField addTarget:self action:@selector(confirmPwdFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // 保存
        [viewParent addSubview:phoneCodeTextField];
        
        _confirmPwdTextField = phoneCodeTextField;
    }
    [_confirmPwdTextField setFrame:CGRectMake(kLeftMargin, spaceYStart, viewParent.width-kLeftMargin, viewParent.height-spaceYStart)];
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *bottomLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, viewParent.height-1, viewParent.width, 0.5)];
    [viewParent addSubview:bottomLine];
    
}

#pragma mark - 输入事件
// 判断是否可提交
- (void)setCanRegister
{
    if (_oldPwdIsOk && _pwdIsSame) {
        [_submitButton setBackgroundColor:kBackgroundGreenColor];
        [_submitButton setEnabled:YES];
    }
    else
    {
        [_submitButton setBackgroundColor:[UIColor lightGrayColor]];
        [_submitButton setEnabled:NO];
    }
}

// 旧密码
- (void)oldPasswordChanged:(id)sender
{
    // 保存文本
    _oldPwdString = [(UITextField *)sender text];
    
    if ([_oldPwdString isStringSafe])
    {
        _oldPwdIsOk = YES;
    }
    else
    {
        _oldPwdIsOk = NO;
    }
    
    [self setCanRegister];
}

- (void)oldPasswordFinished:(id)sender
{
    
}

// 密码
- (void)passwordChanged:(id)sender
{
    // 保存文本
    _pwdString = [(UITextField *)sender text];
    
    if (_pwdString.length > 5 && [_pwdString isEqualToString:_confirmPwdString]) {
        _pwdIsSame = YES;
    }
    else
    {
        _pwdIsSame = NO;
    }
    [self setCanRegister];
}

- (void)passwordFinished:(id)sender
{
}

// 确认密码
- (void)confirmPwdChanged:(id)sender
{
    // 保存文本
    _confirmPwdString = [(UITextField *)sender text];
    
    if (_confirmPwdString.length > 5 && [_pwdString isEqualToString:_confirmPwdString]) {
        _pwdIsSame = YES;
    }
    else
    {
        _pwdIsSame = NO;
    }
    [self setCanRegister];
}

- (void)confirmPwdFinished:(id)sender
{
    
}

- (void)doSubmitAction
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求key
    // =======================================================================
    NSString *cellPhone = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserCellPhoneKey];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    // 手机号
    [parameters setObjectSafe:base64Encode(cellPhone) forKey:@"cellPhone"];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestLoginSalt
                 forParamDic:parameters
                searchResult:[[SaltResult alloc] init]
                 andDelegate:self forInfo:kRequestLoginSalt];
    
}

- (void)getSubmitRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 提交请求
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    
    // 密码MD5
    NSString *oldPwdMd5 = [[NSString stringWithFormat:@"%@%@", _saltString, _oldPwdString] getMD5];
    NSString *newPwdMd5 = [[NSString stringWithFormat:@"%@%@", _saltString, _pwdString] getMD5];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode(oldPwdMd5) forKey:@"oldPassword"];
    [parameters setObjectSafe:base64Encode(newPwdMd5) forKey:@"newPassword"];
    
    
    // 请求
    [NetWorkTask postRequest:kRequestAlterPwd
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestAlterPwd];
}

#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    if ([customInfo isEqualToString:kRequestLoginSalt])
    {
        [self getSearchNetBackOfSalt:searchResult forInfo:customInfo];
    }
    else if ([customInfo isEqualToString:kRequestAlterPwd])
    {
        [self getSearchNetBackOfSubmit:searchResult forInfo:customInfo];
    }
    
    
}

- (void)getSearchNetBackOfSalt:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        SaltResult *result = (SaltResult *)searchResult;
        
        // 接口成功
        if ([result.status intValue] == 0)
        {
            // 成功
            if ([result.isSuccess integerValue] == 0)
            {
                if ([result.salt isStringSafe])
                {
                    _saltString = result.salt;
                }
                
                [self getSubmitRequest];
                
            }
            else
            {
                if ([result.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:result.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
        }
    }
}

- (void)getSearchNetBackOfSubmit:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        BusinessSearchNetResult *parentRelateInfoResult = (BusinessSearchNetResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                // 清除登录缓存(保留手机号）
                NSString *cellPhone = [[[DataController getInstance] getUserLoginInfo ]objectForKey:kUserCellPhoneKey];
                
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [dictionary setObject:cellPhone forKey:kUserCellPhoneKey];
                
                [[DataController getInstance] saveUserLoginInfo:dictionary];
                
                // 提示
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"修改成功，请重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alertView.tag = eAlterPwdSuccessAlertTag;
                [alertView show];
            }
            // 失败
            else
            {
                if ([parentRelateInfoResult.businessMsg isStringSafe]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:parentRelateInfoResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)getSearchNetBackWithFailure:(id)customInfo
{
    [self stopLoadingAnimation];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == eAlterPwdSuccessAlertTag)
    {
        LoginVC *login = [[LoginVC alloc] initWithName:@"登陆"];
        [self.navigationController pushViewController:login animated:YES];
    }
}

- (void)dismissKeyboard
{
    if (_oldPwdTextField)
    {
        [_oldPwdTextField resignFirstResponder];
    }
    if (_pwdTextField) {
        [_pwdTextField resignFirstResponder];
    }
    if (_confirmPwdTextField) {
        [_confirmPwdTextField resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //删除退格按钮
    if (string.length == 0) {
        return YES;
    }
    
    // 旧密码
    if (textField == _oldPwdTextField)
    {
        return [textField shouldChangeInRange:range withString:string andLength:16];
    }
    
    if (textField == _pwdTextField)
    {
        return [textField shouldChangeInRange:range withString:string andLength:16];
    }
    // 密码不能超过16位
    if (textField == _confirmPwdTextField)
    {
        return [textField shouldChangeInRange:range withString:string andLength:16];
    }
    
    return YES;
}
@end
