//
//  TeacherInfoVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/12.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "TeacherInfoVC.h"
#import "BirthdayVC.h"

typedef NS_ENUM(NSInteger, ControllTag) {
    eNameTextFieldTag,
    ePhoneTextFieldTag,
};

#define kTextFieldLMargin           25

@interface TeacherInfoVC ()<UITextFieldDelegate, UITextViewDelegate, BirthdayVCDelegate>

@property (nonatomic, strong) BirthdayVC *birthdayVC;

@property (nonatomic, strong) UILabel *nameTitleLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *birthTitleLabel;
@property (nonatomic, strong) __block UILabel *birthLabel;

@property (nonatomic, strong) UILabel *cellPhoneTitleLabel;
@property (nonatomic, strong) UILabel *cellPhoneLabel;

@property (nonatomic, strong) UILabel *resumeLabel;

@end

@implementation TeacherInfoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // =======================================================================
    // 内容视图
    // =======================================================================
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight);
    scrollView.backgroundColor = kBackgroundColor;
    [self.view addSubview:scrollView];
    
    scrollView.delegate = self;
    
    [self setupRootViewSubs:scrollView];
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
    
    // =======================================================================
    // 顶部分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // 调整Y
    spaceYStart += 11;
    
    // =======================================================================
    // 履历
    // =======================================================================
    UIView *resumeView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 200)];
    [viewParent addSubview:resumeView];

    [self setupViewSubsResume:resumeView];
    
    // 调整Y
    spaceYStart += resumeView.height;
    
    [viewParent setContentSize:CGSizeMake(viewParent.width, viewParent.height)];
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
    // title
    // =======================================================================
    if (_nameTitleLabel == nil)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"姓名：" andColor:kTextColor];
        [viewParent addSubview:titleLabel];
        
        _nameTitleLabel = titleLabel;
    }
    _nameTitleLabel.frame = CGRectMake(kTextFieldLMargin, 1, 16*3, viewParent.height-1);
    _nameTitleLabel.text = @"姓名：";
    
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"姓名：" andColor:kTextColor];
        [viewParent addSubview:_nameLabel];
    }
    _nameLabel.frame = CGRectMake(_nameTitleLabel.right, 1, kScreenWidth-_nameTitleLabel.right, viewParent.height-1);
    _nameLabel.text = @"姓名：";
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
    
    // =======================================================================
    // 输入view
    // =======================================================================
//    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldLMargin, 1, kScreenWidth-kTextFieldLMargin, kCellHeight-1)
//                                                   initFontSize:kSmallTitleFont
//                                                      textColor:kTextColor];
//    [textField setPlaceholder:@"电话号码"
//             placeholderColor:kTextColor
//          placeholderFontSize:15.0f];
////    textField.textAlignment = NSTextAlignmentLeft;
//    [textField setDelegate:self];
//    
//    [textField addTarget:self action:@selector(phoneChanged:) forControlEvents:UIControlEventEditingChanged];
//    [textField addTarget:self action:@selector(phoneFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    // 保存
//    [viewParent addSubview:textField];
    
    // 输入
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:@"电话号码"
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
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
}

// 履历
- (void)setupViewSubsResume:(UIView *)viewParent
{
    
    // =======================================================================
    // 输入view
    // =======================================================================
//    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(kTextFieldLMargin, 1, kScreenWidth-kTextFieldLMargin, viewParent.height-1)
//                                                   initFontSize:kSmallTitleFont
//                                                      textColor:kTextColor];
//    [textField setPlaceholder:@"履历"
//             placeholderColor:kTextColor
//          placeholderFontSize:15.0f];
//    textField.textAlignment = NSTextAlignmentLeft;
//
//    [textField setDelegate:self];
//    
//    [textField addTarget:self action:@selector(nameChanged) forControlEvents:UIControlEventEditingChanged];
//    [textField addTarget:self action:@selector(nameFinished) forControlEvents:UIControlEventEditingDidEndOnExit];
//    // 保存
//    [viewParent addSubview:textField];
    
    UITextView *textView = [[UITextView  alloc] initWithFrame:CGRectMake(10, 1, viewParent.width-20, viewParent.height-1)];
    textView.textColor = kTextColor;
    textView.font = kSmallTitleFont;
    textView.delegate = self;
    textView.backgroundColor = [UIColor whiteColor];
    
    textView.text = @"履历：";
    textView.returnKeyType = UIReturnKeyDefault;
    textView.scrollEnabled = YES;
    textView.layer.borderColor = [UIColor colorWithHex:0xDCDCDC alpha:1.0].CGColor;
    textView.layer.borderWidth = 1.0;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [viewParent addSubview: textView];
}

- (void)nameChanged:(id)sender
{
    
}

- (void)nameFinished:(id)sender
{
    
}

- (void)phoneChanged:(id)sender
{
    
}
- (void)phoneFinished:(id)sender
{
    
}

- (void)doSelectCalendar:(UIButton *)sender
{
    // 隐藏键盘
    UITextField *textField = (UITextField *)[self.view viewWithTag:eNameTextFieldTag];
    if (textField) {
        [textField resignFirstResponder];
    }
    
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
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    [textView becomeFirstResponder];
}
- (void)textViewDidEndEditing:(UITextView *)textView;
{
    [textView resignFirstResponder];
}
@end
