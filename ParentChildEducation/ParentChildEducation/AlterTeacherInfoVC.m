//
//  AlterTeacherInfoVC.m
//  
//
//  Created by zlan.zhang on 15/5/12.
//
//

#import "AlterTeacherInfoVC.h"
#import "BirthdayVC.h"
#import "TeacherInfoResult.h"
#import "RadioButton.h"

typedef NS_ENUM(NSInteger, ControllerTag)
{
    eSubmitSuccessAlertTag = 100 ,
};

#define kTextFieldLMargin           25

@interface AlterTeacherInfoVC ()<UITextFieldDelegate, UITextViewDelegate, BirthdayVCDelegate, NetworkPtc, UITextViewDelegate, UIScrollViewDelegate, RadioButtonDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) __block UILabel *birthLabel;
@property (nonatomic, strong) UILabel *sexTitleLabel;

@property (nonatomic, strong) BirthdayVC *birthdayVC;

@property (nonatomic, strong) NSString *teacherName;
@property (nonatomic, strong) NSString *courseName;
@property (nonatomic, strong) NSString *teacherBirth;
@property (nonatomic, strong) NSString *teacherCellPhone;
@property (nonatomic, strong) NSString *teacherResume;

@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *courseTextField;
@property (nonatomic, strong) UITextField *cellPhoneTextField;
@property (nonatomic, strong) UITextView *resumeTextView;

@property (nonatomic, strong) RadioButton *radioBoy;
@property (nonatomic, strong) RadioButton *radioGirl;

@property (nonatomic, strong) TeacherInfoResult *teacherInfoResult;

@property (nonatomic, assign) BOOL teacherSex;
;
@end

@implementation AlterTeacherInfoVC

- (id)init
{
    self = [super init];
    if (self)
    {
        // 默认男
        _teacherSex = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // =======================================================================
    // 内容视图
    // =======================================================================
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    scrollView.backgroundColor = kBackgroundColor;
    [self.view addSubview:scrollView];
    
    scrollView.delegate = self;
    
    [self setupRootViewSubs:scrollView];
    
    [self getSearchTeacherInfo];
}

- (void)setupRootViewSubs:(UIScrollView *)viewParent
{
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 姓名
    // =======================================================================
    UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    nameView.backgroundColor = kWhiteColor;
    [viewParent addSubview:nameView];
    
    [self setupViewSubsName:nameView];
    
    // 调整Y
    spaceYStart += nameView.height;
    
    // =======================================================================
    // 性别
    // =======================================================================
    UIView *sexView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    sexView.backgroundColor = kWhiteColor;
    [viewParent addSubview:sexView];
    
    [self setupViewSubsWithRadioButton:sexView forTitle:@"性别"];
    
    // 调整Y
    spaceYStart += sexView.height;
    
    // =======================================================================
    // 所授课程
    // =======================================================================
    UIView *causeView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    causeView.backgroundColor = kWhiteColor;
    [viewParent addSubview:causeView];
    
    [self setupViewSubsCourse:causeView];
    
    // 调整Y
    spaceYStart += causeView.height;

    // =======================================================================
    // 出生年月：选择日历
    // =======================================================================
    UIView *birthView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    birthView.backgroundColor = kWhiteColor;
    [viewParent addSubview:birthView];
    
    [self setupViewSubsBirth:birthView];
    
    // 调整Y
    spaceYStart += birthView.height;
    
    // =======================================================================
    // 电话
    // =======================================================================
    UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    phoneView.backgroundColor = kWhiteColor;
    [viewParent addSubview:phoneView];
    
    [self setupViewSubsPhone:phoneView];
    
    // 调整Y
    spaceYStart += phoneView.height;
    
    // 调整Y
    spaceYStart += 11;
    
    // =======================================================================
    // 履历
    // =======================================================================
    UIView *resumeView = [[UIView alloc] initWithFrame:CGRectMake(10, spaceYStart, viewParent.width-20, 200)];
    [viewParent addSubview:resumeView];
    
    [self setupViewSubsResume:resumeView];
    
    // 调整Y
    spaceYStart += resumeView.height;
    spaceYStart += 54;
    
    // =======================================================================
    // 提交
    // =======================================================================
    UIButton *logOutBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [logOutBtn setTitle:@"提交" forState:UIControlStateNormal];
    [logOutBtn addTarget:self action:@selector(doSubmitAction) forControlEvents:UIControlEventTouchUpInside ];
    logOutBtn.titleLabel.font=kSmallTitleFont;
    logOutBtn.frame = CGRectMake(40, spaceYStart, viewParent.width - 40*2, 40) ;
    logOutBtn.tintColor = [UIColor whiteColor];
    logOutBtn.backgroundColor = kBackgroundGreenColor;
    logOutBtn.layer.cornerRadius = 20;
    [viewParent addSubview:logOutBtn];
    
    // 调整Y
    spaceYStart += logOutBtn.height;
    spaceYStart += 50;
    
    if (spaceYStart > viewParent.height)
    {
        [viewParent setContentSize:CGSizeMake(viewParent.width, spaceYStart)];
    }
    else
    {
        [viewParent setContentSize:CGSizeMake(viewParent.width, viewParent.height)];
    }
    
    if (kSystemVersion < 7) {
        if (spaceYStart > viewParent.height)
        {
            [viewParent setContentSize:CGSizeMake(viewParent.width, spaceYStart+kNavigationBarHeight)];
        }
        else
        {
            [viewParent setContentSize:CGSizeMake(viewParent.width, viewParent.height+kNavigationBarHeight)];
        }
    }

}

// 姓名
- (void)setupViewSubsName:(UIView *)viewParent
{
    // =======================================================================
    // 顶部分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // =======================================================================
    // 输入view
    // =======================================================================
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:@"姓名"
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
    [textField setTextColor:kTextColor];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField addTarget:self action:@selector(nameChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(nameFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField setFrame:CGRectMake(kTextFieldLMargin, 1, viewParent.width-kTextFieldLMargin, viewParent.height-1)];
    // 保存
    [viewParent addSubview:textField];
    
    _nameTextField = textField;
}

// 性别：单选框
- (void)setupViewSubsWithRadioButton:(UIView *)viewParent forTitle:(NSString *)initTitle
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
    
    _sexTitleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"性别" andColor:kTextColor];
    _sexTitleLabel.textAlignment = NSTextAlignmentLeft;
    _sexTitleLabel.frame = CGRectMake(kTextFieldLMargin, 1, 35, kCellHeight-1);
    [viewParent addSubview:_sexTitleLabel];
    
    
    // 单选框
    RadioButton *radio1 = [[RadioButton alloc] initWithDelegate:self groupId:@"groupId1"];
    radio1.frame = CGRectMake(98, (kCellHeight-40)/2, 50, 40);
    [radio1 setTitle:@"男" forState:UIControlStateNormal];
    [radio1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [radio1.titleLabel setFont:kSmallTitleFont];
    [viewParent addSubview:radio1];
    _radioBoy = radio1;
    
    // 设置选中
    [radio1 setChecked:YES];
    
    RadioButton *radio2 = [[RadioButton alloc] initWithDelegate:self groupId:@"groupId1"];
    radio2.frame = CGRectMake(168, (kCellHeight-40)/2, 50, 40);
    [radio2 setTitle:@"女" forState:UIControlStateNormal];
    [radio2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [radio2.titleLabel setFont:kSmallTitleFont];
    [viewParent addSubview:radio2];
    
    _radioGirl = radio2;
}

// 所授课程
- (void)setupViewSubsCourse:(UIView *)viewParent
{
    // =======================================================================
    // 顶部分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // =======================================================================
    // 输入view
    // =======================================================================
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:@"所授课程"
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
    [textField setTextColor:kTextColor];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField addTarget:self action:@selector(causeChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(causeFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField setFrame:CGRectMake(kTextFieldLMargin, 1, viewParent.width-kTextFieldLMargin, viewParent.height-1)];
    // 保存
    [viewParent addSubview:textField];
    
    _courseTextField = textField;
}

// 出生年月
- (void)setupViewSubsBirth:(UIView *)viewParent
{
    // =======================================================================
    // 顶部分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // =======================================================================
    // 出生年月
    // =======================================================================
    
    _birthLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"出生年月" andColor:kTextColor];
    _birthLabel.textAlignment = NSTextAlignmentLeft;
    _birthLabel.frame = CGRectMake(kTextFieldLMargin, 1, kScreenWidth-kTextFieldLMargin, kCellHeight-1);
    [viewParent addSubview:_birthLabel];
    
    UIButton *birthButton = [[UIButton alloc] init];
    birthButton.frame = _birthLabel.frame;
    birthButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [birthButton addTarget:self action:@selector(doSelectCalendar:) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:birthButton];
}

// 电话号码
- (void)setupViewSubsPhone:(UIView *)viewParent
{
    // =======================================================================
    // 顶部分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // 输入
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:@"电话号码"
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
    [textField setTextColor:kTextColor];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField addTarget:self action:@selector(phoneChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(phoneFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField setFrame:CGRectMake(kTextFieldLMargin, 1, viewParent.width-kTextFieldLMargin, viewParent.height-1)];
    // 保存
    [viewParent addSubview:textField];
    
    _cellPhoneTextField = textField;
}

// 履历
- (void)setupViewSubsResume:(UIView *)viewParent
{
    viewParent.layer.borderColor = [UIColor colorWithHex:0xDCDCDC alpha:1.0].CGColor;
    viewParent.layer.borderWidth = 1.0;
    viewParent.backgroundColor = kWhiteColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"履历：" andColor:kTextColor];
    titleLabel.frame = CGRectMake(10, 8, 50, 18);
    [viewParent addSubview:titleLabel];
    
    
    UITextView *textView = [[UITextView  alloc] initWithFrame:CGRectMake(titleLabel.right, 0, viewParent.width-titleLabel.right, viewParent.height-8)];
    textView.textColor = kTextColor;
    textView.font = kSmallTitleFont;
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
    textView.returnKeyType = UIReturnKeyDefault;
    textView.scrollEnabled = YES;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [viewParent addSubview: textView];
    
    _resumeTextView = textView;
}

// 姓名
- (void)nameChanged:(UITextField *)sender
{
    _teacherName = sender.text;
}

- (void)nameFinished:(id)sender
{
    
}

// 课程
- (void)causeChanged:(UITextField *)sender
{
    _courseName = sender.text;
}

- (void)causeFinished:(id)sender
{
    
}

// 手机号
- (void)phoneChanged:(UITextField *)sender
{
    _teacherCellPhone = sender.text;
}
- (void)phoneFinished:(id)sender
{
    
}

//// 履历
//- (void)resumeChanged:(UITextField *)sender
//{
//    _teacherResume = sender.text;
//}
//- (void)resumeFinished:(id)sender
//{
//    
//}

- (void)doSelectCalendar:(UIButton *)sender
{
    [self dismissKeyboard];
    
    _birthdayVC = [[BirthdayVC alloc] initWithName:@"选择生日"];
    [_birthdayVC setDelegate:self];
    [_birthdayVC setMaxValidDate:[NSDate date]];
    
    // 添加到父窗口
    [[_birthdayVC view] setAlpha:0];
    [[self view] addSubview:[_birthdayVC view]];
    
    // 显示
    [UIView animateWithDuration:0.8
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [[_birthdayVC view] setAlpha:1];
                     }
                     completion:nil];
}

- (void)doSubmitAction
{
    [self loadingAnimation];
    
    NSString *sex;
    if (_teacherSex)
    {
        sex = @"true";
    }
    else {
        sex = @"false";
    }
    
    
    // =======================================================================
    // 请求参数：teacherId teacherName teacherBirth cellPhone resume
    // =======================================================================
    NSNumber *teacherId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([teacherId stringValue]) forKey:@"teacherId"];
    [parameters setObjectSafe:base64Encode(_teacherName) forKey:@"teacherName"];
    [parameters setObjectSafe:base64Encode(sex) forKey:@"teacherSex"];
    [parameters setObjectSafe:base64Encode(_courseName) forKey:@"course"];

    [parameters setObjectSafe:base64Encode(_teacherBirth) forKey:@"teacherBirth"];
    [parameters setObjectSafe:base64Encode(_teacherCellPhone) forKey:@"cellPhone"];
    [parameters setObjectSafe:base64Encode(_resumeTextView.text) forKey:@"resume"];

    // 发送请求
    [NetWorkTask postRequest:kRequestAlterTeacherInfo
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestAlterTeacherInfo];
}

- (void)getSearchTeacherInfo
{
    [self loadingAnimation];
    
    NSNumber *teacherId = [kSaveData objectForKey:kTeacherIdKey];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([teacherId stringValue]) forKey:@"teacherId"];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestTeacherInfo
                 forParamDic:parameters
                searchResult:[[TeacherInfoResult alloc] init]
                 andDelegate:self forInfo:kRequestTeacherInfo];
    
}
#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    // 获取老师信息回调
    if ([customInfo isEqualToString:kRequestTeacherInfo]) {
        [self getSearchNetBackGetTeacherInfo:searchResult forInfo:customInfo];
    }
    // 修改老师信息回调
    else if ([customInfo isEqualToString:kRequestAlterTeacherInfo]) {
        [self getSearchNetBackAlterTeacherInfo:searchResult forInfo:customInfo];
    }

}
// 获取老师信息回调
- (void)getSearchNetBackGetTeacherInfo:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        TeacherInfoResult *parentRelateInfoResult = (TeacherInfoResult *)searchResult;
        _teacherInfoResult = parentRelateInfoResult;
        
        if ([parentRelateInfoResult.status integerValue]== 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                // 刷新页面
                if ([_teacherInfoResult.teacherName isStringSafe]) {
                    _teacherName = _teacherInfoResult.teacherName;
                    _nameTextField.text = [NSString stringWithFormat:@"姓名：%@", _teacherName];
                }
                
                // 性别
                if (_teacherInfoResult.teacherSex)
                {
                    if ([_teacherInfoResult.teacherSex boolValue])
                    {
                        if (_radioBoy) {
                            [_radioBoy setChecked:YES];
                        }
                        if (_radioGirl) {
                            [_radioGirl setChecked:NO];
                        }
                    }
                    else
                    {
                        if (_radioBoy) {
                            [_radioBoy setChecked:NO];
                        }
                        if (_radioGirl) {
                            [_radioGirl setChecked:YES];
                        }
                    }
                    _teacherSex = [_teacherInfoResult.teacherSex boolValue];
                    
                }
                
                // 所授课程
                if ([_teacherInfoResult.course isStringSafe]) {
                    _courseName = _teacherInfoResult.course;
                    _courseTextField.text = [NSString stringWithFormat:@"所授课程：%@", _courseName];
                }
                // 出生日期
                if ([_teacherInfoResult.teacherBirth isStringSafe]) {
                    _teacherBirth = _teacherInfoResult.teacherBirth;
                    _birthLabel.text = [NSString stringWithFormat:@"出生日期：%@", _teacherBirth];
                }
                
                // 手机号
                if ([_teacherInfoResult.cellPhone isStringSafe]) {
                    _teacherCellPhone = _teacherInfoResult.cellPhone;
                    _cellPhoneTextField.text = [NSString stringWithFormat:@"手机号：%@", _teacherCellPhone];
                }
                // 履历
                if ([_teacherInfoResult.resume isStringSafe]) {
                    _teacherResume = _teacherInfoResult.resume;
                    _resumeTextView.text = _teacherResume;
                }
            }
            // 失败
            else
            {
                if ([parentRelateInfoResult.businessMsg isStringSafe])
                {
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
// 修改老师信息回调
- (void)getSearchNetBackAlterTeacherInfo:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        BusinessSearchNetResult *parentRelateInfoResult = (BusinessSearchNetResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"修改成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = eSubmitSuccessAlertTag;
                
                [alertView show];
                
            }
            // 失败
            else
            {
                if ([parentRelateInfoResult.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:parentRelateInfoResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:parentRelateInfoResult.msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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

#pragma mark - BirthdayVCDelegate
// =======================================================================
// BirthdayVCDelegate
// =======================================================================
- (void)BirthdayVCBack:(NSDate *)birthdayDate withInfo:(id)delgtInfo;
{
    NSDateFormatter *dateFormatter = [NSDateFormatter defaultFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *birthdayText = [dateFormatter stringFromDate:birthdayDate];
    
    // 刷新日期
    _birthLabel.text = [NSString stringWithFormat:@"出生日期：%@", birthdayText] ;
    _teacherBirth = birthdayText;
}

- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    [textView becomeFirstResponder];
}
- (void)textViewDidEndEditing:(UITextView *)textView;
{
    [textView resignFirstResponder];
}

 - (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
    _teacherResume = textView.text;
    return YES;
}

// 取消输入
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    if ([_nameTextField isFirstResponder])
    {
        [_nameTextField resignFirstResponder];
    }
    
    if ([_courseTextField isFirstResponder]) {
        [_courseTextField resignFirstResponder];
    }
    if ([_cellPhoneTextField isFirstResponder])
    {
        [_cellPhoneTextField resignFirstResponder];
    }
    
    if ([_resumeTextView isFirstResponder]) {
        [_resumeTextView resignFirstResponder];
    }
}

#pragma mark - RadioButtonDelegate
- (void)didSelectedRadioButton:(RadioButton *)radio groupId:(NSString *)groupId;
{
    if ([radio.titleLabel.text isEqualToString:@"男"])
    {
        _teacherSex = YES;
    }
    else
    {
        _teacherSex = NO;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == eSubmitSuccessAlertTag)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end

