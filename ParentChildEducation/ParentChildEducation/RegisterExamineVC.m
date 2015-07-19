//
//  RegisterExamineVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/15.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "RegisterExamineVC.h"
#import "ParentsListResult.h"
#import "ParentListInfo.h"
#import "ParentRelateInfoResult.h"
#import "ParentDetailView.h"

typedef NS_ENUM(NSInteger, ActionType) {
    eDoPassAction,
    eDoRefuseAction,
};

typedef NS_ENUM(NSInteger, ControlTag) {
    ePhoneTitleTag = 100,
    eCellPhoneLabelTag,
    eParentTtileLabelTag,
    eLoadMoreButtonTag,
    eAuditSuccessAlertTag,
    
    eparentNameButtonTag = 1000,    // 家长姓名
    
    ePassButtonTag = 5000,          // 通过按钮
    eRefuseButtonTag = 10000,       // 拒绝
};

#define kRoundCorner                10
#define kCellButtonWidth            53
#define kCellButtonHeight           23
#define kMyCellHeight               70

//#define kRowNumber                  10

#define kRefuseKey                  @"refuse"
#define kPassKey                    @"pass"

@interface RegisterExamineVC ()<UITableViewDataSource, UITableViewDelegate, NetworkPtc, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *parentList;
@property (nonatomic, assign) NSInteger curPageIndex;
@property (nonatomic, strong) UITableView *parentTableView;

@property (nonatomic, strong) UIButton *passButton;
@property (nonatomic, strong) UIButton *refuseButton;
@property (nonatomic, assign) BOOL isAllPass;
// 按钮数组
@property (nonatomic, strong) NSMutableArray *buttonsArray;


@property (nonatomic, assign) NSInteger actionType; // 1 pass 2 refuse
@property (nonatomic, assign) ActionType selectRow;


@end

@implementation RegisterExamineVC

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _parentList = [[NSMutableArray alloc] init];
        _curPageIndex = 1;
        _isAllPass = NO;
        
        _buttonsArray = [[NSMutableArray alloc] init];

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupRootViewSubs:self.view];
    
    // 请求家长列表
    [self getParentList];
}

- (void)setRightItem
{
    // 增加全部审核入口
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setTitle:@"全部通过" forState:UIControlStateNormal];
    [settingButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [settingButton.titleLabel setFont:kSmallTitleFont];
    [settingButton addTarget:self action:@selector(doAllExamineAction) forControlEvents:UIControlEventTouchUpInside];
    settingButton.frame = CGRectMake(0, 0, 70, 21);
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height-spaceYStart)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [viewParent addSubview:tableView];
    
    _parentTableView = tableView;
}

- (void)setupViewSubsParentList:(UIView *)viewParent curRow:(NSInteger)curRow isAllPass:(BOOL)isAllPass
{
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
    
#warning 临时解决
    [viewParent removeAllSubviews];
    
    // 数据
    ParentListInfo *parentInfo;
    if (_parentList && _parentList.count > curRow)
    {
        parentInfo = _parentList[curRow];
    }
    
    // =======================================================================
    // 电话号码
    // =======================================================================
    
    NSString *phoneTitle = @"电话号码：";
    CGSize phoneTitleSize = [phoneTitle sizeWithFontCompatible:kSmallTitleFont];

    UILabel *phoneTitleLabel = (UILabel *)[viewParent viewWithTag:ePhoneTitleTag];
    if (phoneTitleLabel == nil)
    {
        phoneTitleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:phoneTitle andColor:kTextBlackColor];
        [viewParent addSubview:phoneTitleLabel];
    }
    phoneTitleLabel.text = phoneTitle;
    phoneTitleLabel.frame = CGRectMake(spaceXStart, spaceYStart, phoneTitleSize.width, phoneTitleSize.height);
    
    // 调整X
    spaceXStart += phoneTitleLabel.width;
    
    NSString *cellPhone;
    if (parentInfo)
    {
        cellPhone = parentInfo.cellPhone;
    }

    if ([cellPhone isStringSafe])
    {
        CGSize phoneTitleSize = [cellPhone sizeWithFontCompatible:kSmallTitleFont];

        UILabel *cellPhoneLabel = (UILabel *)[viewParent viewWithTag:eCellPhoneLabelTag];
        if (cellPhoneLabel == nil)
        {
            cellPhoneLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:phoneTitle andColor:kTextBlackColor];
            [viewParent addSubview:cellPhoneLabel];
        }
        cellPhoneLabel.frame = CGRectMake(spaceXStart, spaceYStart, phoneTitleSize.width, phoneTitleSize.height);
  
        cellPhoneLabel.text = cellPhone;
    }
    
    // 调整Y
    spaceYStart += phoneTitleLabel.height;
    spaceYStart += 9;
    // 重置X
    spaceXStart = 10;
    
    // =======================================================================
    // 家长
    // =======================================================================
    NSString *parentTitle = @"请求人：";
    CGSize parentTitleSize = [parentTitle sizeWithFontCompatible:kSmallTitleFont];
    
    UILabel *parentTtileLabel = (UILabel *)[viewParent viewWithTag:eParentTtileLabelTag];
    if (parentTtileLabel == nil)
    {
        parentTtileLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:parentTitle andColor:kTextColor];
        [viewParent addSubview:parentTtileLabel];
    }
    parentTtileLabel.text = parentTitle;
    parentTtileLabel.frame = CGRectMake(spaceXStart, spaceYStart, parentTitleSize.width, parentTitleSize.height);
    
    
    // 家长姓名
    NSString *parentName;
    if (parentInfo)
    {
        parentName = parentInfo.parentName;
    }

    if ([parentName isStringSafe])
    {
        CGSize parentNameSize = [parentName sizeWithFontCompatible:kSmallTitleFont];
        
        UIButton *parentNameButton = (UIButton *)[viewParent viewWithTag:eparentNameButtonTag+curRow];
        if (parentNameButton == nil)
        {
            parentNameButton = [[UIButton alloc] initWithFont:kSmallTitleFont
                                                    andTitle:parentName
                                              andTtitleColor:[UIColor colorWithHex:0x6380a7 alpha:1.0]];
            parentNameButton.tag = eparentNameButtonTag+curRow;
            [parentNameButton addTarget:self action:@selector(doParentDetailInfoAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [viewParent addSubview:parentNameButton];
        }
        parentNameButton.frame = CGRectMake(parentTtileLabel.right, spaceYStart, parentNameSize.width, parentNameSize.height);
        [parentNameButton setTitle:parentName forState:UIControlStateNormal];
    }
    
    // =======================================================================
    // refuse
    // =======================================================================
    
    // 添加button到dic
    NSMutableDictionary *buttonsDic = [[NSMutableDictionary alloc] init];
    
    UIButton *refuseButton = (UIButton *)[viewParent viewWithTag:eRefuseButtonTag+curRow];
    if (refuseButton == nil)
    {
        refuseButton = [[UIButton alloc] initWithFont:kMiddleFont andTitle:@"拒绝" andTtitleColor:kTextColor andBorderColor:kTextColor andCornerRadius:kRoundCorner];
        refuseButton.backgroundColor = kWhiteColor;
        
        [refuseButton addTarget:self action:@selector(doRefuseAction:) forControlEvents:UIControlEventTouchUpInside];
        refuseButton.tag = eRefuseButtonTag+curRow;
        
        [viewParent addSubview:refuseButton];
        
        [buttonsDic setObject:refuseButton forKey:kRefuseKey];
    }
    refuseButton.frame = CGRectMake(kScreenWidth-10-kCellButtonWidth, (viewParent.height-kCellButtonHeight)/2, kCellButtonWidth, kCellButtonHeight);
    
    // =======================================================================
    // pass
    // =======================================================================
    UIButton *passButton = (UIButton *)[viewParent viewWithTag:ePassButtonTag+curRow];

    if (passButton == nil)
    {
        passButton = [[UIButton alloc] initWithFont:kMiddleFont andTitle:@"通过" andTtitleColor:kWhiteColor andCornerRadius:kRoundCorner];
        passButton.backgroundColor = kBackgroundGreenColor;
        [passButton addTarget:self action:@selector(doPassAction:) forControlEvents:UIControlEventTouchUpInside];
        passButton.tag = ePassButtonTag+curRow;
        
        [viewParent addSubview:passButton];
        
        [buttonsDic setObject:passButton forKey:kPassKey];

    }
    passButton.frame = CGRectMake(refuseButton.left-9-kCellButtonWidth, (viewParent.height-kCellButtonHeight)/2, kCellButtonWidth, kCellButtonHeight);
    
    if (_buttonsArray.count > curRow) {
        _buttonsArray[curRow] = buttonsDic;
    }
    else {
        [_buttonsArray insertObject:buttonsDic atIndex:curRow];
    }
    
    // 设置是否全部通过
    if (isAllPass)
    {
        [passButton setEnabled:NO];
        [passButton setBackgroundColor:[UIColor lightGrayColor]];
        
        [refuseButton setEnabled:YES];
        [refuseButton setBackgroundColor:[UIColor whiteColor]];
    }
    
    // 根据后端状态、控制按钮状态 （1：通过 2：未通过 0：正在审核）
    NSString *auditStatus;
    if (parentInfo)
    {
        auditStatus = parentInfo.auditStatus;
    }
    
    if (auditStatus && [auditStatus isEqualToString:@"1"]) {
        [passButton setEnabled:NO];
        [passButton setBackgroundColor:[UIColor lightGrayColor]];
        [passButton setTitle:@"已通过" forState:UIControlStateNormal];

        [refuseButton setEnabled:YES];
        [refuseButton setBackgroundColor:kWhiteColor];
        [refuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
    }
   
    else if (auditStatus && [auditStatus isEqualToString:@"2"]) {
        [passButton setEnabled:YES];
        [passButton setBackgroundColor:kBackgroundGreenColor];
        [passButton setTitle:@"通过" forState:UIControlStateNormal];

        [refuseButton setEnabled:NO];
        [refuseButton setBackgroundColor:[UIColor lightGrayColor]];
        [refuseButton setTitle:@"已拒绝" forState:UIControlStateNormal];
    }
    else if (auditStatus && [auditStatus isEqualToString:@"0"]) {
        [passButton setEnabled:YES];
        [passButton setBackgroundColor:kBackgroundGreenColor];
        [passButton setTitle:@"通过" forState:UIControlStateNormal];

        [refuseButton setEnabled:YES];
        [refuseButton setBackgroundColor:kWhiteColor];
        [refuseButton setTitle:@"拒绝" forState:UIControlStateNormal];

    }
    else {
        [passButton setEnabled:YES];
        [passButton setBackgroundColor:kBackgroundGreenColor];
        [passButton setTitle:@"通过" forState:UIControlStateNormal];

        [refuseButton setEnabled:YES];
        [refuseButton setBackgroundColor:kWhiteColor];
        [refuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
    }
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, viewParent.height-1, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
}

#pragma mark - 事件处理
// 请求家长列表
- (void)getParentList
{
    [self loadingAnimation];
    
    // =======================================================================
    // 设置家长审核状态 setIsPass:（1：通过 2：不通过)
    // =======================================================================
    NSNumber *teacherId = [kSaveData objectForKey:kTeacherIdKey];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    [parameters setObjectSafe:base64Encode([teacherId stringValue]) forKey:@"teacherId"];
    
    // 请求
    [NetWorkTask postRequest:kRequestParentList
                 forParamDic:parameters
                searchResult:[[ParentsListResult alloc] init]
                 andDelegate:self forInfo:kRequestParentList];
}
- (void)doRefuseAction:(UIButton *)sender
{
    _actionType = eDoRefuseAction;
    _refuseButton = sender;
    
    NSInteger curRow = sender.tag - eRefuseButtonTag;
    _selectRow = curRow;
    
    if (_parentList && _parentList.count > curRow)
    {
        [self loadingAnimation];
        
        ParentListInfo *curSelectParent = _parentList[curRow];
        NSNumber *curParentId = curSelectParent.parentId;
        
        NSNumber *teacherId = [kSaveData objectForKey:kTeacherIdKey];
        
        // =======================================================================
        // 设置家长审核状态 setIsPass:（1：通过 2：不通过)
        // =======================================================================
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        
        [parameters setObjectSafe:base64Encode([curParentId stringValue]) forKey:@"parentIds"];
        
        [parameters setObjectSafe:base64Encode([teacherId stringValue]) forKey:@"teacherId"];

        [parameters setObjectSafe:base64Encode(@"2") forKey:@"setPass"];
        
        // 请求
        [NetWorkTask postRequest:kRequestParentAudit
                     forParamDic:parameters
                    searchResult:[[BusinessSearchNetResult alloc] init]
                     andDelegate:self forInfo:kRequestParentAudit];
    }
}

- (void)doPassAction:(UIButton *)sender
{
    [self loadingAnimation];
    
    _actionType = eDoPassAction;
    _passButton = sender;

    NSInteger curRow = sender.tag - ePassButtonTag;
    _selectRow = curRow;

    if (_parentList && _parentList.count > curRow)
    {
        ParentListInfo *curSelectParent = _parentList[curRow];
        NSNumber *curParentId = curSelectParent.parentId;
        
        NSNumber *teacherId = [kSaveData objectForKey:kTeacherIdKey];
        // =======================================================================
        // 设置家长审核状态 setIsPass:（1：通过 2：不通过)
        // =======================================================================
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObjectSafe:base64Encode([curParentId stringValue]) forKey:@"parentIds"];
        [parameters setObjectSafe:base64Encode([teacherId stringValue]) forKey:@"teacherId"];

        [parameters setObjectSafe:base64Encode(@"1") forKey:@"setPass"];
        
        // 请求
        [NetWorkTask postRequest:kRequestParentAudit
                     forParamDic:parameters
                    searchResult:[[BusinessSearchNetResult alloc] init]
                     andDelegate:self forInfo:kRequestParentAudit];
    }
}

- (void)doAllExamineAction
{
    [self loadingAnimation];
    
    // =======================================================================
    // 设置家长审核状态 setIsPass:（1：通过 2：不通过)
    // =======================================================================
    NSNumber *teacherId = [kSaveData objectForKey:kTeacherIdKey];

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([teacherId stringValue]) forKey:@"teacherId"];
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"allPass"];

    // 请求
    [NetWorkTask postRequest:kRequestParentAuditAll
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestParentAuditAll];
}

// 查看家长详情
- (void)doParentDetailInfoAction:(UIButton *)sender
{
    [self loadingAnimation];
    
    NSInteger curRow = sender.tag - eparentNameButtonTag;
    if (_parentList && _parentList.count > curRow)
    {
        ParentListInfo *curSelectParent = _parentList[curRow];
        NSNumber *curParentId = curSelectParent.parentId;
        // =======================================================================
        // 请求
        // =======================================================================
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObjectSafe:base64Encode([curParentId stringValue]) forKey:@"parentId"];
        
        // 请求
        [NetWorkTask postRequest:kRequestGetRelateInfo
                     forParamDic:parameters
                    searchResult:[[ParentRelateInfoResult alloc] init]
                     andDelegate:self forInfo:kRequestGetRelateInfo];
    }
}

#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    // 单个审核
    if ([customInfo isEqualToString:kRequestParentAudit])
    {
        [self getSearchNetBackWithAudit:searchResult forInfo:customInfo];
    }
    // 批量审核
    else if ([customInfo isEqualToString:kRequestParentAuditAll])
    {
        [self getSearchNetBackWithAuditAll:searchResult forInfo:customInfo];

    }
    // 家长详情
    else if ([customInfo isEqualToString:kRequestGetRelateInfo])
    {
        [self getSearchNetBackWithGetParentDeatil:searchResult forInfo:customInfo];
    }
    // 家长列表
    else if ([customInfo isEqualToString:kRequestParentList])
    {
        [self getSearchNetBackWithGetParentList:searchResult forInfo:customInfo];
    }
    
}

- (void)getSearchNetBackWithAudit:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil && [searchResult.status integerValue] == 0)
    {
        BusinessSearchNetResult *result = (BusinessSearchNetResult *)searchResult;
        // 成功
        if ([result.isSuccess integerValue] == 0) {
            
#warning todo 更新显示按钮状态
            if (_actionType == eDoPassAction)
            {
                _passButton.enabled = NO;
                _passButton.backgroundColor = [UIColor lightGrayColor];
                [_passButton setTitle:@"已通过" forState:UIControlStateNormal];
             
                if (_buttonsArray && _buttonsArray.count > _selectRow) {
                    NSMutableDictionary *curDic = _buttonsArray[_selectRow];
                    
                    UIButton *refuseButton = [curDic objectForKey:kRefuseKey];
                    
                    refuseButton.enabled = YES;
                    refuseButton.backgroundColor = kWhiteColor;
                    [refuseButton setTitle:@"拒绝" forState:UIControlStateNormal];
                }
                
                ParentListInfo *parentInfo;
                if (_parentList.count > _selectRow)
                {
                    parentInfo = _parentList[_selectRow];
                    // 已审核
                    parentInfo.auditStatus = @"1";
                }
                
            }
            else
            {
                _refuseButton.enabled = NO;
                _refuseButton.backgroundColor = [UIColor lightGrayColor];
                [_refuseButton setTitle:@"已拒绝" forState:UIControlStateNormal];

                // 通过与拒绝至少有一个可点击
                if (_buttonsArray && _buttonsArray.count > _selectRow) {
                    NSMutableDictionary *curDic = _buttonsArray[_selectRow];
                    
                    UIButton *passButton = [curDic objectForKey:kPassKey];
                    
                    passButton.enabled = YES;
                    passButton.backgroundColor = kBackgroundGreenColor;
                    [passButton setTitle:@"通过" forState:UIControlStateNormal];

                }
                
                ParentListInfo *parentInfo;
                if (_parentList.count > _selectRow)
                {
                    parentInfo = _parentList[_selectRow];
                    // 已拒绝
                    parentInfo.auditStatus = @"2";
                }
            }

            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已审核" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
//            alertView.tag = eAuditSuccessAlertTag;
            
            [alertView show];
            
        }
        else {
            
            if ([result.businessMsg isStringSafe])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:result.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
           
        }
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未知错误，请联系系统管理员" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }

}
- (void)getSearchNetBackWithAuditAll:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil && [searchResult.status integerValue] == 0)
    {
        BusinessSearchNetResult *result = (BusinessSearchNetResult *)searchResult;
        // 成功
        if ([result.isSuccess integerValue] == 0)
        {
            _isAllPass = YES;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已审核" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            alertView.tag = eAuditSuccessAlertTag;
            
            [alertView show];
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
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未知错误，请联系系统管理员" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }

}

// 家长详情回调
- (void)getSearchNetBackWithGetParentDeatil:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        ParentRelateInfoResult *parentRelateInfoResult = (ParentRelateInfoResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                // 添加详情浮层
                ParentDetailView *parentDetailView = [[ParentDetailView alloc] initWithParentInfo:parentRelateInfoResult];
                
                [self.view addSubview:parentDetailView];
                
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

// 家长列表
- (void)getSearchNetBackWithGetParentList:(SearchNetResult *)searchResult forInfo:(id) customInfo
{
    if (searchResult != nil)
    {
       ParentsListResult *parentsListResult = (ParentsListResult *)searchResult;
        
        if ([parentsListResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentsListResult.isSuccess integerValue] == 0)
            {
                _parentList = parentsListResult.parentsAuditList;
                
                // 增加全部审核入口
                if (_parentList && _parentList.count > 0)
                {
                    [self setRightItem];
                }
                
                // 刷新页面
                [_parentTableView reloadData];
            }
            // 失败
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:parentsListResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
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

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row < kRowNumber)
//    {
        return kMyCellHeight;
//    }
//    else if (indexPath.row == kRowNumber)
//    {
//        return 30;
//    }
//    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
//    if (indexPath.row == kRowNumber)
//    {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathWithIndex:kRowNumber]];
////        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"campusDynamicMoreCellID" forIndexPath:[NSIndexPath indexPathWithIndex:kRowNumber]];
//        if (cell != nil)
//        {
//            cell.textLabel.text = @"加载中...";
//        }
//    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _parentList.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row < kRowNumber) {
        NSString *reuseIdentifier = @"campusDynamicActivityCellID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];
        }
        
        [cell.contentView setFrame:CGRectMake(0, 0, tableView.width, kMyCellHeight)];
        [self setupViewSubsParentList:cell.contentView curRow:indexPath.row isAllPass:_isAllPass ];
        
        return cell;
//    }
//    else if (indexPath.row == kRowNumber)
//    {
//        NSString *reuseIdentifier = @"campusDynamicMoreCellID";
//        
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
//        if (cell == nil)
//        {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        [cell.contentView setFrame:CGRectMake(0, 0, tableView.width, 30)];
//        [self setupViewSubsLoadMore:cell.contentView];
//        
//        return cell;
//    }
    return nil;
}

//- (void)setupViewSubsLoadMore:(UIView *)viewParent
//{
//    
//    UIButton *button = (UIButton *)[viewParent viewWithTag:eLoadMoreButtonTag];
//    if (button == nil)
//    {
//        button = [[UIButton alloc] initWithFont:kSmallTitleFont andTitle:@"加载更多" andTtitleColor:kWhiteColor];
//        button.backgroundColor = kBackgroundGreenColor;
//        button.tag = eLoadMoreButtonTag;
//        [button addTarget:self action:@selector(doLoadMoreAction:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [viewParent addSubview:button];
//    }
//    button.frame = viewParent.frame;
//    
//}

//- (void)doLoadMoreAction:(UIButton *)sender
//{
//    [sender setTitle:@"加载中..." forState:UIControlStateNormal];
//    
//    // 请求更多
//    [self getParentList:_curPageIndex];
//}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == eAuditSuccessAlertTag)
    {
        [self getParentList];
//        [_parentTableView reloadData];
    }
}
@end
