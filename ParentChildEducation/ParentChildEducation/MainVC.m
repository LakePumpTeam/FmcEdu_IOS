//
//  MainVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "MainVC.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "HDetailPictureInfo.h"

// 校园动态
#import "CampusDynamicListVC.h"
// 班级动态
#import "ClassDynamicListVC.h"
// 育儿课堂
#import "EducationChildListVC.h"

// 亲子教育
#import "TaskListVC.h"
// 校园吧
#import "BBSBarVC.h"

// 设置
#import "SettingsVC.h"

// 智能定位
#import "LocationVC.h"

// 教师修改信息(点击头像）
#import "AlterTeacherInfoVC.h"
// 教师查看信息（点击老师名字）
#import "NewTeacherInfoVC.h"
// 家长关联信息修改（头像)
#import "AlterParentInfoVC.h"
#import "AlterAssociatedInforVC.h"
// 注册审批
#import "RegisterExamineVC.h"
// 接送孩子
#import "PickUpChildVC.h"
// 考勤
#import "CheckInVC.h"

#import "HeaderTeacherForHomePageResult.h"

#import "DistributeDynamicVC.h"                 // 发布动态
#import "HomeNewNewsResult.h"

typedef NS_ENUM(NSInteger, ControllTag) {
    eCampusDynamicTag = 1,
    eClassDynamicTag,
    eTimeTableTag,
    eChildEducationTag,
    eChildClassTag,
    eCampusBarTag,
    eLocationTag,
    eRegisterExamineTag,
    ePickUpChildTag,
    eCheckInTag,
};

typedef NS_ENUM(NSInteger, UserType) {
    eTeacherType = 1,
    eParentType,
};

// 尺寸
#define kPortraitWidth              76
#define kBottomBarHeight            49

@interface MainVC ()<NetworkPtc>

@property (nonatomic, strong) UIView *portraitView;

@property (nonatomic, assign) NSInteger userRole;

@property (nonatomic, strong) UILabel *classLabel;
@property (nonatomic, strong) UIButton *nameButton;

@property (nonatomic, strong) HeaderTeacherForHomePageResult *headerTeacherForHomePageResult;

@property (nonatomic, strong) HomeNewNewsResult *homeNewNewsResult;

// 新消息提醒
@property (nonatomic, strong) UIImageView *campusNewsHint;
@property (nonatomic, strong) UIImageView *classNewsHint;
@property (nonatomic, strong) UIImageView *parentChildNewsHint;
@property (nonatomic, strong) UIImageView *childClassNewsHint;
@property (nonatomic, strong) UIImageView *bbsBarNewsHint;

@end

@implementation MainVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getBaseInfoRequest];
    
    [self getCheckNewsRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置基本view
    [self setNavView];
    
    // =======================================================================
    // 获取用户角色
    // =======================================================================
    NSMutableDictionary *userInfo = [[DataController getInstance] getUserLoginInfo];
    _userRole = [[userInfo objectForKey:kUserRoleKey] intValue];
    
    [self setupRootViewSubs:self.view];
    
}

// 设置基本view
- (void)setNavView
{
    // 显示状态栏
    [self.navigationController.navigationBar setHidden:NO];
    
    [self setReturnItemHidden];
    
    // 增加设置
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(doSettingsAction) forControlEvents:UIControlEventTouchUpInside];
    settingButton.frame = CGRectMake(0, 0, 21, 20);
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    // 背景
    [self.view setBackgroundColor:kBackgroundColor];
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceYEnd = viewParent.height;
    
    if (kSystemVersion > 7)
    {
        spaceYStart += kNavigationBarHeight;
    }
    else
    {
        spaceYEnd -= kNavigationBarHeight;
    }
    
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 用户基本信息视图
    // =======================================================================

    UIView *userBaseInfoView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, kScreenWidth, 160)];
    [self setViewSubsUserBaseInfo:userBaseInfoView];
    
    [viewParent addSubview:userBaseInfoView];
    
    spaceYStart += userBaseInfoView.height;
    
    spaceYStart += 10;
    
    // =======================================================================
    // 九宫格
    // =======================================================================
    
    NSInteger nineBlockHeight;
    if (_userRole == eTeacherType)
    {
        nineBlockHeight = spaceYEnd-spaceYStart-kBottomBarHeight-10;
    }
    else
    {
        nineBlockHeight = spaceYEnd-spaceYStart-10;
    }
    
    UIView *nineBlockBoxView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, kScreenWidth, nineBlockHeight)];
    nineBlockBoxView.backgroundColor = kWhiteColor;
    
    [viewParent addSubview:nineBlockBoxView];
    
    [self setupViewSubsNineBlockBoxView:nineBlockBoxView];
    
    // =======================================================================
    // 发布 Tab
    // =======================================================================

    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYEnd-kBottomBarHeight, kScreenWidth, kBottomBarHeight)];
    bottomView.backgroundColor = kWhiteColor;
    [viewParent addSubview:bottomView];
    
    [self setViewSubsBottomBar:bottomView];
    
    // 发布按钮
    UIButton *distribueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [distribueButton setImage:[UIImage imageNamed:@"Distribute"] forState:UIControlStateNormal];
    distribueButton.frame = bottomView.frame;
    distribueButton.frame = CGRectMake((kScreenWidth-54)/2, spaceYEnd-59, 54, 43);

    [distribueButton addTarget:self action:@selector(doDistributeAction) forControlEvents:UIControlEventTouchUpInside];

    [viewParent addSubview:distribueButton];
    
    if (_userRole == eTeacherType)
    {
        [bottomView setHidden:NO];
        [distribueButton setHidden:NO];
    }
    else
    {
        [bottomView setHidden:YES];
        [distribueButton setHidden:YES];
    }
}

// 用户基本信息视图
- (void)setViewSubsUserBaseInfo:(UIView *)viewParent
{
    // 背景
    UIImageView *backGroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MainBackGround"]];
    backGroundView.frame = CGRectMake(0, 0, viewParent.width, viewParent.height);
    [viewParent addSubview:backGroundView];
    
    // =======================================================================
    // 班级
    // =======================================================================
    NSString *classString = @"所在班级：";
    
    _classLabel = [[UILabel alloc] initWithFont:kMiddleTitleFont
                                                andText:classString
                                               andColor:kWhiteColor];
    _classLabel.frame = CGRectMake(0, viewParent.height-17-18, viewParent.width, 18);
    [viewParent addSubview:_classLabel];
    
    // =======================================================================
    // 姓名
    // =======================================================================
    NSString *nameString = @"老师姓名：";
    _nameButton = [[UIButton alloc] initWithFont:kMiddleTitleFont andTitle:nameString andTtitleColor:kWhiteColor];
    _nameButton.frame = CGRectMake(0, _classLabel.top-18-10, viewParent.width, 18);
    [_nameButton addTarget:self action:@selector(doViewUserInfoAction) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:_nameButton];

    // =======================================================================
    // 头像
    // =======================================================================
    _portraitView = [[UIView alloc] initWithFrame:CGRectMake((kScreenWidth-kPortraitWidth)/2, _nameButton.top-10-kPortraitWidth, kPortraitWidth, kPortraitWidth)];
    [_portraitView.layer setCornerRadius:CGRectGetHeight([_portraitView bounds]) / 2];
    _portraitView.layer.masksToBounds = YES;
    _portraitView.layer.contents = (id)[[UIImage imageNamed:@"000"] CGImage];
    [viewParent addSubview:_portraitView];
    
    // =======================================================================
    // 设置头像
    // =======================================================================
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSelectPhotoAction)];
    [_portraitView addGestureRecognizer:gesture];

}

- (void)setViewSubsBottomBar:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;

    // 分割线
    UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, 0.5)];
    [viewParent addSubview:lineView];
    
}

// 九宫格
- (void)setupViewSubsNineBlockBoxView:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    NSInteger blockHeight = viewParent.height/3;
    NSInteger blockWidth = viewParent.width/3;
    
    // =======================================================================
    // 校园动态
    // =======================================================================

    UIView *campusDynamicView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
    campusDynamicView.backgroundColor = kWhiteColor;
    [viewParent addSubview:campusDynamicView];
    
    [self setupViewSubsBlock:campusDynamicView withImageName:@"campusDynamic" withText:@"校园动态"];
    
    // 新消息提醒
    UIImageView *campusNewsHint = [[UIImageView alloc] init];
    campusNewsHint.image = [UIImage imageNamed:@"newsTint"];
    campusNewsHint.frame = CGRectMake((campusDynamicView.width-26)/2+26+5, (campusDynamicView.height -25-14-12)/2, 9, 9);
    [campusDynamicView addSubview:campusNewsHint];
    _campusNewsHint = campusNewsHint;
    [_campusNewsHint setHidden:YES];
    
    // 点击button
    UIButton *campusDynamicButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, 0, viewParent.width, viewParent.height)];
    campusDynamicButton.backgroundColor = [UIColor clearColor];
    campusDynamicButton.tag = eCampusDynamicTag;
    [campusDynamicButton addTarget:self action:@selector(goCampusDynamic) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:campusDynamicButton];
    
    
    spaceXStart += blockWidth;
    
    // =======================================================================
    // 班级动态
    // =======================================================================
    UIView *classDynamicView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
    classDynamicView.backgroundColor = kWhiteColor;
    [viewParent addSubview:classDynamicView];
    
    [self setupViewSubsBlock:classDynamicView withImageName:@"classDynamic" withText:@"班级动态"];
    
    // 新消息提醒
    UIImageView *classDynamicHint = [[UIImageView alloc] init];
    classDynamicHint.image = [UIImage imageNamed:@"newsTint"];
    classDynamicHint.frame = CGRectMake((classDynamicView.width-26)/2+26+5, (classDynamicView.height -25-14-12)/2, 9, 9);
    [classDynamicView addSubview:classDynamicHint];
    _classNewsHint = classDynamicHint;
    [_classNewsHint setHidden:YES];

    
    // 点击button
    UIButton *classDynamicButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height)];
    classDynamicButton.backgroundColor = [UIColor clearColor];
    classDynamicButton.tag = eClassDynamicTag;
    [classDynamicButton addTarget:self action:@selector(goClassDynamic) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:classDynamicButton];
    
    spaceXStart += blockWidth;
    
//    // =======================================================================
//    // 课程表
//    // =======================================================================
//    UIView *timeTableView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
//    timeTableView.backgroundColor = kWhiteColor;
//    [viewParent addSubview:timeTableView];
//    
//    [self setupViewSubsBlock:timeTableView withImageName:@"timeTable" withText:@"课程表"];
//    
//    // 点击button
//    UIButton *timeTableButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height)];
//    timeTableButton.backgroundColor = [UIColor clearColor];
//    timeTableButton.tag = eTimeTableTag;
//    [timeTableButton addTarget:self action:@selector(goTimeTable) forControlEvents:UIControlEventTouchUpInside];
//    [viewParent addSubview:timeTableButton];
    
    // =======================================================================
    // 相伴教育
    // =======================================================================
    UIView *parentEducationView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
    parentEducationView.backgroundColor = kWhiteColor;
    [viewParent addSubview:parentEducationView];
    
    [self setupViewSubsBlock:parentEducationView withImageName:@"ParentEducation" withText:@"亲子教育"];
    
    // 新消息提醒
    UIImageView *parentEducationNewsHint = [[UIImageView alloc] init];
    parentEducationNewsHint.image = [UIImage imageNamed:@"newsTint"];
    parentEducationNewsHint.frame = CGRectMake((parentEducationView.width-26)/2+26+5, (parentEducationView.height -25-14-12)/2, 9, 9);
    [parentEducationView addSubview:parentEducationNewsHint];
    _parentChildNewsHint = parentEducationNewsHint;
    [_parentChildNewsHint setHidden:YES];
    
    // 点击button
    UIButton *parentEducationButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height)];
    parentEducationButton.backgroundColor = [UIColor clearColor];
    parentEducationButton.tag = eChildEducationTag;
    [parentEducationButton addTarget:self action:@selector(goParentEducation) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:parentEducationButton];
    
    spaceXStart += blockWidth;
    
    // 第二行：重置X/Y
    // 调整Y
    spaceYStart += blockHeight;
    spaceXStart = 0;
    
    // =======================================================================
    // 育儿课堂
    // =======================================================================
    UIView *childClassView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
    childClassView.backgroundColor = kWhiteColor;
    [viewParent addSubview:childClassView];
    
    [self setupViewSubsBlock:childClassView withImageName:@"childClass" withText:@"育儿课堂"];
    
    // 新消息提醒
    UIImageView *childClassNewsHint = [[UIImageView alloc] init];
    childClassNewsHint.image = [UIImage imageNamed:@"newsTint"];
    childClassNewsHint.frame = CGRectMake((childClassView.width-26)/2+26+5, (childClassView.height -25-14-12)/2, 9, 9);
    [childClassView addSubview:childClassNewsHint];
    _childClassNewsHint = childClassNewsHint;
    [_childClassNewsHint setHidden:YES];

    
    // 点击button
    UIButton *childClassButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height)];
    childClassButton.backgroundColor = [UIColor clearColor];
    childClassButton.tag = eChildEducationTag;
    [childClassButton addTarget:self action:@selector(goChildClass) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:childClassButton];
    
    spaceXStart += blockWidth;
    
    // =======================================================================
    // 校园吧
    // =======================================================================

    UIView *campusBarView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
    campusBarView.backgroundColor = kWhiteColor;
    [viewParent addSubview:campusBarView];
    
    [self setupViewSubsBlock:campusBarView withImageName:@"campusBar" withText:@"校园吧"];
    
    // 新消息提醒
    UIImageView *campusBarHint = [[UIImageView alloc] init];
    campusBarHint.image = [UIImage imageNamed:@"newsTint"];
    campusBarHint.frame = CGRectMake((campusBarView.width-26)/2+26+5, (campusBarView.height -25-14-12)/2, 9, 9);
    [campusBarView addSubview:campusBarHint];
    _bbsBarNewsHint = campusBarHint;
    [_bbsBarNewsHint setHidden:YES];
    
    // 点击button
    UIButton *campusBarButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height)];
    campusBarButton.backgroundColor = [UIColor clearColor];
    campusBarButton.tag = eCampusBarTag;
    [campusBarButton addTarget:self action:@selector(goCampusBar) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:campusBarButton];
    
    spaceXStart += blockWidth;

    // =======================================================================
    // 智能定位
    // =======================================================================
    
    UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
    locationView.backgroundColor = kWhiteColor;
    [viewParent addSubview:locationView];
    
    [self setupViewSubsBlock:locationView withImageName:@"Location" withText:@"智能定位"];
    
    // 点击button
    UIButton *locationButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height)];
    locationButton.backgroundColor = [UIColor clearColor];
    locationButton.tag = eCampusDynamicTag;
    [locationButton addTarget:self action:@selector(goLocation) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:locationButton];
    
    spaceXStart += blockWidth;
    
    // 第二行：重置X/Y
    // 调整Y
    spaceYStart += blockHeight;
    spaceXStart = 0;

    // =======================================================================
    // 注册审批
    // =======================================================================

    // 老师
    if (_userRole == eTeacherType)
    {
        UIView *registerExamineView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
        registerExamineView.backgroundColor = kWhiteColor;
        [viewParent addSubview:registerExamineView];
        
        [self setupViewSubsBlock:registerExamineView withImageName:@"registerExamine" withText:@"注册审批"];
        
        // 点击button
        UIButton *registerExamineButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height)];
        registerExamineButton.backgroundColor = [UIColor clearColor];
        registerExamineButton.tag = eClassDynamicTag;
        [registerExamineButton addTarget:self action:@selector(goRegisterExamine) forControlEvents:UIControlEventTouchUpInside];
        [viewParent addSubview:registerExamineButton];
        
        spaceXStart += blockWidth;
    }
    
    // =======================================================================
    // 接送孩子
    // =======================================================================
    UIView *pickUpChildView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
    pickUpChildView.backgroundColor = kWhiteColor;
    [viewParent addSubview:pickUpChildView];
    
    [self setupViewSubsBlock:pickUpChildView withImageName:@"PickUpChild" withText:@"接送孩子"];
    
    // 点击button
    UIButton *pickUpChildButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height)];
    pickUpChildButton.backgroundColor = [UIColor clearColor];
    pickUpChildButton.tag = ePickUpChildTag;
    [pickUpChildButton addTarget:self action:@selector(goPickUpChildAction) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:pickUpChildButton];
    
    spaceXStart += blockWidth;
    // =======================================================================
    // 考勤
    // =======================================================================
    UIView *checkInView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, blockWidth, blockHeight)];
    checkInView.backgroundColor = kWhiteColor;
    [viewParent addSubview:checkInView];
    
    [self setupViewSubsBlock:checkInView withImageName:@"CheckIn" withText:@"考勤"];
    
    // 点击button
    UIButton *checkInButton = [[UIButton alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height)];
    checkInButton.backgroundColor = [UIColor clearColor];
    checkInButton.tag = eCheckInTag;
    [checkInButton addTarget:self action:@selector(goCheckInAction) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:checkInButton];
    
    spaceXStart += blockWidth;
    
    // 分割线
    [self setupSepartorLines:viewParent];
}

// 考勤
- (void)goCheckInAction
{
    CheckInVC *pickUpChildVC = [[CheckInVC alloc] initWithName:@"考勤"];
    [self.navigationController pushViewController:pickUpChildVC animated:YES];

}

// 接送孩子
- (void)goPickUpChildAction
{
    PickUpChildVC *pickUpChildVC = [[PickUpChildVC alloc] initWithName:@"接送孩子"];
    [self.navigationController pushViewController:pickUpChildVC animated:YES];
}
// 分割线
- (void)setupSepartorLines:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    NSInteger blockHeight = viewParent.height/3;
    NSInteger blockWidth = viewParent.width/3;
    
    // =======================================================================
    // 第一行
    // =======================================================================

    // 竖向分割线
    UIImageView *separView1 = [[UIImageView alloc] initWithFrame:CGRectMake(blockWidth, spaceYStart, 1, blockHeight)];
    separView1.image = [UIImage imageNamed:@"mainSepartorV"];
    
    [viewParent addSubview:separView1];
    
    // 竖向分割线
    UIImageView *separView2 = [[UIImageView alloc] initWithFrame:CGRectMake(blockWidth*2, spaceYStart, 1, blockHeight)];
    separView2.image = [UIImage imageNamed:@"mainSepartorV"];
    
    [viewParent addSubview:separView2];
    
    // =======================================================================
    // 第二行
    // =======================================================================

    // 竖向分割线
    UIImageView *separView3 = [[UIImageView alloc] initWithFrame:CGRectMake(blockWidth, spaceYStart+blockHeight, 1, blockHeight)];
    separView3.image = [UIImage imageNamed:@"mainSepartorV"];
    
    [viewParent addSubview:separView3];
    
    // 竖向分割线
    UIImageView *separView4 = [[UIImageView alloc] initWithFrame:CGRectMake(blockWidth*2, spaceYStart+blockHeight, 1, blockHeight)];
    separView4.image = [UIImage imageNamed:@"mainSepartorV"];
    
    [viewParent addSubview:separView4];
    
    // =======================================================================
    // 第三行
    // =======================================================================
    
    // 竖向分割线
    UIImageView *separView5 = [[UIImageView alloc] initWithFrame:CGRectMake(blockWidth, spaceYStart+blockHeight*2, 1, blockHeight)];
    separView5.image = [UIImage imageNamed:@"mainSepartorV"];
    
    [viewParent addSubview:separView5];
    
    if (_userRole == eTeacherType)
    {
        // 竖向分割线
        UIImageView *separView6 = [[UIImageView alloc] initWithFrame:CGRectMake(blockWidth*2, spaceYStart+blockHeight*2, 1, blockHeight)];
        separView6.image = [UIImage imageNamed:@"mainSepartorV"];
        
        [viewParent addSubview:separView6];
    }
    
    
    // =======================================================================
    // 第一列
    // =======================================================================

    // 横向分割线
    UIImageView *separView11 = [[UIImageView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart+blockHeight, blockWidth, 1)];
    separView11.image = [UIImage imageNamed:@"mainSepartorH"];
    
    [viewParent addSubview:separView11];
    
    // 横向分割线
    UIImageView *separView22 = [[UIImageView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart+blockHeight*2, blockWidth, 1)];
    separView22.image = [UIImage imageNamed:@"mainSepartorH"];
    
    [viewParent addSubview:separView22];
    
    // =======================================================================
    // 第二列
    // =======================================================================
    // 横向分割线
    UIImageView *separView33 = [[UIImageView alloc] initWithFrame:CGRectMake(spaceXStart+blockWidth, spaceYStart+blockHeight, blockWidth, 1)];
    separView33.image = [UIImage imageNamed:@"mainSepartorH"];
    
    [viewParent addSubview:separView33];
    
    // 横向分割线
    UIImageView *separView44 = [[UIImageView alloc] initWithFrame:CGRectMake(spaceXStart+blockWidth, spaceYStart+blockHeight*2, blockWidth, 1)];
    separView44.image = [UIImage imageNamed:@"mainSepartorH"];
    
    [viewParent addSubview:separView44];

    // =======================================================================
    // 第三列
    // =======================================================================
    // 横向分割线
    UIImageView *separView55 = [[UIImageView alloc] initWithFrame:CGRectMake(spaceXStart+blockWidth*2, spaceYStart+blockHeight, blockWidth, 1)];
    separView55.image = [UIImage imageNamed:@"mainSepartorH"];
    
    [viewParent addSubview:separView55];
    
    // 横向分割线
    UIImageView *separView66 = [[UIImageView alloc] initWithFrame:CGRectMake(spaceXStart+blockWidth*2, spaceYStart+blockHeight*2, blockWidth, 1)];
    separView66.image = [UIImage imageNamed:@"mainSepartorH"];
    
    [viewParent addSubview:separView66];
    
}

- (void)setupViewSubsBlock:(UIView *)viewParent withImageName:(NSString *)imageName withText:(NSString *)initText
{
    NSInteger spaceYStart = (viewParent.height -25-14-12)/2;
    NSInteger spaceXStart = 0;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.frame = CGRectMake((viewParent.width-26)/2, spaceYStart, 26, 25);
    imageView.image = [UIImage imageNamed:imageName];
    [viewParent addSubview:imageView];
    
    // 调整Y
    spaceYStart += 12;
    spaceYStart += imageView.height;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:initText andColor:kTextColor];
    
    titleLabel.frame = CGRectMake(spaceXStart, spaceYStart, viewParent.width, 14);
    [viewParent addSubview:titleLabel];
}

#pragma mark - 网络请求

// 检查是否有新消息
- (void)getCheckNewsRequest
{
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    
    NSNumber *classId = [kSaveData objectForKey:kClassIdKey];
    [parameters setObjectSafe:base64Encode([classId stringValue]) forKey:kClassIdKey];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestCheckNewNews
                 forParamDic:parameters
                searchResult:[[HomeNewNewsResult alloc] init]
                 andDelegate:self forInfo:kRequestCheckNewNews];
}
// 获取基本信息
- (void)getBaseInfoRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSNumber *optionId = [kSaveData objectForKey:kOptionIdKey];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    
    // (家长登陆是传学生的ID，教师登陆传所选班级的ID)
    [parameters setObjectSafe:base64Encode([optionId stringValue]) forKey:@"optionId"];

    // 发送请求
    [NetWorkTask postRequest:kRequestHeaderTeacherForHomePage
                 forParamDic:parameters
                searchResult:[[HeaderTeacherForHomePageResult alloc] init]
                 andDelegate:self forInfo:kRequestHeaderTeacherForHomePage];
    
}

- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    if ([customInfo isEqualToString:kRequestHeaderTeacherForHomePage]) {
        [self getSearchNetBackHomePageTeacherInfo:searchResult forInfo:customInfo];
    }
    else if ([customInfo isEqualToString:kRequestCheckNewNews])
    {
        [self getSearchNetBackOfCheckNews:(HomeNewNewsResult *)searchResult forInfo:customInfo];
    }
}

- (void)getSearchNetBackWithFailure:(id)customInfo
{
    [self stopLoadingAnimation];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

// 首页教师信息回调
- (void)getSearchNetBackHomePageTeacherInfo:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        HeaderTeacherForHomePageResult *parentRelateInfoResult = (HeaderTeacherForHomePageResult *)searchResult;
        _headerTeacherForHomePageResult = parentRelateInfoResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                _userRole = [parentRelateInfoResult.userRole integerValue];
                
                // 刷新页面
                if ([_headerTeacherForHomePageResult.className isStringSafe])
                {
                    _classLabel.text =[NSString stringWithFormat:@"所在班级：%@", _headerTeacherForHomePageResult.className];
                }
                
                if (_headerTeacherForHomePageResult.teacherName)
                {
                    [_nameButton setTitle:[NSString stringWithFormat:@"老师姓名：%@", _headerTeacherForHomePageResult.teacherName] forState:UIControlStateNormal];
                    
                }
                
                if (_headerTeacherForHomePageResult.sex) {
                    if ([_headerTeacherForHomePageResult.sex boolValue]) {
                        _portraitView.layer.contents = (id)[[UIImage imageNamed:@"malePhoto"] CGImage];
                    }
                    else
                    {
                        _portraitView.layer.contents = (id)[[UIImage imageNamed:@"femalePhoto"] CGImage];

                    }
                }
                
                // 保存teacherId
                if (_headerTeacherForHomePageResult.teacherId) {
                    [kSaveData setObject:_headerTeacherForHomePageResult.teacherId forKey:kTeacherIdKey];
                    [kSaveData synchronize];
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)getSearchNetBackOfCheckNews:(HomeNewNewsResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        HomeNewNewsResult *parentRelateInfoResult = (HomeNewNewsResult *)searchResult;
        _homeNewNewsResult = parentRelateInfoResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                
                [self refreshNewsStatus];
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (void)refreshNewsStatus
{
    // 校园动态
    if ([_homeNewNewsResult.schoolNews boolValue])
    {
        [_campusNewsHint setHidden:NO];
    }
    else
    {
        [_campusNewsHint setHidden:YES];
    }
    
    // 班级动态
    if ([_homeNewNewsResult.classNews boolValue]) {
        [_classNewsHint setHidden:NO];
    }
    else
    {
        [_classNewsHint setHidden:YES];
    }
    
    // 亲子教育
    if ([_homeNewNewsResult.educationChild boolValue]) {
        [_parentChildNewsHint setHidden:NO];
    }
    else
    {
        [_parentChildNewsHint setHidden:YES];
    }
    
    // 育儿学堂
    if ([_homeNewNewsResult.childClassNew boolValue]) {
        [_childClassNewsHint setHidden:NO];
    }
    else
    {
        [_childClassNewsHint setHidden:YES];
    }
    // 校园吧
    if ([_homeNewNewsResult.bbsNews boolValue])
    {
        [_bbsBarNewsHint setHidden:NO];
    }
    else
    {
        [_bbsBarNewsHint setHidden:YES];
    }
}

#pragma mark - 九宫格跳转事件

// 校园动态
- (void)goCampusDynamic
{
    CampusDynamicListVC *campusDynamic = [[CampusDynamicListVC alloc] initWithName:@"校园动态"];
    [self.navigationController pushViewController:campusDynamic animated:YES];
}

// 班级动态
- (void)goClassDynamic
{
    ClassDynamicListVC *campusDynamic = [[ClassDynamicListVC alloc] initWithName:@"班级动态"];
    [self.navigationController pushViewController:campusDynamic animated:YES];
}

// 课程表
- (void)goTimeTable
{
    
}

// 亲子教育
- (void)goParentEducation
{
    if (kProgramVersion == 3)
    {
        TaskListVC *parentChildEducationVC = [[TaskListVC alloc] initWithName:@"亲子教育"];
        [self.navigationController pushViewController:parentChildEducationVC animated:YES];

    }
}

// 育儿课堂
- (void)goChildClass
{
    EducationChildListVC *goVC = [[EducationChildListVC alloc] initWithName:@"育儿课堂"];
    [self.navigationController pushViewController:goVC animated:YES];
    
}

// 校园吧
- (void)goCampusBar
{
    if (kProgramVersion == 3)
    {
        BBSBarVC *bbsBarVC = [[BBSBarVC alloc] initWithName:@"校园吧"];
        [self.navigationController pushViewController:bbsBarVC animated:YES];
    }
   
}

// 智能定位
- (void)goLocation
{
    LocationVC *locationVC = [[LocationVC alloc] initWithName:@"智能定位"];
    [self.navigationController pushViewController:locationVC animated:YES];
}

// 注册审核
- (void)goRegisterExamine
{
    RegisterExamineVC *registerExamineVC = [[RegisterExamineVC alloc] initWithName:@"用户审批"];
    [self.navigationController pushViewController:registerExamineVC animated:YES];
}

// 发布
- (void)doDistributeAction
{
    DistributeDynamicVC *distributeDynamicVC = [[DistributeDynamicVC alloc] initWithName:@"发布动态"];
    [self.navigationController pushViewController:distributeDynamicVC animated:YES];
}

#pragma mark - 设置
- (void)doSettingsAction
{
    SettingsVC *settingsVC = [[SettingsVC alloc] initWithName:@"设置"];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

// 点击头像
- (void)doSelectPhotoAction
{
    // 老师
    if (_userRole == eTeacherType)
    {
        // 老师信息修改页面
        AlterTeacherInfoVC *alterTeacherInfo = [[AlterTeacherInfoVC alloc] initWithName:@"修改信息"];
        [self.navigationController pushViewController:alterTeacherInfo animated:YES];
        
    }
    // 家长
    else if (_userRole == eParentType)
    {
        // 取UserId
        NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
        
        // 家长关联信息修改页面
        AlterAssociatedInforVC *alterTeacherInfo = [[AlterAssociatedInforVC alloc] initWithName:@"修改信息"];
        [alterTeacherInfo setUserId:userId];
        alterTeacherInfo.fromType = 2;

        [self.navigationController pushViewController:alterTeacherInfo animated:YES];
    }
}

// 点击老师姓名
- (void)doViewUserInfoAction
{
    if (_userRole == eParentType)
    {
        // 查看老师信息
        NewTeacherInfoVC *teacherInfo = [[NewTeacherInfoVC alloc] initWithName:@"老师信息"];
        [self.navigationController pushViewController:teacherInfo animated:YES];
    }
    
}

@end
