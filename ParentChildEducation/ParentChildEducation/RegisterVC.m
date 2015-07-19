//
//  RegisterNewVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/9.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "RegisterVC.h"
#import "RegisterAssociatedInforVC.h"
#import "PhoneCodeResult.h"

typedef NS_ENUM(NSInteger, ControllTag)
{
    eProtocolImageViewTag = 1,
    eSendPhoneCodeAlertViewTag,
};

#define kCellHeight                     54
#define kCellCount                      5

#define kTopMargin                      10
#define kLeftMargin                     17

// 验证码button
#define kPhoneCodeButtonHeight          37
#define kPhoneCodeButtonWidth           96

// 网络请求类型
#define kNewWorkTypeRegister            @"RegisterRequest"
#define kNewWorkTypeSendPhoneCode       @"SendPhoneCode"

@interface RegisterVC ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, NetworkPtc>

@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *phoneCodeTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *confirmPwdTextField;

@property (nonatomic, strong) UIButton *phoneCodeButton;
@property (nonatomic, strong) UIButton *registerButton;

@property (nonatomic, strong) NSString *phoneNumberString;
@property (nonatomic, strong) NSString *phoneCodeString;
@property (nonatomic, strong) NSString *pwdString;
@property (nonatomic, strong) NSString *confirmPwdString;

// 倒计时
@property (nonatomic, assign) NSInteger lessTime;			// 剩余时间的总秒数
@property (nonatomic, assign) CFRunLoopRef runLoop;			// 消息循环
@property (nonatomic, assign) CFRunLoopTimerRef	timer;      // 消息循环定时器

@property (nonatomic, assign) NSInteger protocolSelectCount;   // 阅读协议状态

@property (nonatomic, assign) BOOL phoneIsOk;
@property (nonatomic, assign) BOOL phoneCodeIsOk;
@property (nonatomic, assign) BOOL pwdIsOk;
@property (nonatomic, assign) BOOL pwdIsSame;

@end

@implementation RegisterVC

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _phoneIsOk = NO;
#warning 默认加载了验证码，供测试用，所以设置为YES
        _phoneCodeIsOk = YES;
        _pwdIsOk = NO;
        _pwdIsSame = NO;
    }
    
    return self;
}

- (void)dealloc
{
    if (_runLoop != nil && _timer != nil)
    {
        CFRunLoopTimerInvalidate(_timer);
        CFRunLoopRemoveTimer(_runLoop, _timer, kCFRunLoopCommonModes);
        [self setRunLoop:nil];
        [self setTimer:nil];
    }
    
    [self dismissKeyboard];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 显示状态栏
    [self.navigationController.navigationBar setHidden:NO];
    
    // 设置倒计时时间
    [self setLessTime:60];
    
    // 设置阅读协议状态
    _protocolSelectCount = 1;
    
    [self setupRootViewSubs:self.view];
}


- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // tableView
    // =======================================================================

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height-spaceYStart)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [viewParent addSubview:tableView];
    
    // 添加手势，触摸即键盘消失
    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc]                                                initWithTarget:self                                                 action:@selector(dismissKeyboard)];
    [tableView addGestureRecognizer:dismissKeyboardTap];
}

// PhoneCell
- (void)setupViewSubsPhoneCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    NSInteger spaceXEnd = viewParent.width;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // 调整Y
    spaceYStart += 1;
    // =======================================================================
    // 获取验证码
    // =======================================================================
    
    // 调整X
    spaceXStart = spaceXEnd-10-kPhoneCodeButtonWidth;
    
    if (_phoneCodeButton == nil)
    {
        UIButton *phoneCodeButton = [[UIButton alloc] initWithFont:kSmallTitleFont andTitle:@"获取验证码" andTtitleColor:kWhiteColor andCornerRadius:20.0];
        phoneCodeButton.backgroundColor = kBackgroundGreenColor;
        
        [phoneCodeButton addTarget:self action:@selector(getPhoneCode) forControlEvents:UIControlEventTouchUpInside];
        
        [viewParent addSubview:phoneCodeButton];
        _phoneCodeButton = phoneCodeButton;

    }
    _phoneCodeButton.frame = CGRectMake(spaceXStart, spaceYStart+(viewParent.height-kPhoneCodeButtonHeight)/2, kPhoneCodeButtonWidth, kPhoneCodeButtonHeight);
    
    // 重置XEnd
    spaceXEnd -= 10;
    spaceXEnd -= kPhoneCodeButtonWidth;
    
    // 重置X
    spaceXStart = kLeftMargin;
    
    // =======================================================================
    // 手机号输入
    // =======================================================================
    if (_phoneTextField == nil)
    {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [textField setTextColor:kTextColor];
        [textField setBackgroundColor:kWhiteColor];
        [textField setKeyboardType:UIKeyboardTypeNumberPad];
        [textField setFont:kSmallTitleFont];
        [textField setPlaceholder:@"请输入您的手机号"
                 placeholderColor:kTextColor
              placeholderFontSize:kSmallTitleFont];
        [textField setDelegate:self];
        [textField setClearsOnBeginEditing:NO];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyNext];
        [textField addTarget:self action:@selector(phoneChanged:) forControlEvents:UIControlEventEditingChanged];
        [textField addTarget:self action:@selector(phoneFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // 保存
        [viewParent addSubview:textField];
        
        _phoneTextField = textField;
    }
    [_phoneTextField setFrame:CGRectMake(spaceXStart, spaceYStart, spaceXEnd-spaceXStart, viewParent.height-spaceYStart)];
}

// 验证码cell
- (void)setupViewSubsPhoneCodeCell:(UIView *)viewParent inSize:(CGSize *)viewSize
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
    if (_phoneCodeTextField == nil)
    {
        UITextField *phoneCodeTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        
        [phoneCodeTextField setTextColor:kTextColor];
        [phoneCodeTextField setFont:kSmallTitleFont];
        [phoneCodeTextField setPlaceholder:@"填写验证码"
                          placeholderColor:kTextColor
                       placeholderFontSize:kSmallTitleFont];
        [phoneCodeTextField setDelegate:self];
        [phoneCodeTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [phoneCodeTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [phoneCodeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [phoneCodeTextField setReturnKeyType:UIReturnKeyDone];
        [phoneCodeTextField addTarget:self action:@selector(phoneCodeChanged:) forControlEvents:UIControlEventEditingChanged];
        [phoneCodeTextField addTarget:self action:@selector(phoneCodeFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // 保存
        [viewParent addSubview:phoneCodeTextField];
        
        _phoneCodeTextField = phoneCodeTextField;
    }
    
    [_phoneCodeTextField setFrame:CGRectMake(kLeftMargin, spaceYStart, viewParent.width-kLeftMargin, viewParent.height-spaceYStart)];

}

// 密码cell
- (void)setupViewSubsPwdCell:(UIView *)viewParent inSize:(CGSize *)viewSize
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
        [phoneCodeTextField setPlaceholder:@"设置密码，需为6-16位字符"
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
- (void)setupViewSubsConfirmPwdCell:(UIView *)viewParent inSize:(CGSize *)viewSize
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
        [phoneCodeTextField setPlaceholder:@"确认密码，请再次确认密码"
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

// 协议
- (void)setupViewSubsProtocolCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 协议
    // =======================================================================
    
    // image 14*11
    spaceYStart += 10;
    spaceXStart += 10;
    
    // image背景
    UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, 18, 18)];
    backGroundView.backgroundColor = [UIColor whiteColor];
    backGroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    backGroundView.layer.borderWidth = 0.5;
    [viewParent addSubview:backGroundView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"protocol"]];
    imageView.frame = CGRectMake((backGroundView.width-14)/2, (backGroundView.height-12)/2, 14, 12);
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.tag = eProtocolImageViewTag;
    [backGroundView addSubview:imageView];
    
    // =======================================================================
    // 默认勾选
    // =======================================================================

    // 偶数次未选中
    if (_protocolSelectCount%2 == 0) {
        [imageView setImage:[UIImage imageNamed:@"protocol"]];
    }
    // 奇数次选中
    else {
        [imageView setImage:[UIImage imageNamed:@"protocolSelect"]];
    }

    
    // 添加手势
    UITapGestureRecognizer *protocolGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doProtocolAction:)];
    [backGroundView addGestureRecognizer:protocolGesture];
    
    
    // 调整X
    spaceXStart += 20;
    
    // label
    NSString *protocolString = @"我已阅读并接受《服务协议》";
    UILabel *protocolLabel = [[UILabel alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, 14*protocolString.length, viewParent.height-10)];
    protocolLabel.text = protocolString;
    protocolLabel.font = kMiddleFont;
    protocolLabel.textColor = kTextColor;
    protocolLabel.backgroundColor = [UIColor clearColor];
    [viewParent addSubview:protocolLabel];
}

// foot
- (void)setupTableFootSubs:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 0;
    
    // 调整Y
    spaceYStart += 43;
    
    // =======================================================================
    // 注册
    // =======================================================================
    if (viewParent != nil)
    {
        UIButton *registerButton = [[UIButton alloc] initWithFont:kLargeTitleFont andTitle:@"注册" andTtitleColor:kWhiteColor andCornerRadius:20.0];
        registerButton.backgroundColor = [UIColor lightGrayColor];
        
        registerButton.frame = CGRectMake(40, spaceYStart, viewParent.width-40*2, kButtonHeight);
        [registerButton addTarget:self action:@selector(doRegisterAction) forControlEvents:UIControlEventTouchUpInside];
        // 默认置灰
        [registerButton setEnabled:NO];
        
        [viewParent addSubview:registerButton];
        
        _registerButton = registerButton;
    }
    
    
    // 调整Y
    spaceYStart += kButtonHeight;
    spaceYStart += 10;
    
    viewSize->height = spaceYStart;
    
    if (viewParent != nil)
    {
        [viewParent setViewHeight:spaceYStart];
    }
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGSize viewRootSize = CGSizeMake(tableView.width, 0);
    [self setupTableFootSubs:nil inSize:&viewRootSize];
    
    return viewRootSize.height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return kCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger curRow = 0;
    
    // 手机号
    if (curRow == row) {
        NSString *reusedIdentifier = @"RegisterVCPhoneID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.contentView setBackgroundColor:kWhiteColor];
        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kCellHeight);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsPhoneCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    // 验证码
    if (curRow == row) {
        NSString *reusedIdentifier = @"RegisterVCPhoneCodeID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kCellHeight);
        [cell.contentView setSize:contentViewSize];

        [self setupViewSubsPhoneCodeCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    //  密码
    if (curRow == row) {
        NSString *reusedIdentifier = @"RegisterVCPwdID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kCellHeight);
        [cell.contentView setSize:contentViewSize];

        [self setupViewSubsPwdCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    // 确认密码
    if (curRow == row) {
        NSString *reusedIdentifier = @"RegisterVCConfirmPwdID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kCellHeight);
        [cell.contentView setSize:contentViewSize];

        [self setupViewSubsConfirmPwdCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    // =======================================================================
    // 协议
    // =======================================================================
    if (curRow == row) {
        NSString *reusedIdentifier = @"RegisterVCProtocolID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.contentView setBackgroundColor:kBackgroundColor];
        }
        CGSize contentViewSize = CGSizeMake(tableView.width, 30);
        [cell.contentView setSize:contentViewSize];

        [self setupViewSubsProtocolCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // 创建根View
    CGSize viewRootSize = CGSizeMake(tableView.width, 0);
    
    UIView *viewRoot = [[UIView alloc] initWithFrame:CGRectZero];
    [viewRoot setFrame:CGRectMake(0, 0, viewRootSize.width, viewRootSize.height)];
    
    // 创建根View的子界面
    [self setupTableFootSubs:viewRoot inSize:&viewRootSize];
    
    return viewRoot;

}

#pragma mark - 事件处理
// 手机号码
- (void)phoneChanged:(UITextField *)textField
{
    // 保存文本
    _phoneNumberString = [(UITextField *)textField text];
    
    if ([_phoneNumberString isStringSafe] && _phoneNumberString.length == 11) {
        _phoneIsOk = YES;
    }
    else
    {
        _phoneIsOk = NO;
    }
    
    [self setCanRegister];
    
}

- (void)phoneFinished:(id)sender
{
    UITextField *textFieldMobile = (UITextField *)sender;
    
    [textFieldMobile resignFirstResponder];
    
}

// 验证码
- (void)phoneCodeChanged:(id)sender
{
    // 保存文本
    _phoneCodeString = [(UITextField *)sender text];
    
    if ([_phoneCodeString isStringSafe]) {
        _phoneCodeIsOk = YES;
    }
    else
    {
        _phoneCodeIsOk = NO;
    }
    [self setCanRegister];

}

- (void)phoneCodeFinished:(id)sender
{
    UITextField *textFieldMobile = (UITextField *)sender;
    
    [textFieldMobile resignFirstResponder];
    
}

// 密码
- (void)passwordChanged:(id)sender
{
    // 保存文本
    _pwdString = [(UITextField *)sender text];
    
    if ([_pwdString isStringSafe] && _pwdString.length >5)
    {
        _pwdIsOk = YES;
    }
    else
    {
        _pwdIsOk = NO;
    }
    
    if ([_confirmPwdString isEqualToString:_pwdString])
    {
        _pwdIsSame = YES;
    }
    else{
        _pwdIsSame = NO;
    }
    [self setCanRegister];
}

- (void)passwordFinished:(id)sender
{
    UITextField *textFieldMobile = (UITextField *)sender;
    
    [textFieldMobile resignFirstResponder];
    
}

// 确认密码
- (void)confirmPwdChanged:(id)sender
{
    // 保存文本
    _confirmPwdString = [(UITextField *)sender text];
    
    if (_confirmPwdString.length >5 && [_confirmPwdString isEqualToString:_pwdString])
    {
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
    UITextField *textFieldMobile = (UITextField *)sender;
    
    [textFieldMobile resignFirstResponder];
    
}

// 判断是否可注册
- (void)setCanRegister
{
    if (_phoneIsOk && _pwdIsOk && _pwdIsSame && _phoneCodeIsOk && _protocolSelectCount%2 == 1) {
        [_registerButton setBackgroundColor:kBackgroundGreenColor];
        [_registerButton setEnabled:YES];
    }
    else
    {
        [_registerButton setBackgroundColor:[UIColor lightGrayColor]];
        [_registerButton setEnabled:NO];
    }
}

// 注册
- (void)doRegisterAction
{
    // 校验手机号
    if (![_phoneNumberString isStringSafe] || ![_pwdString isStringSafe])
    {
        NSString *errorInfo;
        if (![_phoneNumberString isStringSafe])
        {
            errorInfo = @"请输入手机号";
        }
        else
        {
            if (![_pwdString isStringSafe]) {
                errorInfo = @"请输入密码";
            }
        }
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorInfo delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alertView.backgroundColor = [UIColor whiteColor];
        [alertView show];
        
    }
    else if (_phoneNumberString.length < 11)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入有效的手机号码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if (_pwdString.length < 6)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码长度必须大于6" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else  if (![_pwdString isEqualToString:_confirmPwdString]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"两次密码输入不一致" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }

   [self loadingAnimation];
    
    // =======================================================================
    // 参数：cellPhone：手机号  authCode:短信验证码  password：密码
    // =======================================================================
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode(_phoneNumberString) forKey:@"cellPhone"];
    [parameters setObjectSafe:base64Encode(_phoneCodeString) forKey:@"authCode"];
    
    // 用当前时间戳做key
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *keyString = [NSString stringWithFormat:@"%llu", recordTime];
    NSLog(@"===========================%llu", recordTime);
    
    // 密码MD5
    NSString *pwdMd5 = [[NSString stringWithFormat:@"%llu%@", recordTime, _pwdString] getMD5];
    [parameters setObjectSafe:base64Encode(pwdMd5) forKey:@"password"];
    // salt
    [parameters setObjectSafe:base64Encode(keyString) forKey:@"salt"];

    // 请求
    [NetWorkTask postRequest:kRequestRegisterCheckPwd
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestRegisterCheckPwd];
}

// 获取验证码
- (void)getPhoneCode
{
    if (!_phoneIsOk)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入有效手机号" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self loadingAnimation];
        
        // =======================================================================
        // 发送验证码，回调中处理，成功提示发送成功，并开始[self timerStart];失败则提示重新发送
        // =======================================================================
        
        // 参数
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObjectSafe:base64Encode(_phoneNumberString) forKey:@"cellPhone"];
        
        [NetWorkTask postRequest:kRequestSendPhoneCodeOfRegister
                     forParamDic:parameters
                    searchResult:[[PhoneCodeResult alloc] init]
                     andDelegate:self forInfo:kRequestSendPhoneCodeOfRegister];
    }
}

#pragma mark - 倒计时
// 启动消息循环定时器
- (void)timerStart
{
    // 创建消息循环定时器
    _runLoop = CFRunLoopGetCurrent();
    CFRunLoopTimerContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    _timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 1, 1.0, 0, 0,
                                  &findHRedEnvelopePhoneCodeCFTimerCallback, &context);
    
    CFRunLoopAddTimer(_runLoop, _timer, kCFRunLoopCommonModes);
}

// 时钟回调函数
void findHRedEnvelopePhoneCodeCFTimerCallback(CFRunLoopTimerRef timer, void *info)
{
    // 剩余时间减1
    RegisterVC *registerNewVC = (__bridge id)info;
    
    // 时间秒数减1
    [registerNewVC setLessTime:[registerNewVC lessTime] - 1];
    
    // 更新倒计时时间
    [registerNewVC updateLessTime];
    
    if ([registerNewVC lessTime] <= 0)
    {
        CFRunLoopRemoveTimer([registerNewVC runLoop], [registerNewVC timer], kCFRunLoopCommonModes);
        [registerNewVC setRunLoop:nil];
        [registerNewVC setTimer:nil];
    }
}

// 更新剩余时间
- (void)updateLessTime
{
    if (_phoneCodeButton != nil)
    {
        UIButton *buttonLessTime = _phoneCodeButton;
        
        if(_lessTime > 0)
        {
            NSString *lessTimeTmp = [[NSString alloc] initWithFormat:@"重新获取 %lds", (long)_lessTime];
            [buttonLessTime setTitle:lessTimeTmp forState:UIControlStateDisabled];
            [buttonLessTime setBackgroundColor:[UIColor grayColor]];
            [buttonLessTime setEnabled:NO];
        }
        else
        {
            NSString *lessTimeTmp = [[NSString alloc] initWithFormat:@"重新获取"];
            [buttonLessTime setTitle:lessTimeTmp forState:UIControlStateNormal];
            [buttonLessTime setEnabled:YES];
            [buttonLessTime setBackgroundColor:kBackgroundGreenColor];
        }
    }
    
}

#pragma mark - 网络请求回调
// 获取网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo;
{
    [self stopLoadingAnimation];
    
    // 注册回调
    if ([customInfo isEqualToString:kRequestRegisterCheckPwd]) {
        
        [self getSearchNetBackWithRegister:searchResult];
        
    }
    // 发送验证码回调
    else if ([customInfo isEqualToString:kRequestSendPhoneCodeOfRegister])
    {
        [self getSearchNetBackWithSendPhoneCode:searchResult];
    }
}

// 发送验证码请求回调
- (void)getSearchNetBackWithSendPhoneCode:(id)searchResult
{
    [self stopLoadingAnimation];
    
    if (searchResult != nil)
    {
        PhoneCodeResult *result = searchResult;
        
        // 发送成功
        if ([result.status intValue] == 0)
        {
            if ([result.isSuccess integerValue] == 0)
            {
#warning 方便用户测试
                _phoneCodeString = result.identifyCode;
                _phoneCodeTextField.text = _phoneCodeString;
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = eSendPhoneCodeAlertViewTag;
                
                [alertView show];
                
            }
            else
            {
                NSString *errorMsg = @"发送失败";
                if ([result.businessMsg isKindOfClass:[NSString class]] && [result.msg isStringSafe])
                {
                    errorMsg = result.businessMsg;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }
        else
        {
            NSString *errorMsg = @"网络异常，请稍后再试";
            if ([result.msg isKindOfClass:[NSString class]] && [result.msg isStringSafe])
            {
                errorMsg = result.msg;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 注册回调
- (void)getSearchNetBackWithRegister:(SearchNetResult *)searchResult
{
    [self stopLoadingAnimation];

    if (searchResult != nil) {
        // 注册成功
        if ([searchResult.status intValue] == 0)
        {
            BusinessSearchNetResult *result = (BusinessSearchNetResult *)searchResult;
            
            if ([result.isSuccess integerValue] == 0)
            {
                // 保存最近一次输入的电话号码
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [dictionary setObjectSafe:_phoneNumberString
                                   forKey:kUserCellPhoneKey];
                [[DataController getInstance] saveUserLoginInfo:dictionary];
                
                // 进入关联信息页面
                RegisterAssociatedInforVC *registerAssociatedInforVC = [[RegisterAssociatedInforVC alloc] initWithName:@"关联信息"];
                registerAssociatedInforVC.parentCellPhone = _phoneNumberString;
                
                [self.navigationController pushViewController:registerAssociatedInforVC animated:YES];
            }
            else
            {
                NSString *errorMsg;
                if ([result.businessMsg isStringSafe]) {
                    errorMsg = result.businessMsg;
                }
                else {
                    errorMsg = @"注册失败";
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:result.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView show];
                
                [_phoneCodeButton setTitle:@"重新发送" forState:UIControlStateNormal];
                
            }
            
        }
        // 失败
        else
        {
            NSString *errorMsg;
            if ([searchResult.msg isKindOfClass:[NSString class]] &&[searchResult.msg isStringSafe]) {
                errorMsg = searchResult.msg;
            }
            else {
                errorMsg = @"注册失败";
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常，请联系后台管理员" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 请求失败回调
- (void)getSearchNetBackWithFailure:(id)customInfo;
{
    [self stopLoadingAnimation];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
   
}

// 阅读协议选择状态
- (void)doProtocolAction:(UIGestureRecognizer *)gesture
{
    // 增加选中次数
    _protocolSelectCount++;
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:eProtocolImageViewTag];

    // 偶数次未选中
    if (_protocolSelectCount%2 == 0) {
        [imageView setImage:[UIImage imageNamed:@"protocol"]];
    }
    // 奇数次选中
    else {
        [imageView setImage:[UIImage imageNamed:@"protocolSelect"]];
    }
    
    [self setCanRegister];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
    switch (tag)
    {
        case eSendPhoneCodeAlertViewTag:
        {
            [self timerStart];
            break;
        }
        default:
            break;
    }
    
}

// 触碰隐藏键盘
- (void)dismissKeyboard
{
    if (_phoneTextField) {
        [_phoneTextField resignFirstResponder];
    }
    
    if (_phoneCodeTextField)
    {
        [_phoneCodeTextField resignFirstResponder];
    }
    if (_pwdTextField) {
        [_pwdTextField resignFirstResponder];
    }
    if (_confirmPwdTextField) {
        [_confirmPwdTextField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
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
    
    // 验证码不超过10位
    if (textField == _phoneCodeTextField)
    {
        return [textField shouldChangeInRange:range withString:string andLength:10];
    }
    
    // 密码不能超过16位
    if (textField == _pwdTextField)
    {
        return [textField shouldChangeInRange:range withString:string andLength:16];
    }
    
    if (textField == _confirmPwdTextField)
    {
        return [textField shouldChangeInRange:range withString:string andLength:16];
    }
    
    return YES;
}

@end
