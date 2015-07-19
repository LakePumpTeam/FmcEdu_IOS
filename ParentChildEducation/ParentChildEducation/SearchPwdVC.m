//
//  SearchPwdVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/12.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchPwdVC.h"
#import "LoginVC.h"
#import "PhoneCodeResult.h"
#import "SaltResult.h"

typedef NS_ENUM(NSInteger, ControllTag)
{
    eProtocolImageViewTag = 1,
    eSendPhoneCodeAlertViewTag,
    eSubmitSuccessTag,              // 重置成功alert
    eFailureAlertTag,
};

typedef NS_ENUM(NSInteger, CellType)
{
    ePhoneCellType = 0,
    ePhoneCodeCellType,
    ePwdCellType,              // 重置成功alert
    eConfirmPwdCellType,
    eSubmitCellType
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

@interface SearchPwdVC ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, NetworkPtc>

@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *phoneCodeTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *confirmPwdTextField;
@property (nonatomic, strong) UIButton *phoneCodeButton;
@property (nonatomic, strong) UIButton *submitButton;

@property (nonatomic, strong) NSString *phoneNumberString;
@property (nonatomic, strong) NSString *phoneCodeString;
@property (nonatomic, strong) NSString *pwdString;
@property (nonatomic, strong) NSString *confirmPwdString;

// 倒计时
@property (nonatomic, assign) NSInteger lessTime;			// 剩余时间的总秒数
@property (nonatomic, assign) CFRunLoopRef runLoop;			// 消息循环
@property (nonatomic, assign) CFRunLoopTimerRef	timer;      // 消息循环定时器

@property (nonatomic, assign) BOOL phoneIsOk;
@property (nonatomic, assign) BOOL phoneCodeIsOk;
@property (nonatomic, assign) BOOL pwdIsSame;

@property (nonatomic, strong) NSString *saltString;

@end

@implementation SearchPwdVC

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _phoneIsOk = NO;
#warning 默认加载了验证码，供测试用，所以设置为YES
        _phoneCodeIsOk = YES;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 显示状态栏
    [self.navigationController.navigationBar setHidden:NO];
    
    // 设置倒计时时间
    [self setLessTime:60];
    
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
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    
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
        UIButton *phoneCodeButton = [[UIButton alloc] initWithFont:kMiddleFont andTitle:@"获取验证码" andTtitleColor:kWhiteColor andCornerRadius:20.0];
        phoneCodeButton.backgroundColor = kBackgroundGreenColor;
        
        [phoneCodeButton addTarget:self action:@selector(getPhoneCode) forControlEvents:UIControlEventTouchUpInside];
        
        [viewParent addSubview:phoneCodeButton];
        _phoneCodeButton = phoneCodeButton;
        
    }
    _phoneCodeButton.frame = CGRectMake(spaceXStart, spaceYStart+(kCellHeight-kPhoneCodeButtonHeight)/2, kPhoneCodeButtonWidth, kPhoneCodeButtonHeight);
    
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
        [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [textField setReturnKeyType:UIReturnKeyNext];
        [textField addTarget:self action:@selector(phoneChanged:) forControlEvents:UIControlEventEditingChanged];
        [textField addTarget:self action:@selector(phoneFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // 保存
        [viewParent addSubview:textField];
        
        _phoneTextField = textField;
    }
    [_phoneTextField setFrame:CGRectMake(spaceXStart, spaceYStart, spaceXEnd-spaceXStart, kCellHeight-spaceYStart)];
    
    NSMutableDictionary *dictionary = [[DataController getInstance] getUserLoginInfo];

    _phoneNumberString = [dictionary objectForKey:kUserCellPhoneKey];
    _phoneTextField.text = _phoneNumberString;
    
    if (_phoneNumberString.length == 11)
    {
        _phoneIsOk = YES;
    }
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
        [phoneCodeTextField setKeyboardType:UIKeyboardTypeNumberPad];
        [phoneCodeTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [phoneCodeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [phoneCodeTextField setReturnKeyType:UIReturnKeyDone];
        [phoneCodeTextField addTarget:self action:@selector(phoneCodeChanged:) forControlEvents:UIControlEventEditingChanged];
        [phoneCodeTextField addTarget:self action:@selector(phoneCodeFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        // 保存
        [viewParent addSubview:phoneCodeTextField];
        
        _phoneCodeTextField = phoneCodeTextField;
    }
    
    [_phoneCodeTextField setFrame:CGRectMake(kLeftMargin, spaceYStart, viewParent.width-kLeftMargin, viewParent.height-1)];
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
    // 验证码输入
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
    // 确认密码
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
}

// 提交
- (void)setupViewSubsSubmit:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 0;
    
    // =======================================================================
    // 提交
    // =======================================================================
    
    // 调整Y
    spaceYStart += 73;
    
    UIButton *submitButton = [[UIButton alloc] initWithFont:[UIFont systemFontOfSize:20] andTitle:@"提交" andTtitleColor:kWhiteColor andCornerRadius:20.0];
    submitButton.backgroundColor = [UIColor lightGrayColor];
    
    submitButton.frame = CGRectMake(40, spaceYStart, kScreenWidth-40*2, kButtonHeight);
    [submitButton addTarget:self action:@selector(doSubmitAction) forControlEvents:UIControlEventTouchUpInside];
    [submitButton setEnabled:NO];
    
    [viewParent addSubview:submitButton];
    
    _submitButton = submitButton;

}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == eSubmitCellType)
    {
        return kCellHeight + 73;
    }
    else
    {
        return kCellHeight;
    }
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
        NSString *reusedIdentifier = @"SearchVCPhoneID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];
        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kCellHeight);
        [cell.contentView setSize:contentViewSize];
        
        [self setupViewSubsPhoneCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    // 验证码
    if (curRow == row) {
        NSString *reusedIdentifier = @"SearchVCPhoneCodeID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kCellHeight);
        [cell.contentView setSize:contentViewSize];
        
        [self setupViewSubsPhoneCodeCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    // 密码
    if (curRow == row) {
        NSString *reusedIdentifier = @"SearchPwdID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        NSString *reusedIdentifier = @"SearchConfirmPwdID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kCellHeight);
        [cell.contentView setSize:contentViewSize];

        [self setupViewSubsConfirmPwdCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    // 提交
    if (curRow == row) {
        NSString *reusedIdentifier = @"SearchPwdSubmitID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            [cell.contentView setBackgroundColor:kBackgroundColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kButtonHeight+73);
        [cell.contentView setSize:contentViewSize];
        
        [self setupViewSubsSubmit:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - 事件处理
// 判断是否可注册
- (void)setCanRegister
{
    if (_phoneIsOk && _pwdIsSame && _phoneCodeIsOk) {
        [_submitButton setBackgroundColor:kBackgroundGreenColor];
        [_submitButton setEnabled:YES];
    }
    else
    {
        [_submitButton setBackgroundColor:[UIColor lightGrayColor]];
        [_submitButton setEnabled:NO];
    }
}

// 手机号码
- (void)phoneChanged:(id)sender
{
    // 保存文本
    _phoneNumberString = [(UITextField *)sender text];
    
    if (_phoneNumberString.length == 11)
    {
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
    
    if ([_phoneCodeString isStringSafe])
    {
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
    
    if (_pwdString.length > 5 && [_pwdString isEqualToString:_confirmPwdString])
    {
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
    
    if (_confirmPwdString.length > 5 && [_pwdString isEqualToString:_confirmPwdString])
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
    
}

// 提交
- (void)doSubmitAction
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

- (void)getSubmitRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 参数：cellPhone：手机号  authCode:短信验证码  password：密码
    // =======================================================================
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode(_phoneNumberString) forKey:@"cellPhone"];
    [parameters setObjectSafe:base64Encode(_phoneCodeString) forKey:@"authCode"];
    
    // salt+密码MD5
    NSString *pwdMd5 = [[NSString stringWithFormat:@"%@%@", _saltString, _pwdString] getMD5];
    [parameters setObjectSafe:base64Encode(pwdMd5) forKey:@"password"];
    
    // 请求
    [NetWorkTask postRequest:kRequestSearchPwd
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestSearchPwd];
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
                                  &findSearchPwdVCPhoneCodeCFTimerCallback, &context);
    
    CFRunLoopAddTimer(_runLoop, _timer, kCFRunLoopCommonModes);
}

// 时钟回调函数
void findSearchPwdVCPhoneCodeCFTimerCallback(CFRunLoopTimerRef timer, void *info)
{
    // 剩余时间减1
    SearchPwdVC *registerNewVC = (__bridge id)info;
    
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
    
    // 提交密码回调
    if ([customInfo isEqualToString:kRequestSearchPwd]) {
        
        [self getSearchNetBackWithRegister:searchResult];
    }
    // 发送验证码回调
    else if ([customInfo isEqualToString:kRequestSendPhoneCodeOfRegister])
    {
        [self getSearchNetBackWithSendPhoneCode:searchResult];
    }
    // 请求salt
    else if ([customInfo isEqualToString:kRequestLoginSalt])
    {
        [self getSearchNetBackOfSalt:searchResult forInfo:customInfo];
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

// 发送验证码请求回调
- (void)getSearchNetBackWithSendPhoneCode:(id)searchResult
{
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
                NSString *errorMsg;
                if ([result.businessMsg isStringSafe]) {
                    errorMsg = result.businessMsg;
                }
                else {
                    errorMsg = @"发送验证码失败，请重新发送";
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:result.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = eFailureAlertTag;
                
                [alertView show];
            }
            
            
        }
        // 发送失败
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常，请联系后台管理员" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

// 找回密码回调
- (void)getSearchNetBackWithRegister:(SearchNetResult *)searchResult
{
    // 重置成功
    if ([searchResult.status intValue] == 0)
    {
        BusinessSearchNetResult *result = (BusinessSearchNetResult *)searchResult;
        
        if ([result.isSuccess integerValue] == 0)
        {
            NSString *successMsg = @"重置成功，请重新登陆";
            if ([result.businessMsg isStringSafe])
            {
                successMsg = result.businessMsg;
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:successMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alertView.tag = eSubmitSuccessTag;
            
            [alertView show];
        }
        else
        {
            NSString *errorMsg;
            if ([result.businessMsg isStringSafe]) {
                errorMsg = result.businessMsg;
            }
            else {
                errorMsg = @"重置密码失败，请稍后再试";
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alertView.tag = eFailureAlertTag;
            
            [alertView show];
        }
        
    }
    // 失败
    else
    {
       
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常，请联系后台管理员" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 请求失败回调
- (void)getSearchNetBackWithFailure:(id)customInfo
{
    [self stopLoadingAnimation];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    alertView.tag = eFailureAlertTag;
    
    [alertView show];
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger tag = alertView.tag;
    
    // 发送验证码成功
    if (tag == eSendPhoneCodeAlertViewTag)
    {
        [self timerStart];
    }
    // 重置密码成功，返回登陆
    else if (tag == eSubmitSuccessTag)
    {
        LoginVC *login = [[LoginVC alloc] initWithName:@"登陆"];
        [self.navigationController pushViewController:login animated:YES];
    }
    // 失败
    else if (tag == eFailureAlertTag)
    {
        [_phoneCodeButton setTitle:@"重新发送" forState:UIControlStateNormal];
        [_phoneCodeButton setBackgroundColor:kBackgroundGreenColor];
        
        if (_runLoop != nil && _timer != nil)
        {
            CFRunLoopTimerInvalidate(_timer);
            CFRunLoopRemoveTimer(_runLoop, _timer, kCFRunLoopCommonModes);
            [self setRunLoop:nil];
            [self setTimer:nil];
        }
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
