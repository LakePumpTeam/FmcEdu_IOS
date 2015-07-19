//
//  RegisterAssociatedInforVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/9.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "RegisterAssociatedInforVC.h"
#import "RadioButton.h"
#import "UIPopoverListView.h"
#import "PopTableViewCell.h"

#import "ProvResult.h"
#import "CityResult.h"
#import "SchoolResult.h"
#import "ClassResult.h"
#import "HeadTeacherResult.h"
#import "ParentRelateInfoResult.h"

#import "ProvInfo.h"
#import "CityInfo.h"
#import "SchoolInfo.h"
#import "ClassInfo.h"

#import "BirthdayVC.h"
#import "LoginVC.h"

typedef NS_ENUM(NSInteger, ControllTag) {
    eProvTag = 1,
    eCityTag,
    eSchoolTag,
    eClassTag,
    eHeadTeacherTag,
    eStudentNameTag,
    eStudentSexTag,
    eStudentAgeTag,
    eParentNameTag,
    eParentPhoneTag,
    eParentChildRelationTag,
    eAddressTag,
    eBraceletCardNumTag,
    eBraceletNumTag,
    
    eRelateInfoSuccessAlertTag,
};

#define kCellCount                      4
#define kTextSize                       16
#define kTextFieldLMargin               25
#define kPopCellHeight                  50

@interface RegisterAssociatedInforVC ()<UITextFieldDelegate, UIPopoverListViewDataSource, UIPopoverListViewDelegate, NetworkPtc, UIScrollViewDelegate, RadioButtonDelegate, BirthdayVCDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView; // 内容视图

@property (nonatomic, strong) UIPopoverListView *provslistview;
@property (nonatomic, strong) UIPopoverListView *cityslistview;
@property (nonatomic, strong) UIPopoverListView *schoolslistview;
@property (nonatomic, strong) UIPopoverListView *classeslistview;
@property (nonatomic, strong) UIPopoverListView *relationlistview;

@property (nonatomic, strong) NSMutableArray *provList;
@property (nonatomic, strong) NSMutableArray *cityList;
@property (nonatomic, strong) NSMutableArray *schoolList;
@property (nonatomic, strong) NSMutableArray *classList;
@property (nonatomic, strong) NSMutableArray *relationList;

@property (nonatomic, strong) UIView *provView;
@property (nonatomic, strong) UIView *cityView;
@property (nonatomic, strong) UIView *schoolView;
@property (nonatomic, strong) UIView *classView;
@property (nonatomic, strong) UIView *headTeacherView;
@property (nonatomic, strong) UIView *relationView;

// 输入
@property (nonatomic, strong) UITextField *studentNameField;
@property (nonatomic, strong) UITextField *parentNameField;
@property (nonatomic, strong) UITextField *parentPhoneField;
@property (nonatomic, strong) UITextField *addressField;
@property (nonatomic, strong) UITextField *braceletCarNumField;
@property (nonatomic, strong) UITextField *braceletNumField;

@property (nonatomic, strong) NSString *studentName;
@property (nonatomic, strong) NSString *parentName;
//@property (nonatomic, strong) NSString *parentPhone;    // 注册页面直接带过来

@property (nonatomic, strong) NSString *parentRelation;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *braceletCarNum;
@property (nonatomic, strong) NSString *braceletNum;

// 选择信息
@property (nonatomic, strong) ProvInfo *selectProvInfo;
@property (nonatomic, strong) CityInfo *selectCityInfo;
@property (nonatomic, strong) SchoolInfo *selectSchoolInfo;
@property (nonatomic, strong) ClassInfo *selectClassInfo;
@property (nonatomic, strong) HeadTeacherResult *headTeacherResult;

// 显示
@property (nonatomic, strong) NSString *headTeacherName;

// 性别
@property (nonatomic, assign) BOOL studentSex;      // yes:男 no:女

// 出生日期
@property (nonatomic, strong) __block UILabel *birthLabel;
@property (nonatomic, strong) BirthdayVC *birthdayVC;
@property (nonatomic, strong) NSString *studentBirth;

@property (nonatomic, strong) ParentRelateInfoResult *parentRelateInfoResult;   // 家长默认关联信息

@end
@implementation RegisterAssociatedInforVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 显示状态栏
    [self.navigationController.navigationBar setHidden:NO];
    
    // 初始化
    _provList = [[NSMutableArray alloc] init];
    _cityList = [[NSMutableArray alloc] init];
    _schoolList = [[NSMutableArray alloc] init];
    _classList = [[NSMutableArray alloc] init];
    _relationList = [[NSMutableArray alloc] init];
    
    [_relationList addObjectsFromArray:[NSArray arrayWithObjects:@"爸爸", @"妈妈", @"爷爷", @"奶奶", @"姥爷", @"姥姥", @"其他", nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
   

    [self setupRootViewSubs:self.view];
        
}

- (void)keyboardWillShow:(NSNotification *)notification{
    
    
    if ([_studentNameField isFirstResponder])
    {
        [_scrollView setContentOffset:CGPointMake(0, 250)];

    }
    if ([_parentNameField isFirstResponder]) {
        [_scrollView setContentOffset:CGPointMake(0, 300)];
    }
    if ([_parentPhoneField isFirstResponder]) {
        [_scrollView setContentOffset:CGPointMake(0, 350)];
    }
    if ([_addressField isFirstResponder]) {
        [_scrollView setContentOffset:CGPointMake(0, 450)];
    }
    if ([_braceletCarNumField isFirstResponder]) {
        [_scrollView setContentOffset:CGPointMake(0, 500)];
    }
    if ([_braceletNumField isFirstResponder]) {
        [_scrollView setContentOffset:CGPointMake(0, 550)];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification{
   
//    [_scrollView setContentOffset:CGPointZero];
   
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 内容视图
    // =======================================================================
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = CGRectMake(spaceXStart, spaceYStart, kScreenWidth, kScreenHeight-spaceYStart);
    scrollView.backgroundColor = kBackgroundColor;
    [scrollView setContentOffset:CGPointMake(spaceXStart, spaceYStart)];

    [viewParent addSubview:scrollView];
    
    scrollView.delegate = self;
    
    _scrollView = scrollView;
    
    // 子视图
    [self setupViewSubsScrollView:scrollView];
    
    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc]                                                initWithTarget:self                                                 action:@selector(dismissKeyboard)];
    [scrollView addGestureRecognizer: dismissKeyboardTap];
   
}

- (void)setupViewSubsScrollView:(UIScrollView *)viewParent
{
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 省份
    // =======================================================================
    _provView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    _provView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithPop:_provView forTitle:@"省份" withTag:eProvTag];
    [viewParent addSubview:_provView];
    
    // 添加手势
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(provsViewGesture:)];
    [_provView addGestureRecognizer:gesture];

    // 调整Y
    spaceYStart += _provView.height;
    
    // =======================================================================
    // 城市
    // =======================================================================
    _cityView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    _cityView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithPop:_cityView forTitle:@"城市" withTag:eCityTag];
    [viewParent addSubview:_cityView];
    
    // 添加手势
    UITapGestureRecognizer *cityGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(citysViewGesture:)];
    [_cityView addGestureRecognizer:cityGesture];

    // 调整Y
    spaceYStart += _cityView.height;
    
    // =======================================================================
    // 学校
    // =======================================================================
    _schoolView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    _schoolView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithPop:_schoolView forTitle:@"学校" withTag:eSchoolTag];
    [viewParent addSubview:_schoolView];
    
    // 添加手势
    UITapGestureRecognizer *schoolGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(schoolsViewGesture:)];
    [_schoolView addGestureRecognizer:schoolGesture];

    // 调整Y
    spaceYStart += _schoolView.height;
    
    // =======================================================================
    // 班级
    // =======================================================================
    _classView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    _classView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithPop:_classView forTitle:@"班级" withTag:eClassTag];
    [viewParent addSubview:_classView];
    
    // 添加手势
    UITapGestureRecognizer *classGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(classesViewGesture:)];
    [_classView addGestureRecognizer:classGesture];
    
    // 调整Y
    spaceYStart += _classView.height;
    
    // =======================================================================
    // 班主任（根据后台返回显示）
    // =======================================================================
    _headTeacherView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    _headTeacherView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithNoPop:_headTeacherView forTitle:@"班主任" withTag:eHeadTeacherTag];
    [viewParent addSubview:_headTeacherView];
    
    // 添加手势
    UITapGestureRecognizer *headTeacherGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headTeacherViewGesture:)];
    [_headTeacherView addGestureRecognizer:headTeacherGesture];
    
    // 调整Y
    spaceYStart += _headTeacherView.height;
    
    // =======================================================================
    // 学生姓名
    // =======================================================================
    UIView *studentNameView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    studentNameView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithInputStuentName:studentNameView forTitle:@"学生姓名" withTag:eStudentNameTag];
    [viewParent addSubview:studentNameView];
    
    // 调整Y
    spaceYStart += studentNameView.height;
    
    // =======================================================================
    // 学生姓别
    // =======================================================================
    UIView *studentSexView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    studentSexView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithRadioButton:studentSexView forTitle:@"学生姓别" withTag:eStudentSexTag];
    [viewParent addSubview:studentSexView];
    
    // 调整Y
    spaceYStart += studentSexView.height;
    
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
    // 家长姓名
    // =======================================================================
    UIView *parentNameView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    parentNameView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithInputParentName:parentNameView forTitle:@"家长姓名" withTag:eParentNameTag];
    [viewParent addSubview:parentNameView];
    
    // 调整Y
    spaceYStart += parentNameView.height;
    
    // =======================================================================
    // 家长电话
    // =======================================================================
    UIView *parentPhoneView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    parentPhoneView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithInputParentPhone:parentPhoneView forTitle:@"家长电话" withTag:eParentPhoneTag];
    [viewParent addSubview:parentPhoneView];
    
    // 调整Y
    spaceYStart += parentPhoneView.height;
    
    // =======================================================================
    // 亲子关系
    // =======================================================================
    _relationView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    _relationView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithPop:_relationView forTitle:@"亲子关系" withTag:eParentChildRelationTag];
    [viewParent addSubview:_relationView];
    
    // 添加手势
    UITapGestureRecognizer *relationGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(relationViewGesture:)];
    [_relationView addGestureRecognizer:relationGesture];
    
    // 调整Y
    spaceYStart += _relationView.height;
    
    // =======================================================================
    // 家庭地址
    // =======================================================================
    UIView *addressView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    addressView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithInputAddress:addressView forTitle:@"家庭地址" withTag:eAddressTag];
    [viewParent addSubview:addressView];
    
    // 调整Y
    spaceYStart += addressView.height;
    
    // =======================================================================
    // 手环卡号
    // =======================================================================
    UIView *braceletCardNumView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    braceletCardNumView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithInputBraceletCardNum:braceletCardNumView forTitle:@"手环卡号" withTag:eBraceletCardNumTag];
    [viewParent addSubview:braceletCardNumView];
    
    // 调整Y
    spaceYStart += braceletCardNumView.height;
    
    // =======================================================================
    // 手环编号
    // =======================================================================
    UIView *braceletNumView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, kCellHeight)];
    braceletNumView.backgroundColor = [UIColor whiteColor];
    [self setupViewSubsWithInputBraceletNum:braceletNumView forTitle:@"手环编号" withTag:eBraceletNumTag];
    [viewParent addSubview:braceletNumView];
    
    // 调整Y
    spaceYStart += braceletNumView.height;
    
    
    // =======================================================================
    // 底部分割线
    // =======================================================================
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
    // =======================================================================
    // 提交审核
    // =======================================================================
    
    // 调整Y
    spaceYStart += 55;

    UIButton *submitButton = [[UIButton alloc] initWithFont:kTitleFont andTitle:@"提交审核" andTtitleColor:kWhiteColor andCornerRadius:20.0];
    submitButton.backgroundColor = kBackgroundGreenColor;
    
    submitButton.frame = CGRectMake(40, spaceYStart, kScreenWidth-40*2, kButtonHeight);
    [submitButton addTarget:self action:@selector(doSubmitAction) forControlEvents:UIControlEventTouchUpInside];
    
    [viewParent addSubview:submitButton];
    
    // 调整Y
    spaceYStart += submitButton.height;
    spaceYStart += 55;
    
    [viewParent setContentSize:CGSizeMake(kScreenWidth, spaceYStart)];
    
    if (kSystemVersion < 7) {
        [viewParent setContentSize:CGSizeMake(kScreenWidth, spaceYStart+kNavigationBarHeight)];
    }
}

- (void)setupViewSubsWithPop:(UIView *)viewParent forTitle:(NSString *)initTitle withTag:(NSInteger)initTag
{
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
    // 提示*
    UILabel *redStarLabel = [[UILabel alloc] initRedStart:kSmallTitleFont];
    redStarLabel.frame = CGRectMake(10, (kCellHeight-12)/2, kTextSize, kTextSize);
    [viewParent addSubview:redStarLabel];
    
    // =======================================================================
    // 具体信息
    // =======================================================================

    UILabel *titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont
                                                andText:initTitle
                                               andColor:[UIColor colorWithHex:0x888888 alpha:1.0]];
    titleLabel.frame = CGRectMake(redStarLabel.centerX + 8, 0, kTextSize*initTitle.length, kCellHeight);
    titleLabel.tag = initTag;
    [viewParent addSubview:titleLabel];
    
    // 下拉arrow 16*12
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"downArrow"]];
    imageView.frame = CGRectMake(kScreenWidth-25-16, (kCellHeight-12)/2, 16, 12);
    [viewParent addSubview:imageView];
}

// 分割线+提示+title
- (void)setupViewSubsWithNoPop:(UIView *)viewParent forTitle:(NSString *)initTitle withTag:(NSInteger)initTag
{
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
    // 提示*
    UILabel *redStarLabel = [[UILabel alloc] initRedStart:kSmallTitleFont];
    redStarLabel.frame = CGRectMake(10, (kCellHeight-kTextSize)/2, kTextSize, kTextSize);
    [viewParent addSubview:redStarLabel];
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont
                                                andText:initTitle
                                               andColor:[UIColor colorWithHex:0x888888 alpha:1.0]];
    titleLabel.frame = CGRectMake(redStarLabel.centerX + 8, (kCellHeight-kTextSize)/2, kTextSize*initTitle.length, kTextSize);
    titleLabel.tag = initTag;
    [viewParent addSubview:titleLabel];
}

// 学生姓名
- (void)setupViewSubsWithInputStuentName:(UIView *)viewParent forTitle:(NSString *)initTitle withTag:(NSInteger)initTag
{
    // 提示*
    UILabel *redStarLabel = [[UILabel alloc] initRedStart:kSmallTitleFont];
    redStarLabel.frame = CGRectMake(10, (kCellHeight-kTextSize)/2, kTextSize, kTextSize);
    [viewParent addSubview:redStarLabel];
    
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
    // 输入
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    //    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:initTitle
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyNext];
    [textField addTarget:self action:@selector(studentNameChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(studentNameFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField setFrame:CGRectMake(25, 1, kScreenWidth-25, 48)];
    textField.tag = initTag;
    // 保存
    [viewParent addSubview:textField];
    
    _studentNameField = textField;
}

// 家长姓名
- (void)setupViewSubsWithInputParentName:(UIView *)viewParent forTitle:(NSString *)initTitle withTag:(NSInteger)initTag
{
    // 提示*
    UILabel *redStarLabel = [[UILabel alloc] initRedStart:kSmallTitleFont];
    redStarLabel.frame = CGRectMake(10, (kCellHeight-kTextSize)/2, kTextSize, kTextSize);
    [viewParent addSubview:redStarLabel];
    
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
    // 输入
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    //    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:initTitle
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyNext];
    [textField addTarget:self action:@selector(parentNameChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(parentNameFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField setFrame:CGRectMake(25, 1, kScreenWidth-25, 48)];
    textField.tag = initTag;
    // 保存
    [viewParent addSubview:textField];
    
    _parentNameField = textField;
}

// 家长电话
- (void)setupViewSubsWithInputParentPhone:(UIView *)viewParent forTitle:(NSString *)initTitle withTag:(NSInteger)initTag
{
    // 提示*
    UILabel *redStarLabel = [[UILabel alloc] initRedStart:kSmallTitleFont];
    redStarLabel.frame = CGRectMake(10, (kCellHeight-kTextSize)/2, kTextSize, kTextSize);
    [viewParent addSubview:redStarLabel];
    
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
    // 输入
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:initTitle
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyNext];
    [textField addTarget:self action:@selector(parentPhoneChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(parentPhoneFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField setFrame:CGRectMake(25, 1, kScreenWidth-25, 48)];
    textField.tag = initTag;
    
    textField.userInteractionEnabled = NO;
    textField.enabled = NO;
    
    // 保存
    [viewParent addSubview:textField];
    
    _parentPhoneField = textField;
    
    _parentPhoneField.text = _parentCellPhone;
    
}

// 家庭地址
- (void)setupViewSubsWithInputAddress:(UIView *)viewParent forTitle:(NSString *)initTitle withTag:(NSInteger)initTag
{
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
    // 输入
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    //    [textField setKeyboardType:UIKeyboardTypeNumberPad];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:initTitle
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyNext];
    [textField addTarget:self action:@selector(addressChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(addressFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField setFrame:CGRectMake(25, 1, kScreenWidth-25, 48)];
    textField.tag = initTag;
    // 保存
    [viewParent addSubview:textField];
    
    _addressField = textField;
}

// 手环卡号
- (void)setupViewSubsWithInputBraceletCardNum:(UIView *)viewParent forTitle:(NSString *)initTitle withTag:(NSInteger)initTag
{
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
    // 输入
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:initTitle
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyNext];
    [textField addTarget:self action:@selector(braceletCarNumChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(braceletCarNumFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField setFrame:CGRectMake(25, 1, kScreenWidth-25, 48)];
    textField.tag = initTag;
    // 保存
    [viewParent addSubview:textField];
    
    _braceletCarNumField = textField;
}

// 手环编号
- (void)setupViewSubsWithInputBraceletNum:(UIView *)viewParent forTitle:(NSString *)initTitle withTag:(NSInteger)initTag
{
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
    // 输入
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [textField setBackgroundColor:kWhiteColor];
    [textField setFont:kSmallTitleFont];
    [textField setPlaceholder:initTitle
             placeholderColor:kTextColor
          placeholderFontSize:kSmallTitleFont];
    [textField setDelegate:self];
    [textField setClearsOnBeginEditing:NO];
    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [textField setReturnKeyType:UIReturnKeyNext];
    [textField addTarget:self action:@selector(braceletNumChanged:) forControlEvents:UIControlEventEditingChanged];
    [textField addTarget:self action:@selector(braceletNumFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [textField setFrame:CGRectMake(25, 1, kScreenWidth-25, 48)];
    textField.tag = initTag;
    // 保存
    [viewParent addSubview:textField];
    
    _braceletNumField = textField;
}


- (void)studentNameChanged:(UITextField *)sender
{
    // 保存文本
    _studentName = [(UITextField *)sender text];
    
}

- (void)studentNameFinished:(UITextField *)sender
{
    
}
- (void)parentNameChanged:(UITextField *)sender
{
    // 保存文本
    _parentName = [(UITextField *)sender text];
}

- (void)parentNameFinished:(UITextField *)sender
{
    
}
- (void)parentPhoneChanged:(UITextField *)sender
{
    // 保存文本
    _parentCellPhone = [(UITextField *)sender text];
}

- (void)parentPhoneFinished:(UITextField *)sender
{
    
}

- (void)addressChanged:(UITextField *)sender
{
    // 保存文本
    _address = [(UITextField *)sender text];
}

- (void)addressFinished:(UITextField *)sender
{
    
}
- (void)braceletCarNumChanged:(UITextField *)sender
{
    // 保存文本
    _braceletCarNum = [(UITextField *)sender text];
}

- (void)braceletCarNumFinished:(UITextField *)sender
{
    
}
- (void)braceletNumChanged:(UITextField *)sender
{
    // 保存文本
    _braceletNum = [(UITextField *)sender text];
    
}
- (void)braceletNumFinished:(UITextField *)sender
{
    
}
#pragma mark - 出生日期选择
// 出生年月
- (void)setupViewSubsBirth:(UIView *)viewParent
{
    // 提示*
    UILabel *redStarLabel = [[UILabel alloc] initRedStart:kSmallTitleFont];
    redStarLabel.frame = CGRectMake(10, (kCellHeight-kTextSize)/2, kTextSize, kTextSize);
    [viewParent addSubview:redStarLabel];
    
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

// 学生性别：单选框
- (void)setupViewSubsWithRadioButton:(UIView *)viewParent forTitle:(NSString *)initTitle withTag:(NSInteger)initTag
{
    [self setupViewSubsWithNoPop:viewParent forTitle:initTitle withTag:initTag];
    
    // 单选框
    RadioButton *radio1 = [[RadioButton alloc] initWithDelegate:self groupId:@"groupId1"];
    radio1.frame = CGRectMake(98, (kCellHeight-40)/2, 50, 40);
    [radio1 setTitle:@"男" forState:UIControlStateNormal];
    [radio1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [radio1.titleLabel setFont:kSmallTitleFont];
    [viewParent addSubview:radio1];
    // 设置选中
    [radio1 setChecked:YES];
    _studentSex = YES;
    
    RadioButton *radio2 = [[RadioButton alloc] initWithDelegate:self groupId:@"groupId1"];
    radio2.frame = CGRectMake(168, (kCellHeight-40)/2, 50, 40);
    [radio2 setTitle:@"女" forState:UIControlStateNormal];
    [radio2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [radio2.titleLabel setFont:kSmallTitleFont];
    [viewParent addSubview:radio2];
}

#pragma mark - 事件
- (void)doSubmitAction
{
    [self loadingAnimation];
    
    // =======================================================================
    // 关联家长信息
    // =======================================================================
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode(_parentCellPhone) forKey:@"cellPhone"];
    [parameters setObjectSafe:base64Encode([_selectProvInfo.provId stringValue]) forKey:@"provId"];
    [parameters setObjectSafe:base64Encode([_selectCityInfo.cityId stringValue]) forKey:@"cityId"];
    [parameters setObjectSafe:base64Encode([_selectSchoolInfo.schoolId stringValue]) forKey:@"schoolId"];
    [parameters setObjectSafe:base64Encode([_selectClassInfo.classId stringValue]) forKey:@"classId"];
    [parameters setObjectSafe:base64Encode([_headTeacherResult.headTeacherId stringValue]) forKey:@"teacherId"];
    [parameters setObjectSafe:base64Encode(_studentName) forKey:@"studentName"];
    [parameters setObjectSafe:base64Encode([[NSNumber numberWithBool:_studentSex] stringValue]) forKey:@"studentSex"];
    
    [parameters setObjectSafe:base64Encode(_studentBirth) forKey:@"studentAge"];
    
    [parameters setObjectSafe:base64Encode(_parentName) forKey:@"parentName"];
    [parameters setObjectSafe:base64Encode(_parentRelation) forKey:@"relation"];
    [parameters setObjectSafe:base64Encode(_address) forKey:@"address"];
    [parameters setObjectSafe:base64Encode(_braceletCarNum) forKey:@"braceletCardNumber"];
    [parameters setObjectSafe:base64Encode(_braceletNum) forKey:@"braceletNumber"];

    // 发送请求
    [NetWorkTask postRequest:kRequestRegisterRelateInfo
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestRegisterRelateInfo];
}

#pragma mark - 手势识别
// 弹出省份列表
- (void)provsViewGesture:(UIGestureRecognizer *)gesture
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：pageSize 每页显示条数 pageIndex 页索引
    // =======================================================================
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"pageSize"];
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"pageIndex"];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestPorv
                 forParamDic:parameters
                searchResult:[[ProvResult alloc] init]
                 andDelegate:self forInfo:kRequestPorv];
    
}

// 弹出城市列表
- (void)citysViewGesture:(UIGestureRecognizer *)gesture
{
    if (_selectProvInfo.provId == nil)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择省份" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self loadingAnimation];
        
        // =======================================================================
        // 请求参数：pageSize 每页显示条数 pageIndex 页索引
        // =======================================================================
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"pageSize"];
        [parameters setObjectSafe:base64Encode(@"1") forKey:@"pageIndex"];
        [parameters setObjectSafe:base64Encode([_selectProvInfo.provId stringValue]) forKey:@"provId"];

        // 发送请求
        [NetWorkTask postRequest:kRequestCitys
                     forParamDic:parameters
                    searchResult:[[CityResult alloc] init]
                     andDelegate:self forInfo:kRequestCitys];
    }
}

// 弹出学校列表
- (void)schoolsViewGesture:(UIGestureRecognizer *)gesture
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：pageSize 每页显示条数 pageIndex 页索引
    // =======================================================================
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"pageSize"];
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"pageIndex"];
    [parameters setObjectSafe:base64Encode([_selectCityInfo.cityId stringValue]) forKey:@"cityId"];

    // 发送请求
    [NetWorkTask postRequest:kRequestSchools
                 forParamDic:parameters
                searchResult:[[SchoolResult alloc] init]
                 andDelegate:self forInfo:kRequestSchools];
    
   
}

// 弹出班级列表
- (void)classesViewGesture:(UIGestureRecognizer *)gesture
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：pageSize 每页显示条数 pageIndex 页索引
    // =======================================================================
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"pageSize"];
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"pageIndex"];
    [parameters setObjectSafe:base64Encode([_selectSchoolInfo.schoolId stringValue]) forKey:@"schoolId"];

    // 发送请求
    [NetWorkTask postRequest:kRequestClasses
                 forParamDic:parameters
                searchResult:[[ClassResult alloc] init]
                 andDelegate:self forInfo:kRequestClasses];
}

// 弹出亲子关系列表
- (void)relationViewGesture:(UIGestureRecognizer *)gesture
{
    CGFloat xWidth = kScreenWidth - 40.0f;
    CGFloat yHeight = kPopCellHeight * (_relationList.count + 1);
    CGFloat yOffset = kNavigationBarHeight + 20;
    
    CGFloat subsHeight = kScreenHeight-kNavigationBarHeight-80;
    
    if (yHeight > subsHeight) {
        yHeight = subsHeight;
    }
    
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(20, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    [poplistview setTitle:@"请选择亲子关系"];
    _relationlistview = poplistview;
    [_relationlistview show];
}

- (void)headTeacherViewGesture:(UIGestureRecognizer *)gesture
{
    if (_selectClassInfo != nil && _selectClassInfo.classId && _selectSchoolInfo.schoolId)
    {
        [self loadingAnimation];
        
        // =======================================================================
        // 请求参数：classId schoolId
        // =======================================================================
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObjectSafe:base64Encode([_selectClassInfo.classId stringValue]) forKey:@"classId"];
        
        // 发送请求
        [NetWorkTask postRequest:kRequestHeadTeacher
                     forParamDic:parameters
                    searchResult:[[HeadTeacherResult alloc] init]
                     andDelegate:self forInfo:kRequestHeadTeacher];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择班级" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;

    if (popoverListView == _provslistview)
    {
        static NSString *identifier = @"ProvsListViewCell";
        ProvInfo *objectInfo = _provList[row];
        
        PopTableViewCell *cell = [[PopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:identifier];
        cell.textLabel.text = objectInfo.name;
        cell.textLabel.textColor = [UIColor colorWithHex:0x999999 alpha:1.0] ;
        cell.textLabel.font = kSmallTitleFont ;
        cell.imageView.image = [UIImage imageNamed:@"unselect"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone ;
        
        return cell;
    }
    else if (popoverListView == _cityslistview)
    {
        static NSString *identifier = @"CitysListViewCell";
        CityInfo *objectInfo = _cityList[row];

        PopTableViewCell *cell = [[PopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:identifier];
        cell.textLabel.text = objectInfo.cityName;
        cell.textLabel.textColor = [UIColor colorWithHex:0x999999 alpha:1.0] ;
        cell.textLabel.font=kSmallTitleFont ;
        cell.imageView.image = [UIImage imageNamed:@"unselect"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone ;
        
        return cell;

    }
    else if (popoverListView == _schoolslistview)
    {
        static NSString *identifier = @"SchoolListViewCell";
        SchoolInfo *objectInfo = _schoolList[row];
        
        PopTableViewCell *cell = [[PopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:identifier];
        cell.textLabel.text = objectInfo.schoolName;
        cell.textLabel.textColor = [UIColor colorWithHex:0x999999 alpha:1.0] ;
        cell.textLabel.font=kSmallTitleFont ;
        cell.imageView.image = [UIImage imageNamed:@"unselect"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone ;
        
        return cell;
    }
    else if (popoverListView == _classeslistview)
    {
        static NSString *identifier = @"ClassListViewCell";
        ClassInfo *objectInfo = _classList[row];

        PopTableViewCell *cell = [[PopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:identifier];
        cell.textLabel.text = objectInfo.className;
        cell.textLabel.textColor = [UIColor colorWithHex:0x999999 alpha:1.0] ;
        cell.textLabel.font=kSmallTitleFont ;
        cell.imageView.image = [UIImage imageNamed:@"unselect"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone ;
        
        return cell;
    }
    // 亲子关系
    else if (popoverListView == _relationlistview)
    {
        static NSString *identifier = @"RelationListViewCell";
        
        PopTableViewCell *cell = [[PopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:identifier];
        cell.textLabel.text = _relationList[row];
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
    if (popoverListView == _provslistview)
    {
        return _provList.count;
    }
    else if (popoverListView == _cityslistview) {
        return _cityList.count;
    }
    else if (popoverListView == _schoolslistview) {
        return _schoolList.count;
    }
    else if (popoverListView == _classeslistview) {
        return _classList.count;
    }
    else if (popoverListView == _relationlistview) {
        return _relationList.count;
    }
    
    return 7;
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    if (popoverListView == _provslistview)
    {
        UILabel *label = (UILabel *)[_provView viewWithTag:eProvTag];
        if (label)
        {
             _selectProvInfo = _provList[indexPath.row];
            
            CGSize textSize = [_selectProvInfo.name sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(kScreenWidth-100, _provView.height) lineBreakMode:NSLineBreakByTruncatingTail];
            
            // 更新label
            label.text = _selectProvInfo.name;
            label.frame = CGRectMake(25, 0, textSize.width, _provView.height);
        }
    }
    else if (popoverListView == _cityslistview)
    {
        UILabel *label = (UILabel *)[_cityView viewWithTag:eCityTag];
        if (label)
        {
            _selectCityInfo = _cityList[indexPath.row];
            
            CGSize textSize = [_selectCityInfo.name sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(kScreenWidth-100, _cityView.height) lineBreakMode:NSLineBreakByTruncatingTail];
            
            // 更新label
            label.text = _selectCityInfo.name;
            label.frame = CGRectMake(25, 0, textSize.width, _cityView.height);
        }
    }
    else if (popoverListView == _schoolslistview)
    {
        UILabel *label = (UILabel *)[_schoolView viewWithTag:eSchoolTag];
        if (label)
        {
            _selectSchoolInfo = _schoolList[indexPath.row];
            
            CGSize textSize = [_selectSchoolInfo.schoolName sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(kScreenWidth-100, _schoolView.height) lineBreakMode:NSLineBreakByTruncatingTail];
            
            // 更新label
            label.text = _selectSchoolInfo.schoolName;
            label.frame = CGRectMake(25, 0, textSize.width, _schoolView.height);
        }
    }
    else if (popoverListView == _classeslistview)
    {
        UILabel *label = (UILabel *)[_classView viewWithTag:eClassTag];
        if (label)
        {
            _selectClassInfo = _classList[indexPath.row];
            
            CGSize textSize = [_selectClassInfo.className sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(kScreenWidth-100, _classView.height) lineBreakMode:NSLineBreakByTruncatingTail];
            
            // 更新label
            label.frame = CGRectMake(25, 0, textSize.width, _classView.height);
            label.text = _selectClassInfo.className;
        }
    }
    else if (popoverListView == _relationlistview)
    {
        UILabel *label = (UILabel *)[_relationView viewWithTag:eParentChildRelationTag];
        if (label)
        {
            CGSize textSize = [_relationList[indexPath.row] sizeWithFont:kSmallTitleFont constrainedToSize:CGSizeMake(kScreenWidth-100, _relationView.height)];
            
            // 更新label
            label.frame = CGRectMake(25, 0, textSize.width, _relationView.height);
            label.text = _relationList[indexPath.row];
            
            _parentRelation = _relationList[indexPath.row];

        }
    }
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPopCellHeight;
}

#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    if ([customInfo isEqualToString:kRequestPorv])
    {
        [self getSearchNetBackWithProvsList:searchResult];
    }
    else if ([customInfo isEqualToString:kRequestCitys])
    {
        [self getSearchNetBackWithCitysList:searchResult];
    }
    else if ([customInfo isEqualToString:kRequestSchools])
    {
        [self getSearchNetBackWithSchoolsList:searchResult];
    }
    else if ([customInfo isEqualToString:kRequestClasses])
    {
        [self getSearchNetBackWithClassesList:searchResult];
    }
    // 班主任
    else if ([customInfo isEqualToString:kRequestHeadTeacher])
    {
        [self getSearchNetBackWitHeadTeacher:searchResult];
    }
    else if ([customInfo isEqualToString:kRequestRegisterRelateInfo])
    {
        [self getSearchNetBackWithSubmit:(BusinessSearchNetResult *)searchResult];
    }
}

- (void)getSearchNetBackWithFailure:(id)customInfo
{
    [self stopLoadingAnimation];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

// 省份列表回调
- (void)getSearchNetBackWithProvsList:(id)searchResult
{
    if (searchResult != nil)
    {
        ProvResult *result = searchResult;
        
        // 成功
        if ([result.status intValue] == 0)
        {
            _provList = result.provinces;
            
            // 弹出省份列表
            CGFloat xWidth = kScreenWidth - 40.0f;
            CGFloat yHeight = kPopCellHeight * (_provList.count + 1);
            CGFloat yOffset = kNavigationBarHeight + 20;
            
            CGFloat subsHeight = kScreenHeight-kNavigationBarHeight-80;
            
            if (yHeight > subsHeight) {
                yHeight = subsHeight;
            }
            
            UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(20, yOffset, xWidth, yHeight)];
            poplistview.delegate = self;
            poplistview.datasource = self;
            [poplistview setTitle:@"请选择省份"];
            _provslistview = poplistview;
            [_provslistview show];

        }
        // 发送失败
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取省份列表失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}


// 城市列表回调
- (void)getSearchNetBackWithCitysList:(id)searchResult
{
    if (searchResult != nil)
    {
        CityResult *result = searchResult;
        
        // 成功
        if ([result.status intValue] == 0)
        {
            _cityList = result.cities;
            
            CGFloat xWidth = kScreenWidth - 40.0f;
            CGFloat yHeight = kPopCellHeight * (_cityList.count + 1);
            CGFloat yOffset = kNavigationBarHeight + 70;
            
            CGFloat subsHeight = kScreenHeight-kNavigationBarHeight-80;
            
            if (yHeight > subsHeight) {
                yHeight = subsHeight;
            }
            
            UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(20, yOffset, xWidth, yHeight)];
            poplistview.delegate = self;
            poplistview.datasource = self;
            [poplistview setTitle:@"请选择城市"];
            _cityslistview = poplistview;
            [_cityslistview show];
            
        }
        // 发送失败
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取城市列表失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}


// 教师列表回调
- (void)getSearchNetBackWithSchoolsList:(id)searchResult
{
    if (searchResult != nil)
    {
        SchoolResult *result = searchResult;
        
        // 成功
        if ([result.status intValue] == 0)
        {
            // 成功
            if ([result.isSuccess intValue] == 0)
            {
                _schoolList = result.schools;
                
                CGFloat xWidth = kScreenWidth - 40.0f;
                CGFloat yHeight = kPopCellHeight * (_schoolList.count + 1);
                CGFloat yOffset = kNavigationBarHeight + 20;
                
                CGFloat subsHeight = kScreenHeight-kNavigationBarHeight-80;
                
                if (yHeight > subsHeight) {
                    yHeight = subsHeight;
                }
                
                UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(20, yOffset, xWidth, yHeight)];
                poplistview.delegate = self;
                poplistview.datasource = self;
                [poplistview setTitle:@"请选择学校"];
                _schoolslistview = poplistview;
                [_schoolslistview show];
            }
            // 失败
            else
            {
                NSString *errorString = @"获取教师列表失败";

                if ([result.businessMsg isKindOfClass:[NSString class]] && [result.businessMsg isStringSafe])
                {
                    errorString = result.businessMsg;
                }

                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }
        // 发送失败
        else
        {
            NSString *errorString = @"获取教师列表失败";
            if ([result.businessMsg isKindOfClass:[NSString class]] && [result.businessMsg isStringSafe])
            {
                errorString = result.businessMsg;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取教师列表失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}


// 班级列表回调
- (void)getSearchNetBackWithClassesList:(id)searchResult
{
    if (searchResult != nil)
    {
        ClassResult *result = searchResult;
        
        // 成功
        if ([result.status intValue] == 0)
        {
            if ([result.isSuccess integerValue] == 0)
            {
                _classList = result.classList;
                
                CGFloat xWidth = kScreenWidth - 40.0f;
                CGFloat yHeight = kPopCellHeight * (_classList.count + 1);
                CGFloat yOffset = kNavigationBarHeight + 20;
                
                CGFloat subsHeight = kScreenHeight-kNavigationBarHeight-80;
                
                if (yHeight > subsHeight) {
                    yHeight = subsHeight;
                }
                
                UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(20, yOffset, xWidth, yHeight)];
                poplistview.delegate = self;
                poplistview.datasource = self;
                [poplistview setTitle:@"请选择班级"];
                _classeslistview = poplistview;
                [_classeslistview show];

            }
            else
            {
                NSString *errorString = @"获取班级列表失败";
                
                if ([result.businessMsg isKindOfClass:[NSString class]] && [result.businessMsg isStringSafe])
                {
                    errorString = result.businessMsg;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        // 发送失败
        else
        {
            NSString *errorString = @"获取班级列表失败";
            
            if ([result.msg isKindOfClass:[NSString class]] && [result.msg isStringSafe])
            {
                errorString = result.msg;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取班级列表失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 班主任回调
- (void)getSearchNetBackWitHeadTeacher:(id)searchResult
{
    if (searchResult != nil)
    {
        _headTeacherResult = searchResult;
        
        // 成功
        if ([_headTeacherResult.status intValue] == 0)
        {
            if ([_headTeacherResult.isSuccess integerValue] == 0)
            {
                if ([_headTeacherResult.headTeacherName isStringSafe])
                {
                    CGSize textSize = [_headTeacherResult.headTeacherName sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(kScreenWidth-100, _headTeacherView.height) lineBreakMode:NSLineBreakByTruncatingTail];
                    
                    // 更新label
                    UILabel *label = (UILabel *)[_headTeacherView viewWithTag:eHeadTeacherTag];
                    label.text = _headTeacherResult.headTeacherName;
                    label.frame = CGRectMake(25, 0, textSize.width, _headTeacherView.height);
                    
                }
            }
            // 失败
            else
            {
                NSString *errorString = @"获取班主任失败";
                
                if ([_headTeacherResult.businessMsg isKindOfClass:[NSString class]] && [_headTeacherResult.businessMsg isStringSafe])
                {
                    errorString = _headTeacherResult.businessMsg;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }
        // 失败
        else
        {
            NSString *errorString = @"获取班主任失败";
            
            if ([_headTeacherResult.msg isKindOfClass:[NSString class]] && [_headTeacherResult.msg isStringSafe])
            {
                errorString = _headTeacherResult.msg;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取班主任失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 关联信息回调
- (void)getSearchNetBackWithSubmit:(BusinessSearchNetResult *)searchResult
{
    if (searchResult != nil)
    {
        // 成功
        if ([searchResult.status intValue] == 0)
        {
            // 成功
            if ([searchResult.isSuccess integerValue] == 0)
            {
                // 清除登录缓存(保留手机号）
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
                [dictionary setObject:_parentCellPhone forKey:kUserCellPhoneKey];
                
                [[DataController getInstance] saveUserLoginInfo:dictionary];
                
                // 提示关联成功，返回登录页面
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"关联信息成功，审核中..." delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alertView.tag = eRelateInfoSuccessAlertTag;
                
                [alertView show];
            }
            else
            {
                NSString *errorMsg = @"关联信息失败";
                
                if ([searchResult.businessMsg isKindOfClass:[NSString class]] && [searchResult.businessMsg isStringSafe])
                {
                    errorMsg = searchResult.businessMsg;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];

            }
        }
        // 失败
        else
        {
            NSString *errorMsg = @"关联信息失败";
            
            if ([searchResult.msg isKindOfClass:[NSString class]] && [searchResult.msg isStringSafe])
            {
                errorMsg = searchResult.msg;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }

    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"关联信息失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 取消输入
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [self dismissKeyboard];
}

- (void)dismissKeyboard
{
    if (_studentNameField)
    {
        [_studentNameField resignFirstResponder];
    }
    if (_parentNameField)
    {
        [_parentNameField resignFirstResponder];
    }
    if (_parentPhoneField)
    {
        [_parentPhoneField resignFirstResponder];
    }
    if (_addressField)
    {
        [_addressField resignFirstResponder];
    }
    if (_braceletCarNumField)
    {
        [_braceletCarNumField resignFirstResponder];
    }
    if (_braceletNumField)
    {
        [_braceletNumField resignFirstResponder];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField;
{
    
}

#pragma mark - 单选回调
- (void)didSelectedRadioButton:(RadioButton *)radio groupId:(NSString *)groupId;
{
    if ([radio.titleLabel.text isEqualToString:@"男"])
    {
        _studentSex = YES;
    }
    else
    {
        _studentSex = NO;
    }
}

- (void)doSelectCalendar:(UIButton *)sender
{
    [self dismissKeyboard];
    
    _birthdayVC = [[BirthdayVC alloc] initWithName:@"选择生日"];
    [_birthdayVC setDelegate:self];
    [_birthdayVC setMaxValidDate:[NSDate date]];
    
    // 添加到父窗口
    [[_birthdayVC view] setAlpha:0];
    [[self view] addSubview:[_birthdayVC view]];
    
    // 滚动ScrollView
    [_scrollView setContentOffset:CGPointMake(0, 200) animated:YES];

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
    _studentBirth = birthdayText;
    
    // 还原ScrollView
    [_scrollView setContentOffset:CGPointZero animated:YES];

}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 关联成功，返回登录页面
    if (alertView.tag == eRelateInfoSuccessAlertTag)
    {
        LoginVC *loginVC = [[LoginVC alloc] initWithName:@"登录"];
        
        // 设置审核状态
        loginVC.auditState = [NSNumber numberWithInt:0];
        
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _parentPhoneField)
    {
        // .length == 0,表示输入更多， .length == 1则表示删除
        if (range.location >= 11 && (textField.markedTextRange == nil && range.length == 0)){
            return NO;
        }
    }
    
    return YES;
}


@end