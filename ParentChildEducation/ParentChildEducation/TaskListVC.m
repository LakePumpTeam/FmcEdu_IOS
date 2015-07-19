//
//  ParentChildEducationVC.m
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/1.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "TaskListVC.h"
#import "TopTabView.h"
#import "TaskListResult.h"
#import "TaskInfo.h"
#import "AddTaskVC.h"
#import "TaskDetailVC.h"
#import "FKRDefaultSearchBarTableViewController.h"

typedef NS_ENUM(NSInteger, UserType) {
    eTeacherType = 1,
    eParentType,
};

#define kMyCellHeight                   60

typedef NS_ENUM(NSInteger, QueryType)
{
    eWaitingFinishTaskType = 0,     // 未完成
    eHasFinishedTaskType,           // 已完成

};

typedef NS_ENUM(NSInteger, ControllTag)
{
    eIconTag = 1,
    eTitleLabelTag,
    eStudentNameLabelTag,
    eFinishTimeLabelTag,
    eSepartorLineTag,
    eDeleteSuccessAlertTag,
    eDeleteAlertTag,
};



@interface TaskListVC ()<UITableViewDataSource, UITableViewDelegate, TopTabViewDelegate, NetworkPtc, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TaskListResult *taskListResult;
@property (nonatomic, assign) NSInteger taskType;
@property (nonatomic, assign) NSInteger userRole;           // 用户角色
@property (nonatomic, strong) TaskInfo *deleteTaskInfo;     // 待删除的任务

@end

@implementation TaskListVC

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _taskType = eWaitingFinishTaskType;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getTaskListRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setSearchItem];
    
    // =======================================================================
    // 获取用户角色
    // =======================================================================
    NSMutableDictionary *userInfo = [[DataController getInstance] getUserLoginInfo];
    _userRole = [[userInfo objectForKey:kUserRoleKey] intValue];
    
    [self setupRootViewSubs:self.view];
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
        spaceYStart = 0;
        spaceYEnd -= kNavigationBarHeight;
    }
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // topBar
    // =======================================================================
    TopTabView *topBar = [[TopTabView alloc] initWithFrame: CGRectMake(spaceXStart, spaceYStart, kScreenWidth, 40)
                                                    titles: [NSArray arrayWithObjects:@"未完成", @"已完成", nil]
                                                      type: @"top"];
    topBar.delegate = self;
    [viewParent addSubview:topBar];
    
    // 调整Y
    spaceYStart += 40;
    
    // =======================================================================
    // 列表
    // =======================================================================
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, kScreenWidth, spaceYEnd-spaceYStart-2) style:UITableViewStylePlain];
    tableView.backgroundColor = kWhiteColor;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [viewParent addSubview:tableView];
    
    _tableView = tableView;
}

- (void)setupViewSubsHeaderView:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;

    // =======================================================================
    // 间距
    // =======================================================================
    UIView *separtorView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewSize->width, 10)];
    separtorView.backgroundColor = kBackgroundColor;
    
    [viewParent addSubview:separtorView];
    
    // 调整Y
    spaceYStart += separtorView.height;
    spaceYStart += 10;
    
    // =======================================================================
    // 添加新任务
    // =======================================================================
    
    // 老师才可添加新任务
    if (_userRole == eTeacherType)
    {
        UIButton *submitButton = [[UIButton alloc] initWithFont:kTitleFont andTitle:@"添加新任务" andTtitleColor:kWhiteColor andCornerRadius:20.0];
        submitButton.backgroundColor = kBackgroundGreenColor;
        
        submitButton.frame = CGRectMake(40, spaceYStart, kScreenWidth-40*2, kButtonHeight);
        [submitButton addTarget:self action:@selector(doAddTaskAction) forControlEvents:UIControlEventTouchUpInside];
        
        [viewParent addSubview:submitButton];
        
        // 调整Y
        spaceYStart += submitButton.height;
        spaceYStart += 11;
    }
    
  
    // =======================================================================
    // 调整父size
    // =======================================================================
    viewSize->height = spaceYStart;
}

- (void)setupViewSubsTaskListCell:(UIView *)viewParent inSize:(CGSize *)viewSize indexPath: (NSIndexPath *)indexPath
{
    // =======================================================================
    // 清数据
    // =======================================================================
    UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eTitleLabelTag];
    titleLabel.text = @"";
    
    UILabel *finishTimeLabel = (UILabel *)[viewParent viewWithTag:eFinishTimeLabelTag];
    finishTimeLabel.text = @"";

    UILabel *studentNameLabel = (UILabel *)[viewParent viewWithTag:eStudentNameLabelTag];
    studentNameLabel.text = @"";
    
    // =======================================================================
    // 数据
    // =======================================================================
    TaskInfo *taskInfo = _taskListResult.taskList[indexPath.row];
    
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
    NSInteger spaceXEnd = viewSize->width-10;
    
    // =======================================================================
    // icon
    // =======================================================================

    CustomButton *iconImageView = (CustomButton *)[viewParent viewWithTag:eIconTag];
    if (iconImageView == nil)
    {
        iconImageView = [[CustomButton alloc] init];
        iconImageView.tag = eIconTag;
        [iconImageView addTarget:self action:@selector(doDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [viewParent addSubview:iconImageView];
    }
    iconImageView.frame = CGRectMake(spaceXStart, (kMyCellHeight-25)/2, 25, 25);
    iconImageView.customInfo = taskInfo;
    
    // 未完成
    if ([taskInfo.completeStatus integerValue] == 0)
    {
        if (_userRole == eParentType)
        {
            [iconImageView setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        }
        else
        {
            [iconImageView setImage:[UIImage imageNamed:@"deleteTask"] forState:UIControlStateNormal];
        }
    }
    // 已完成
    else if ([taskInfo.completeStatus integerValue] == 1)
    {
        [iconImageView setImage:[UIImage imageNamed:@"finishTask"] forState:UIControlStateNormal];
    }
    
    spaceXStart += iconImageView.width;
    spaceXStart += 15;
    spaceXEnd -= iconImageView.width;
    
    // =======================================================================
    // title
    // =======================================================================
    
    if ([taskInfo.title isStringSafe])
    {
        UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eTitleLabelTag];
        if (titleLabel == nil)
        {
            titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"" andColor:[UIColor blackColor] withTag:eTitleLabelTag];
            titleLabel.numberOfLines = 0;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:titleLabel];
        }
        CGSize titleSize = [taskInfo.title sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width - spaceXStart - 10, kMyCellHeight) lineBreakMode:NSLineBreakByTruncatingTail];
        titleLabel.frame = CGRectMake(spaceXStart, spaceYStart, titleSize.width, titleSize.height);
        titleLabel.text = taskInfo.title;

        // 调整Y
        spaceYStart += titleSize.height;
        spaceYStart += 14;
    }
    
    // =======================================================================
    // 时间
    // =======================================================================
    if ([taskInfo.deadline isStringSafe])
    {
        NSString *finishTime = [NSString stringWithFormat:@"完成时间：%@", taskInfo.deadline];

        UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eFinishTimeLabelTag];
        if (titleLabel == nil)
        {
            titleLabel = [[UILabel alloc] initWithFont:kSSmallFont andText:@"" andColor:kTextColor withTag:eFinishTimeLabelTag];
            titleLabel.numberOfLines = 0;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:titleLabel];
        }
        CGSize titleSize = [finishTime sizeWithFontCompatible:kSSmallFont constrainedToSize:CGSizeMake(spaceXEnd, kMyCellHeight) lineBreakMode:NSLineBreakByTruncatingTail];
        titleLabel.frame = CGRectMake(spaceXEnd-titleSize.width, spaceYStart, titleSize.width, titleSize.height);
        titleLabel.text = finishTime;
        
        // 调整Y
        spaceXEnd -= titleSize.width;
    }
    
    // =======================================================================
    // 学生姓名
    // =======================================================================

    if ([taskInfo.studentName isStringSafe])
    {
        NSString *studentName = [NSString stringWithFormat:@"学生：%@", taskInfo.studentName];
        
        UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eStudentNameLabelTag];
        if (titleLabel == nil)
        {
            titleLabel = [[UILabel alloc] initWithFont:kSSmallFont andText:@"" andColor:kTextColor withTag:eStudentNameLabelTag];
            titleLabel.numberOfLines = 0;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:titleLabel];
        }
        CGSize titleSize = [studentName sizeWithFontCompatible:kSSmallFont constrainedToSize:CGSizeMake(spaceXEnd, kMyCellHeight) lineBreakMode:NSLineBreakByTruncatingTail];
        titleLabel.frame = CGRectMake(spaceXStart, spaceYStart, titleSize.width, titleSize.height);
        titleLabel.text = studentName;

        // 调整Y
        spaceYStart += titleSize.height;
    }
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine = (UIView *)[viewParent viewWithTag:eSepartorLineTag];
    if (topLine == nil)
    {
        topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, kMyCellHeight-1, viewParent.width, 0.5)];
        topLine.tag = eSepartorLineTag;
        
        [viewParent addSubview:topLine];
    }
    
    viewSize->height = kMyCellHeight;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGSize headerSize = CGSizeMake(tableView.width, 0);
    [self setupViewSubsHeaderView:nil inSize:&headerSize];
    
    return headerSize.height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMyCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TaskInfo *taskInfo = _taskListResult.taskList[indexPath.row];

    // 任务标题
    NSString *taskTitle = taskInfo.title;
    if (taskInfo.title.length > 6)
    {
        taskTitle = [NSString stringWithFormat:@"%@...", [taskInfo.title substringWithRange:NSMakeRange(0, 6)]];
    }
    
    TaskDetailVC *detailVC = [[TaskDetailVC alloc] initWithName:taskTitle];
    [detailVC setStudentId:taskInfo.studentId];
    [detailVC setTaskId:taskInfo.taskId];
    
    // 设置任务完成状态
    if ([taskInfo.completeStatus integerValue] == 0)
    {
        [detailVC setCompleteStatus:NO];
    }
    else if ([taskInfo.completeStatus integerValue] == 1)
    {
        [detailVC setCompleteStatus:YES];
    }
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _taskListResult.taskList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = @"ModifyParentRelatedInfoVCID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView setBackgroundColor:kWhiteColor];
    }
    CGSize contentViewSize = CGSizeMake(tableView.width, 0);
    [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    
    [self setupViewSubsTaskListCell:cell.contentView inSize:&contentViewSize indexPath:indexPath];
    
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *hearderView = [[UIView alloc] init];
    hearderView.backgroundColor = kWhiteColor;
    
    CGSize headerSize = CGSizeMake(tableView.width, 0);
    [self setupViewSubsHeaderView:hearderView inSize:&headerSize];
    
    [hearderView setFrame:CGRectMake(0, 0, headerSize.width, headerSize.height)];
    
    return hearderView;
}



#pragma mark - 网络请求
- (void)getTaskListRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSString *status = [NSString stringWithFormat:@"%ld", (long)_taskType];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode(status) forKey:@"status"];
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"pageIndex"];
    [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"pageSize"];
 
    // 过滤条件
//    [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"filter"];


    // 发送请求
    [NetWorkTask postRequest:kRequestTaskList
                 forParamDic:parameters
                searchResult:[[TaskListResult alloc] init]
                 andDelegate:self forInfo:kRequestTaskList
     isMockData:kIsMock_RequestTaskList];
}

#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    
    if ([customInfo isEqualToString:kRequestTaskList])
    {
        [self getSearchNetBackOfTaskList:searchResult forInfo:customInfo];
    }
    else if ([customInfo isEqualToString:kRequestDeleteTask])
    {
        [self getSearchNetBackOfDeleteTask:searchResult forInfo:customInfo];
    }
}

// 删除任务回调
- (void)getSearchNetBackOfDeleteTask:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        BusinessSearchNetResult *parentRelateInfoResult = (BusinessSearchNetResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                NSString *successMsg = @"删除成功";
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:successMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = eDeleteSuccessAlertTag;
                
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

// 任务列表请求回调
- (void)getSearchNetBackOfTaskList:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        TaskListResult *parentRelateInfoResult = (TaskListResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                _taskListResult = parentRelateInfoResult;
                
                // 刷新页面
                [_tableView reloadData];
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

- (void)getSearchNetBackWithFailure:(id)customInfo
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}


#pragma mark - TopTabViewDelegate
- (void)topTabSelect:(TopBarButton *)btn tabView:(TopTabView *)tabView
{
    _taskType = btn.type;
    
    [self getTaskListRequest];
}

#pragma mark - 事件机制
- (void)doSearchAction
{
    FKRDefaultSearchBarTableViewController *viewController = [[FKRDefaultSearchBarTableViewController alloc] initWithName:@"搜索任务"];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 添加新任务
- (void)doAddTaskAction
{
    AddTaskVC *addTaskVC = [[AddTaskVC alloc] initWithName:@"添加新任务"];
    
    [self.navigationController pushViewController:addTaskVC animated:YES];
}

- (void)doDeleteAction:(CustomButton *)button
{
    _deleteTaskInfo = button.customInfo;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否删除此条班级动态" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定", nil];
    alertView.tag = eDeleteAlertTag;
    
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == eDeleteSuccessAlertTag)
    {
        [self getTaskListRequest];
    }
    else if (alertView.tag == eDeleteAlertTag)
    {
        if (buttonIndex == alertView.cancelButtonIndex) {
            
        }
        else {
            // 删除班级动态
            if ([_deleteTaskInfo.completeStatus integerValue] == 0)
            {
                // 老师才可删除
                if (_userRole == eTeacherType)
                {
                    // 删除
                    [self loadingAnimation];
                    
                    // =======================================================================
                    // 请求参数：cellPhone 登录账号 password
                    // =======================================================================
                    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
                    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
                    [parameters setObjectSafe:base64Encode([_deleteTaskInfo.taskId stringValue]) forKey:@"taskId"];
                    [parameters setObjectSafe:base64Encode([_deleteTaskInfo.studentId stringValue]) forKey:@"studentId"];
                    
                    // 发送请求
                    [NetWorkTask postRequest:kRequestDeleteTask
                                 forParamDic:parameters
                                searchResult:[[BusinessSearchNetResult alloc] init]
                                 andDelegate:self forInfo:kRequestDeleteTask];
                }
            }

        }
    }
}

@end
