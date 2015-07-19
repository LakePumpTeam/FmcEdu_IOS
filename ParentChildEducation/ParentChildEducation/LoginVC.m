//
//  LoginVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "LoginVC.h"

// VC
#import "MainVC.h"
#import "RegisterVC.h"
#import "SearchPwdVC.h"
#import "RegisterAssociatedInforVC.h"
#import "AlterAssociatedInforVC.h"

#import "LoginResult.h"
#import "SaltResult.h"

#import "UIPopoverListView.h"
#import "PopTableViewCell.h"
#import "OptionInfo.h"

typedef NS_ENUM(NSInteger, ControllTag) {
    eSearchPwdAlertTag = 100,
    eNoPassAuditAlertTag,
    eLoginFailureAlertTag,
};

// =======================================================================
// frame
// =======================================================================

// Margin
#define kHMargin                                    40
#define kPwdImageHMargin                            12

// Size
#define kTitleHeight                                40
#define kPhoneImageWidth                            13
#define kPwdImageWidth                              18
#define kPopCellHeight                              50

// =======================================================================
// 文案相关
// =======================================================================
#define kTitle                                      @"相伴教育"

@interface LoginVC () <UITextFieldDelegate, NetworkPtc, UIAlertViewDelegate, UIPopoverListViewDelegate, UIPopoverListViewDataSource>

@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSString *phoneNumberString;
@property (nonatomic, strong) NSString *pwdString;
@property (nonatomic, strong) NSString *pwdMd5;
@property (nonatomic, strong) NSString *saltString;

@property (nonatomic, strong) LoginResult *loginResult;

// 选择列表（家长：学生列表，老师：班级列表）
@property (nonatomic, strong) UIPopoverListView *optionlistview;

@end

@implementation LoginVC

- (id)init
{
    self = [super init];
    
    if (self) {
        // 默认值
        _auditState = [NSNumber numberWithInt:1000];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 隐藏导航
    [self.navigationController.navigationBar setHidden:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 背景色
    [self.view setBackgroundColor:kBackgroundGreenColor];
    
    // =======================================================================
    // 布局
    // =======================================================================
    CGSize contentViewSize = CGSizeMake(kScreenWidth, 0);

    _contentView = [[UIView alloc] init];
    _contentView.frame = CGRectMake(0, 0, contentViewSize.width, contentViewSize.height);
    
    [self.view addSubview:_contentView];

    [self setupRootViewSubs:_contentView inSize:&contentViewSize];
    
    // 添加手势，触摸即键盘消失
    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc]                                                initWithTarget:self                                                 action:@selector(dismissKeyboard)];
    [_contentView addGestureRecognizer:dismissKeyboardTap];

    // 用户正在审核
    if ([_auditState integerValue] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"正在审核..." delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)setupRootViewSubs:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    // Button宽度
    NSInteger buttonWidth = kScreenWidth-kHMargin*2;
    
    // =======================================================================
    // title
    // =======================================================================
    UILabel *titleLabel = [[UILabel alloc] initWithFont:kLargeTitleBoldFont
                                                andText:kTitle
                                               andColor:kWhiteColor];
    titleLabel.frame = CGRectMake(0, spaceYStart, viewSize->width, kTitleHeight);
    [viewParent addSubview:titleLabel];

    // 调整Y
    spaceYStart += titleLabel.height;
    spaceYStart += 43;

    // 调整X
    spaceXStart += kHMargin;
    
    // =======================================================================
    // 手机号输入
    // =======================================================================
    UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, buttonWidth, kButtonHeight)
                                      andCornerRadius:kCornerRadius
                                       andBorderColor:kWhiteColor
                                       andBorderWidth:kBorderWidth];
    [viewParent addSubview:phoneView];
    
    // 子视图
    [self setupSubsPhoneView:phoneView];
    
    // 调整Y
    spaceYStart += phoneView.height;
    spaceYStart += 15;
    
    // =======================================================================
    // 密码输入
    // =======================================================================
    UIView *passwordView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, buttonWidth, kButtonHeight)
                                      andCornerRadius:kCornerRadius
                                       andBorderColor:kWhiteColor
                                       andBorderWidth:kBorderWidth];
    [viewParent addSubview:passwordView];
    
    // 子视图
    [self setupSubsPwdView:passwordView];
    
    // 调整Y
    spaceYStart += passwordView.height;
    
    // =======================================================================
    // 忘记密码
    // =======================================================================
    UIButton *forgetPwdButton = [[UIButton alloc]
                                 initWithFont:kSmallFont
                                 andTitle:@"忘记密码?"
                                 andTtitleColor:kWhiteColor];
    [forgetPwdButton addTarget:self action:@selector(doSearchPwdAction) forControlEvents:UIControlEventTouchUpInside];
    forgetPwdButton.frame = CGRectMake(kScreenWidth-kHMargin-60, spaceYStart+10, 60, 12);
    [viewParent addSubview:forgetPwdButton];
   
    // 调整Y
    
    spaceYStart += 72;
    
    // =======================================================================
    // 登录
    // =======================================================================
    UIButton *loginButton = [[UIButton alloc] initWithFont:kTitleFont
                                                  andTitle:@"登录"
                                            andTtitleColor:kWhiteColor
                                            andBorderColor:[UIColor whiteColor]
                                           andCornerRadius:kCornerRadius];

    [loginButton setImage:[UIImage imageFromColor:kARGBColor(52, 201, 202, 1.0)] forState:UIControlStateNormal];
    [loginButton setImage:[UIImage imageFromColor:[UIColor colorWithHex:0x01a2a4 alpha:1.0]] forState:UIControlStateHighlighted];
    
    loginButton.frame = CGRectMake(spaceXStart, spaceYStart, buttonWidth, kButtonHeight);
    [loginButton addTarget:self action:@selector(doLoginAction) forControlEvents:UIControlEventTouchUpInside];
    
    [viewParent addSubview:loginButton];
    
    // 调整Y
    spaceYStart += loginButton.height;
    spaceYStart += 32;
    
    // =======================================================================
    // 新用户注册
    // =======================================================================
    
    UIButton *registerButton = [[UIButton alloc]
                                 initWithFont:kSmallTitleFont
                                 andTitle:@"新用户注册"
                                 andTtitleColor:kWhiteColor];
    registerButton.frame = CGRectMake((kScreenWidth-90)/2, spaceYStart, 90, 25);
    [registerButton addTarget:self action:@selector(doRegisterAction) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:registerButton];
    
    // 调整Y
    spaceYStart += registerButton.height;
    
    // =======================================================================
    // 调整父view
    // =======================================================================
    [viewParent setHeight:spaceYStart];
    
    // 使viewParent居中
    [viewParent setViewY:(kScreenHeight-spaceYStart)/2.0];
}

// 手机号
- (void)setupSubsPhoneView:(UIView *)viewParent
{
    NSInteger spaceXStart = kPwdImageHMargin + (kPwdImageWidth - kPhoneImageWidth)/2;
    NSInteger parentWidth = viewParent.width;
    NSInteger parentHeight = viewParent.height;
    
    // =======================================================================
    // 图片
    // =======================================================================
    UIImage *phoneImage = [UIImage imageNamed:@"phone"];
    UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:phoneImage];
    phoneImageView.frame = CGRectMake(spaceXStart, (parentHeight-21)/2, kPhoneImageWidth, 21);
    [viewParent addSubview:phoneImageView];
    
    // 调整X
    spaceXStart = kPwdImageHMargin + kPwdImageWidth;
    spaceXStart += 18;
    
    // =======================================================================
    // 手机号输入
    // =======================================================================
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setFrame:CGRectMake(spaceXStart, 0, parentWidth-spaceXStart, parentHeight)];
    [textField setTextColor:kWhiteColor];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:@"请输入手机号"
                  placeholderColor:kWhiteColor
               placeholderFontSize:kSmallTitleFont];
    [textField setText:@""];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setReturnKeyType:UIReturnKeyNext];
    [textField addTarget:self action:@selector(phoneChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(phoneFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    // 保存
    [viewParent addSubview:textField];
    
    _phoneTextField = textField;
    
    // 默认手机号
    NSString *cellPhone = [[[DataController getInstance] getUserLoginInfo ]objectForKey:kUserCellPhoneKey];
    if ([cellPhone isStringSafe])
    {
        _phoneTextField.text = cellPhone;
        _phoneNumberString = cellPhone;
    }
}

// 密码
- (void)setupSubsPwdView:(UIView *)viewParent
{
    NSInteger spaceXStart = kPwdImageHMargin;
    NSInteger parentWidth = viewParent.width;
    NSInteger parentHeight = viewParent.height;
    
    // =======================================================================
    // 图片
    // =======================================================================
    UIImage *phoneImage = [UIImage imageNamed:@"pwd"];
    UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:phoneImage];
    phoneImageView.frame = CGRectMake(spaceXStart, (parentHeight-20)/2, kPwdImageWidth, 20);
    [viewParent addSubview:phoneImageView];
    
    // 调整X
    spaceXStart += phoneImageView.width;
    spaceXStart += 18;
    
    // =======================================================================
    // 密码输入
    // =======================================================================

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    // 特殊设置
    textField.secureTextEntry = YES;

    [textField setFrame:CGRectMake(spaceXStart, 0, parentWidth-spaceXStart, parentHeight)];
    [textField setTextColor:kWhiteColor];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:@"请输入密码"
             placeholderColor:kWhiteColor
          placeholderFontSize:kSmallTitleFont];
    [textField setDelegate:self];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField addTarget:self action:@selector(passwordChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(passwordFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    // 保存
    [viewParent addSubview:textField];
    
    _pwdTextField = textField;
    
    // 默认手机号
    NSString *visiblePwd = [[[DataController getInstance] getUserLoginInfo ]objectForKey:kUserVisiblePwdKey];
    if ([visiblePwd isStringSafe])
    {
        _pwdTextField.text = visiblePwd;
        _pwdString = visiblePwd;
    }
}

#pragma mark - 事件处理
- (void)doLoginAction
{    
    // 校验手机号
    if (_phoneNumberString.length != 11)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入有效的手机号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
   else if (![_pwdString isStringSafe]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
   else
    {
        // 请求salt
        [self getKeyRequest];
    }
   
}

- (void)getKeyRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求key
    // =======================================================================
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    // 手机号
    [parameters setObjectSafe:base64Encode(_phoneNumberString) forKey:@"cellPhone"];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestLoginSalt
                 forParamDic:parameters
                searchResult:[[SaltResult alloc] init]
                 andDelegate:self forInfo:kRequestLoginSalt];

}
- (void)getLoginRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    
    // MD5密码,salt由后台返回，时间戳
    _pwdMd5 = [[NSString stringWithFormat:@"%@%@", _saltString, _pwdString] getMD5];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    // 手机号
    [parameters setObjectSafe:base64Encode(_phoneNumberString) forKey:kUserCellPhoneKey];
    // 密码
    [parameters setObjectSafe:base64Encode(_pwdMd5) forKey:kUserPwdKey];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestLogin
                 forParamDic:parameters
                searchResult:[[LoginResult alloc] init]
                 andDelegate:self forInfo:kRequestLogin
                  isMockData:kIsMock_RequestLogin];
}

// 注册
- (void)doRegisterAction
{
    RegisterVC *registerVC = [[RegisterVC alloc] initWithName:@"注册"];
    [self.navigationController pushViewController:registerVC animated:YES];
}

// 找回密码
- (void)doSearchPwdAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"忘记密码？" message:@"您可以通过注册手机号重置密码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重置密码", nil];
    
    [alertView show];
}

#pragma mark - 输入事件
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

// 手机号码输入变化
- (void)phoneChanged:(id)sender
{
    // 保存文本
    _phoneNumberString = [(UITextField *)sender text];
  
    
//    // 保存最近一次输入的电话号码
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
//    [dictionary setObjectSafe:_phoneNumberString
//                   forKey:kUserCellPhoneKey];
//    [[DataController getInstance] saveUserLoginInfo:dictionary];
}

// 手机号码输入结束
- (void)phoneFinished:(id)sender
{
    UITextField *textFieldMobile = (UITextField *)sender;
    
    [textFieldMobile resignFirstResponder];
    
    if (_phoneNumberString.length < 11) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    }
    
}

#pragma mark - 验证码
- (void)passwordChanged:(id)sender
{
    _pwdString = [(UITextField *)sender text];
}

- (void)passwordFinished:(id)sender
{

}

#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    if ([customInfo isEqualToString:kRequestLoginSalt])
    {
        [self getSearchNetBackOfSalt:searchResult forInfo:customInfo];
    }
    else if ([customInfo isEqualToString:kRequestLogin])
    {
        [self getSearchNetBackOfLogin:searchResult forInfo:customInfo];
    }
}

// 登录回调
- (void)getSearchNetBackOfLogin:(SearchNetResult *)searchResult forInfo:(id)customInfo
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

// 请求salt回调
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
                
                [self getLoginRequest];
                
            }
            else
            {
                if ([result.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:result.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
            if ([result.msg isKindOfClass:[NSString class]] && [result.msg isStringSafe])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:result.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
    [self stopLoadingAnimation];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
    
}

// 进入主界面
- (void)goMain
{
    // 老师
    if ([_loginResult.userRole integerValue] == 1)
    {
        // =======================================================================
        // 保存登录信息
        // =======================================================================
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObjectSafe:_phoneNumberString forKey:kUserCellPhoneKey];
        [dictionary setObjectSafe:_pwdMd5 forKey:kUserPwdKey];
        [dictionary setObjectSafe:_pwdString forKey:kUserVisiblePwdKey];
        [dictionary setObjectSafe:_loginResult.userRole forKey:kUserRoleKey];
        [dictionary setObjectSafe:_loginResult.userId forKey:kUserIdKey];
        // 保存
        [[DataController getInstance] saveUserLoginInfo:dictionary];
        
        // =======================================================================
        // 进入主界面
        // =======================================================================
        
        MainVC *mainVC = [[MainVC alloc] initWithName:@"相伴教育"];
        [self.navigationController pushViewController:mainVC animated:YES];
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
            // 保存登录信息
            // =======================================================================
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            [dictionary setObjectSafe:_phoneNumberString forKey:kUserCellPhoneKey];
            [dictionary setObjectSafe:_pwdMd5 forKey:kUserPwdKey];
            [dictionary setObjectSafe:_pwdString forKey:kUserVisiblePwdKey];
            [dictionary setObjectSafe:_loginResult.userRole forKey:kUserRoleKey];
            [dictionary setObjectSafe:_loginResult.userId forKey:kUserIdKey];
            // 保存
            [[DataController getInstance] saveUserLoginInfo:dictionary];
            
            // =======================================================================
            // 进入主界面
            // =======================================================================
            
            MainVC *mainVC = [[MainVC alloc] initWithName:@"相伴教育"];
            [self.navigationController pushViewController:mainVC animated:YES];
            
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

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    // 未审核通过
    if (alertView.tag == eNoPassAuditAlertTag) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            
        }
        // 进入修改关联信息页面
        else
        {
            AlterAssociatedInforVC *searchPwdVC = [[AlterAssociatedInforVC alloc] initWithName:@"修改关联信息"];
            
            [searchPwdVC setUserId:_loginResult.userId];
            
            [self.navigationController pushViewController:searchPwdVC animated:YES];
        }
    }
    else
    {
        // 取消找回密码
        if (buttonIndex == alertView.cancelButtonIndex) {
            
        }
        // 找回密码
        else
        {
            SearchPwdVC *searchPwdVC = [[SearchPwdVC alloc] initWithName:@"找回密码"];
            [self.navigationController pushViewController:searchPwdVC animated:YES];
        }
    }
   
}

// 触碰隐藏键盘
- (void)dismissKeyboard
{
    if (_phoneTextField) {
        [_phoneTextField resignFirstResponder];
    }
    
    if (_pwdTextField) {
        [_pwdTextField resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //删除退格按钮
    if (string.length == 0) {
        return YES;
    }
    
    if (textField == _phoneTextField)
    {
        return [textField shouldChangeInRange:range withString:string andLength:11];
    }
    // 密码不能超过16位
    if (textField == _pwdTextField)
    {
        return [textField shouldChangeInRange:range withString:string andLength:16];
    }
    
    return YES;
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
