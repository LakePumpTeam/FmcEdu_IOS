//
//  TaskDetailVC.m
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/14.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "TaskDetailVC.h"

#import "NewsDetailResult.h"
#import "UIButton+WebCache.h"

#import "TaskDetailResult.h"
#import "TaskCommentInfo.h"
#import "CustomKeyBoardView.h"

#import "UIPopoverListView.h"
#import "PopTableViewCell.h"

#define kPortraitSize                   40
#define kPopCellHeight                  50

typedef NS_ENUM(NSInteger, UserType) {
    eTeacherType = 1,
    eParentType,
};

typedef NS_ENUM(NSInteger, ControllTag)
{
    eTitleLabelTag = 1,
    eTaskDiretorImageViewTag,
    eSubsTitleLabelTag,
    eNewsDateLabelTag,
    eTimeImageViewTag,
    eContentLabelTag,
    eContentSepartorViewTag,
    eImageViewTag,
    
    eSubmitSuccessAlertTag,
    eAlterSuceessAlertTag,
    eDeleteCommentSuccessAlertTag,
    
    // 评论相关
    ePortraitImageViewTag,      // 头像
    eCommentNameLabelTag,       // 姓名
    eCommentTimeLabelTag,       // 时间
    eCommentContentLabelTag,    // 内容
    eCommentSepartorLineTag,    // 分割线
    
    eCellContentTag = 10000,    // cell-content

};


@interface TaskDetailVC ()<UITableViewDataSource, UITableViewDelegate, NetworkPtc, CustomKeyBoardViewDelegate, UITextViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, UIPopoverListViewDataSource, UIPopoverListViewDelegate>

@property (nonatomic, strong) TaskDetailResult *newsResult;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CustomKeyBoardView *keyBoard;
@property (nonatomic, assign) CGFloat keyBoardHeight;
@property (nonatomic, strong) GCPlaceholderTextView *taskDescribeTextView;
@property (nonatomic, strong) NSString *taskDescribe;
@property (nonatomic, strong) NSArray *actionList;
@property (nonatomic, strong) UIPopoverListView *poplistview;

@property (nonatomic, strong) TaskCommentInfo *selectCommentInfo;

@property (nonatomic, assign) int userRole;

@end

@implementation TaskDetailVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.view setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    
    // 请求新闻详情
    [self getNewsRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 评论操作列表
    _actionList = [[NSArray alloc] initWithObjects:@"删除", @"复制", nil];

    // =======================================================================
    // 获取用户角色
    // =======================================================================
    NSMutableDictionary *userInfo = [[DataController getInstance] getUserLoginInfo];
    _userRole = [[userInfo objectForKey:kUserRoleKey] intValue];
    
    [self setRightItem];
    
    [self setupRootViewSubs:self.view];
}

- (void)setRightItem
{
    // 增加搜索
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton addTarget:self action:@selector(doSaveAction) forControlEvents:UIControlEventTouchUpInside];
    settingButton.frame = CGRectMake(0, 0, 60, 21);
    [settingButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    
    if (_userRole == eTeacherType)
    {
        [settingButton setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    }
    else if (_userRole == eParentType)
    {
        [settingButton setImage:[UIImage imageNamed:@"finish"] forState:UIControlStateNormal];
    }
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    // 任务已完成
    if (_completeStatus)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)doSaveAction
{
    // 老师-保存
    if (_userRole == eTeacherType)
    {
        [_taskDescribeTextView resignFirstResponder];
        
        [self getAlterTaskRequest];
    }
    // 家长-完成任务
    else if (_userRole == eParentType)
    {
        [self getSubmitTaskRequest];
    }
}

#pragma mark - 网络请求

- (void)getAlterTaskRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode([_taskId stringValue]) forKey:@"taskId"];
    [parameters setObjectSafe:base64Encode(_taskDescribeTextView.text) forKey:@"task"];

    // 发送请求
    [NetWorkTask postRequest:kRequestEditTask
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestEditTask];
}

- (void)getSubmitTaskRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode([_taskId stringValue]) forKey:@"taskId"];
    [parameters setObjectSafe:base64Encode([_studentId stringValue]) forKey:@"studentId"];

    // 发送请求
    [NetWorkTask postRequest:kRequestSubmitTask
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestSubmitTask];
}

// 请求新闻详情
- (void)getNewsRequest
{
    [self loadingAnimation];
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    
    // 参数
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([_studentId stringValue]) forKey:@"studentId"];
    [parameters setObjectSafe:base64Encode([_taskId stringValue]) forKey:@"taskId"];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestTaskDetail
                 forParamDic:parameters
                searchResult:[[TaskDetailResult alloc] init]
                 andDelegate:self forInfo:kRequestTaskDetail isMockData:kIsMock_RequestTaskDetail];
}

// 删除评论
- (void)getRequestDeleteComment
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    
    [parameters setObjectSafe:base64Encode([_selectCommentInfo.commentId stringValue]) forKey:@"commentId"];

    // 发送请求
    [NetWorkTask postRequest:kRequestDeleteComment
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestDeleteComment];
}

#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    if ([customInfo isEqualToString:kRequestTaskDetail])
    {
        [self getSearchNetBackOfNewsDetail:searchResult forInfo:customInfo];
    }
    else if ([customInfo isEqualToString:kRequestAddComment])
    {
        [self getSearchNetBackOfAddComment:(BusinessSearchNetResult *)searchResult forInfo:customInfo];
    }
    else if ([customInfo isEqualToString:kRequestEditTask])
    {
        [self getSearchNetBackOfEditTask:(BusinessSearchNetResult *)searchResult forInfo:customInfo];
    }
    else if ([customInfo isEqualToString:kRequestSubmitTask])
    {
        [self getSearchNetBackOfSubmitTask:(BusinessSearchNetResult *)searchResult forInfo:customInfo];
    }
    // 删除评论
    else if ([customInfo isEqualToString:kRequestDeleteComment])
    {
        [self getSearchNetBackOfDeleteComment:(BusinessSearchNetResult *)searchResult forInfo:customInfo];
    }
}

// 删除评论
- (void)getSearchNetBackOfDeleteComment:(BusinessSearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        if ([searchResult.status integerValue] == 0)
        {
            // 获取成功
            if ([searchResult.isSuccess integerValue] == 0)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = eDeleteCommentSuccessAlertTag;
                
                [alertView show];
                
            }
            // 失败
            else
            {
                if ([searchResult.businessMsg isKindOfClass:[NSString class]] && [searchResult.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
        }
        else
        {
            if ([searchResult.msg isKindOfClass:[NSString class]] && [searchResult.msg isStringSafe])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }
        
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 完成任务
- (void)getSearchNetBackOfSubmitTask:(BusinessSearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        if ([searchResult.status integerValue] == 0)
        {
            // 获取成功
            if ([searchResult.isSuccess integerValue] == 0)
            {
                self.navigationItem.rightBarButtonItem = nil;
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提交成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = eSubmitSuccessAlertTag;
                
                [alertView show];
                
            }
            // 失败
            else
            {
                if ([searchResult.businessMsg isKindOfClass:[NSString class]] && [searchResult.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
        }
        else
        {
            if ([searchResult.msg isKindOfClass:[NSString class]] && [searchResult.msg isStringSafe])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }
        
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 修改任务
- (void)getSearchNetBackOfEditTask:(BusinessSearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        if ([searchResult.status integerValue] == 0)
        {
            // 获取成功
            if ([searchResult.isSuccess integerValue] == 0)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = eAlterSuceessAlertTag;
                
                [alertView show];
                
            }
            // 失败
            else
            {
                if ([searchResult.businessMsg isKindOfClass:[NSString class]] && [searchResult.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
        }
        else
        {
            if ([searchResult.msg isKindOfClass:[NSString class]] && [searchResult.msg isStringSafe])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }
        
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)getSearchNetBackOfAddComment:(BusinessSearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        if ([searchResult.status integerValue] == 0)
        {
            // 获取成功
            if ([searchResult.isSuccess integerValue] == 0)
            {
                // 刷新页面
                [self getNewsRequest];
            }
            // 失败
            else
            {
                if ([searchResult.businessMsg isKindOfClass:[NSString class]] && [searchResult.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
        }
        else
        {
            if ([searchResult.msg isKindOfClass:[NSString class]] && [searchResult.msg isStringSafe])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"服务异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }
        
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)getSearchNetBackOfNewsDetail:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        TaskDetailResult *parentRelateInfoResult = (TaskDetailResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                _newsResult = parentRelateInfoResult;
                // 刷新页面
                [self refreshPage];
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
    [self stopLoadingAnimation];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - 事件机制

- (void)refreshPage
{
    [_taskDescribeTextView resignFirstResponder];
    
    [_tableView reloadData];
}

#pragma mark - 布局

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height-spaceYStart-44)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [viewParent addSubview:tableView];
    
    _tableView = tableView;
    
    // 评论视图
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if(_keyBoard == nil)
    {
        _keyBoard = [[CustomKeyBoardView alloc] initWithFrame:CGRectMake(0, self.view.height-44, self.view.width, 44)];
    }
    _keyBoard.delegate = self;
    
    _keyBoard.textView.returnKeyType = UIReturnKeySend;
    
    [self.view addSubview:_keyBoard];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    // =======================================================================
    // titleCell
    // =======================================================================
    if (row == 0)
    {
        CGSize contentViewSize = CGSizeMake(tableView.width, 0);
        [self setupViewSubsTitleCell:nil inSize:&contentViewSize];
        
        return contentViewSize.height;
    }
    
    // =======================================================================
    // 内容cell
    // =======================================================================
    if (row == 1)
    {
        CGSize contentViewSize = CGSizeMake(tableView.width, 0);
        [self setupViewSubsContentCell:nil inSize:&contentViewSize];
        
        return contentViewSize.height;
    }
    
    else
    {
        CGSize contentViewSize = CGSizeMake(tableView.width, 0);
        [self setupViewSubsCommentCell:nil inSize:&contentViewSize indexPath:indexPath];
        
        return contentViewSize.height;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2+_newsResult.commentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger curRow = 0;
    
    if (curRow == row)
    {
        NSString *reuseIdentifier = @"EducationChildDetailVCTitleID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell.contentView setBackgroundColor:kWhiteColor];
        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, 0);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsTitleCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    if (curRow == row)
    {
        NSString *reuseIdentifier = @"EducationChildDetailVCContentID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];
        }
        [cell.contentView setBackgroundColor:kWhiteColor];

        CGSize contentViewSize = CGSizeMake(tableView.width, 0);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsContentCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    if (row >= 2)
    {
        NSString *reuseIdentifier = @"TaskDetaiVCCommentCellID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];
        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, 0);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsCommentCell:cell.contentView inSize:&contentViewSize indexPath:indexPath];
        
        // =======================================================================
        // 增加长按手势
        // =======================================================================
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(handleCommentCellLongPressed:)];
        longPress.delegate = self;
        longPress.minimumPressDuration = 1.0;
        //将长按手势添加到需要实现长按操作的视图里
        [cell.contentView addGestureRecognizer:longPress];
        cell.contentView.tag = eCellContentTag+indexPath.row;
        
        return cell;

    }
    
    return nil;
}

#pragma mark - cell布局
- (void)setupViewSubsTitleCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 11;
    NSInteger spaceXStart = 10;
    NSInteger spaceXEnd = viewSize->width;
    
    // =======================================================================
    // title
    // =======================================================================
    
    if ([_newsResult.title isStringSafe])
    {
        UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eTitleLabelTag];
        if (titleLabel == nil)
        {
            titleLabel = [[UILabel alloc] initWithFont:kMiddleTitleFont andText:@"" andColor:[UIColor blackColor] withTag:eTitleLabelTag];
            titleLabel.backgroundColor = kWhiteColor;
            titleLabel.numberOfLines = 0;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:titleLabel];
        }
        titleLabel.text = _newsResult.title;
        
        // 计算尺寸
//        CGSize titleSize = [_newsResult.title sizeWithFont:kMiddleTitleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX)];
        
        CGSize titleSize = [_newsResult.title sizeWithFontCompatible:kMiddleTitleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
        titleLabel.frame = CGRectMake(spaceXStart, spaceYStart, titleSize.width, titleSize.height);
        
        // 调整Y
        spaceYStart += titleSize.height;
    }
    
    // 调整Y
    spaceYStart += 13;
    
    // =======================================================================
    // 学生
    // =======================================================================
    
    // icon
    UIImageView *taskDirectorIcon = (UIImageView *)[viewParent viewWithTag:eTaskDiretorImageViewTag];
    if (taskDirectorIcon == nil)
    {
        taskDirectorIcon = [[UIImageView alloc] init];
        taskDirectorIcon.tag = eTaskDiretorImageViewTag;
        taskDirectorIcon.image = [UIImage imageNamed:@"TaskDirector"];
        [viewParent addSubview:taskDirectorIcon];
    }
    taskDirectorIcon.frame = CGRectMake(spaceXStart, spaceYStart, 15, 15);
    
    // 调整X
    spaceXStart += 15;
    spaceXStart += 3;
    
    // name
    UILabel *subTitleLabel = (UILabel *)[viewParent viewWithTag:eSubsTitleLabelTag];
    if (subTitleLabel == nil)
    {
        subTitleLabel = [[UILabel alloc] initWithFont:kSmallFont andText:@"" andColor:kTextColor withTag:eSubsTitleLabelTag];
        subTitleLabel.backgroundColor = kWhiteColor;
        
        [viewParent addSubview:subTitleLabel];
    }
    
    NSString *taskDirector = [NSString stringWithFormat:@"学生：%@", _newsResult.studentName];
    
    
    // 计算尺寸
    CGSize subTitleSize = [taskDirector sizeWithFontCompatible:kSmallFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

    subTitleLabel.frame = CGRectMake(spaceXStart, spaceYStart, subTitleSize.width, 15);
    subTitleLabel.text = taskDirector;
    
    // =======================================================================
    // 日期
    // =======================================================================
    UILabel *newsDateLabel = (UILabel *)[viewParent viewWithTag:eNewsDateLabelTag];
    if (newsDateLabel == nil)
    {
        newsDateLabel = [[UILabel alloc] initWithFont:kSmallFont andText:_newsResult.deadline andColor:kTextColor withTag:eNewsDateLabelTag];
        newsDateLabel.backgroundColor = kWhiteColor;
        [viewParent addSubview:newsDateLabel];
    }
    
    NSString *newsDate = [NSString stringWithFormat:@"任务时间：%@", _newsResult.deadline];

    CGSize newsDateSize = [newsDate sizeWithFontCompatible:kSmallFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

    newsDateLabel.frame = CGRectMake(viewSize->width-newsDateSize.width-10, spaceYStart, newsDateSize.width, 15);
    newsDateLabel.text = newsDate;
    
    spaceXEnd = viewSize->width-newsDateSize.width-10;
    
    // 调整x
    spaceXEnd -= 5;
    spaceXEnd -= 15;
    
    // icon
    UIImageView *timeIcon = (UIImageView *)[viewParent viewWithTag:eTimeImageViewTag];
    if (timeIcon == nil)
    {
        timeIcon = [[UIImageView alloc] init];
        timeIcon.tag = eTimeImageViewTag;
        timeIcon.image = [UIImage imageNamed:@"TaskTime"];
        [viewParent addSubview:timeIcon];
    }
    timeIcon.frame = CGRectMake(spaceXEnd, spaceYStart, 15, 15);
    
    // 调整Y
    spaceYStart += 15;
    
    // 调整Y
    spaceYStart += 15;
    
    // =======================================================================
    // 调整父尺寸
    // =======================================================================
    viewSize->height = spaceYStart;
    
}

// 内容
- (void)setupViewSubsContentCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 10;
    
    // =======================================================================
    // 任务描述-输入
    // =======================================================================
    if (viewParent)
    {
        GCPlaceholderTextView *taskDescribTextView = (GCPlaceholderTextView *)[viewParent viewWithTag:eContentLabelTag];
        
        if (taskDescribTextView == nil)
        {
            taskDescribTextView = [[GCPlaceholderTextView alloc] initWithFrame:CGRectZero];
            taskDescribTextView.textColor = kTextColor;
            taskDescribTextView.font = kSmallFont;
            taskDescribTextView.returnKeyType = UIReturnKeyDone;
            taskDescribTextView.backgroundColor = [UIColor clearColor];
            taskDescribTextView.delegate = self;
            taskDescribTextView.keyboardType = UIKeyboardTypeDefault;
            taskDescribTextView.scrollEnabled = YES;
            taskDescribTextView.tag = eContentLabelTag;
            
            [viewParent addSubview: taskDescribTextView];
        }
        _taskDescribeTextView = taskDescribTextView;

    }
    
    CGSize newsContentSize = [_newsResult.task sizeWithFontCompatible:kSmallFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    _taskDescribeTextView.text = _newsResult.task;

//    _taskDescribeTextView.frame = CGRectMake(spaceXStart, spaceYStart, newsContentSize.width, _taskDescribeTextView.contentSize.height);
    
    // 已完成不可编辑
    if (_completeStatus)
    {
        _taskDescribeTextView.editable = NO;
    }
    else
    {
        _taskDescribeTextView.editable = YES;
    }

    NSInteger newSizeH;
    newSizeH = newsContentSize.height + 25;
    
    if (_taskDescribeTextView)
    {
        if (kSystemVersion >= 7.0)
        {
            _taskDescribeTextView.frame = CGRectMake(spaceXStart , spaceYStart, viewSize->width-spaceXStart*2, newSizeH);
            _taskDescribeTextView.contentSize = CGSizeMake(viewSize->width-spaceXStart*2, newSizeH);
        }
        else
        {
            CGSize size = [[_taskDescribeTextView text] sizeWithFontCompatible:kSmallFont];
            
            int length = size.height;  // 2. 取出文字的高度
            int colomNumber = _taskDescribeTextView.contentSize.height/length;  //3. 计算行数
            _taskDescribeTextView.frame=CGRectMake(spaceXStart , spaceYStart, viewSize->width-spaceXStart*2, colomNumber*22);
            _taskDescribeTextView.contentSize=CGSizeMake(viewSize->width-spaceXStart*2, spaceYStart+colomNumber*22);
        }
    }
    
    // 调整Y
    spaceYStart += newSizeH;
    
    UIView *separtorView = (UIView *)[viewParent viewWithTag:eContentSepartorViewTag];
    if (separtorView == nil)
    {
        separtorView = [[UIView alloc] init];
        separtorView.backgroundColor = kBackgroundColor;
        separtorView.tag = eContentSepartorViewTag;
        
        [viewParent addSubview:separtorView];
    }
    separtorView.frame = CGRectMake(0, spaceYStart, viewSize->width, 15);
    
    // 调整Y
    spaceYStart += 15;
    
    viewSize->height = spaceYStart;
}

// 评论cell
- (void)setupViewSubsCommentCell:(UIView *)viewParent inSize:(CGSize *)viewSize indexPath:(NSIndexPath *)indexPath
{
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
    NSInteger spaceXEnd = viewSize->width-10;
    
    TaskCommentInfo *commentInfo = _newsResult.commentList[indexPath.row-2];
    
    // =======================================================================
    // 头像
    // =======================================================================
    UIView *portraitView = (UIView *)[viewParent viewWithTag:ePortraitImageViewTag];
    if (portraitView == nil)
    {
        portraitView = [[UIView alloc] initWithFrame:CGRectZero];
        [portraitView.layer setCornerRadius:CGRectGetHeight([portraitView bounds]) / 2];
        portraitView.layer.masksToBounds = YES;
        portraitView.layer.contents = (id)[[UIImage imageNamed:@"000"] CGImage];
        [viewParent addSubview:portraitView];

    }
    portraitView.frame = CGRectMake(spaceXStart, spaceYStart, kPortraitSize, kPortraitSize);
    
    if ([commentInfo.sex boolValue])
    {
        portraitView.layer.contents = (id)[[UIImage imageNamed:@"malePhoto"] CGImage];
    }
    else
    {
        portraitView.layer.contents = (id)[[UIImage imageNamed:@"femalePhoto"] CGImage];
    }
    
    spaceXStart += kPortraitSize;
    spaceXStart += 10;
    
    // 调整Y
    spaceYStart += (kPortraitSize-15)/2.0;
    
    // =======================================================================
    // 姓名
    // =======================================================================
    NSString *nameString = [NSString stringWithFormat:@"%@(%@)",commentInfo.userName, commentInfo.relationship];
    
    UILabel *commentNameLabel = (UILabel *)[viewParent viewWithTag:eCommentNameLabelTag];
    if (commentNameLabel == nil)
    {
        commentNameLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"" andColor:[UIColor colorWithHex:0x4f4f4f alpha:1.0] withTag:eCommentNameLabelTag];
        [viewParent addSubview:commentNameLabel];
    }
    
    CGSize commentNameSize = [nameString sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

    commentNameLabel.frame = CGRectMake(spaceXStart, spaceYStart, commentNameSize.width, commentNameSize.height);
    commentNameLabel.text = nameString;
    
    // =======================================================================
    // 时间
    // =======================================================================
    UILabel *commentTimeLabel = (UILabel *)[viewParent viewWithTag:eCommentTimeLabelTag];
    
    if (commentTimeLabel == nil)
    {
        commentTimeLabel = [[UILabel alloc] initWithFont:kSSmallFont andText:@"" andColor:kTextColor withTag:eCommentTimeLabelTag];
        [viewParent addSubview:commentTimeLabel];
    }
    CGSize dateSize = [commentInfo.date sizeWithFontCompatible:kSmallFont constrainedToSize:CGSizeMake(viewSize->width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    commentTimeLabel.frame = CGRectMake(spaceXEnd-dateSize.width, spaceYStart, dateSize.width, dateSize.height);
    commentTimeLabel.text = commentInfo.date;
    
    // 调整Y
    spaceYStart += kPortraitSize/2.0;
    spaceYStart += 10;
    
    // =======================================================================
    // 内容
    // =======================================================================
    UILabel *commentContentLabel = (UILabel *)[viewParent viewWithTag:eCommentContentLabelTag];
    if (commentContentLabel == nil)
    {
        commentContentLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"" andColor:[UIColor colorWithHex:0x4f4f4f alpha:1.0] withTag:eCommentContentLabelTag];
        commentContentLabel.numberOfLines = 0;
        commentContentLabel.textAlignment = NSTextAlignmentLeft;
        
        [viewParent addSubview:commentContentLabel];
    }
    commentContentLabel.text = commentInfo.comment;
    
    CGSize contentSize = [commentInfo.comment sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width-10*3-kPortraitSize, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

    commentContentLabel.frame = CGRectMake(spaceXStart, spaceYStart, contentSize.width, contentSize.height);
    
    // 调整Y
    spaceYStart += contentSize.height;
    spaceYStart += 5;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *separtorLineView = (UILabel *)[viewParent viewWithTag:eCommentSepartorLineTag];
    if (separtorLineView == nil)
    {
        separtorLineView = [[UIView alloc] initSepartorViewWithFrame:CGRectZero];
        [viewParent addSubview:separtorLineView];
    }
    separtorLineView.frame = CGRectMake(0, spaceYStart, viewSize->width, 1);
    
    // 调整Y
    spaceYStart += 1;
    
    viewSize->height = spaceYStart;
}

#pragma mark - 评论相关
-(void)keyboardShow:(NSNotification *)note
{
    if ([_taskDescribeTextView isFirstResponder])
    {
        [_tableView setContentOffset:CGPointMake(0, 20)];
    }
    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY = keyBoardRect.size.height;
    _keyBoardHeight = deltaY;
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        _keyBoard.transform = CGAffineTransformMakeTranslation(0, -deltaY);
    }];
}
-(void)keyboardHide:(NSNotification *)note
{
//    [_keyBoard.textView resignFirstResponder];
//    _keyBoard.textView.text=@"";
//
//    _keyBoard.frame = CGRectMake(0, self.view.height-44, self.view.width, 44);
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        _keyBoard.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
        _keyBoard.textView.text=@"";
        
        _keyBoard.frame = CGRectMake(0, self.view.height-44, self.view.width, 44);

//        [_keyBoard removeFromSuperview];
    }];
    
}
-(void)keyBoardViewHide:(UITextView *)keyBoardView content:(NSString *)content newsId:(NSNumber *)newsId
{
    if ([content isStringSafe])
    {
        [self loadingAnimation];
        
        keyBoardView.text = nil;
        [keyBoardView resignFirstResponder];
        
        // 发表评论
        // =======================================================================
        // 请求参数：cellPhone 登录账号 password
        // =======================================================================
        NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
        [parameters setObjectSafe:base64Encode([_taskId stringValue]) forKey:@"taskId"];
        [parameters setObjectSafe:base64Encode(content) forKey:@"content"];
        
        // 发送请求
        [NetWorkTask postRequest:kRequestPostComment
                     forParamDic:parameters
                    searchResult:[[BusinessSearchNetResult alloc] init]
                     andDelegate:self forInfo:kRequestPostComment];

    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入评论内容" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (void)publishComment:(UITextView *)keyBoardView newsId:(NSNumber *)newsId content:(NSString *)content
{
    if ([content isStringSafe]) {
        [self loadingAnimation];
        
        keyBoardView.text = nil;
        [keyBoardView resignFirstResponder];
        
        NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
        
        // 发表评论
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
        [parameters setObjectSafe:base64Encode([_taskId stringValue]) forKey:@"taskId"];
        [parameters setObjectSafe:base64Encode(content) forKey:@"comment"];
        
        // 发送请求
        [NetWorkTask postRequest:kRequestAddComment
                     forParamDic:parameters
                    searchResult:[[BusinessSearchNetResult alloc] init]
                     andDelegate:self forInfo:kRequestAddComment];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入评论内容" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    _taskDescribe = textView.text;
    
//    if ([text isEqualToString:@"\n"])
//    {
//        [textView resignFirstResponder];
//        return NO;
//    }
    
    // 删除退格按钮
    if (text.length == 0)
    {
        return YES;
    }
    
    return [textView shouldChangeInRange:range withString:text andLength:200];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_taskDescribeTextView)
    {
        [_taskDescribeTextView resignFirstResponder];
    }
    
    if (_keyBoard && _keyBoard.textView) {
        _keyBoard.textView.text = nil;
        [_keyBoard.textView resignFirstResponder];
        
    }
    
}
#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == eAlterSuceessAlertTag || alertView.tag == eSubmitSuccessAlertTag || alertView.tag == eDeleteCommentSuccessAlertTag)
    {
        // 刷新页面
        [self getNewsRequest];
    }
}

- (void)handleCommentCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.self.view;
    NSInteger tag = view.tag;
    NSInteger selectRow = tag - eCellContentTag;
    
    if (selectRow >= 2 && _newsResult.commentList.count > 0)
    {
        _selectCommentInfo = _newsResult.commentList[selectRow-2];

    }
    
    if (gestureRecognizer.state ==
        UIGestureRecognizerStateBegan) {
        NSLog(@"UIGestureRecognizerStateBegan");
    }
    if (gestureRecognizer.state ==
        UIGestureRecognizerStateChanged) {
        NSLog(@"UIGestureRecognizerStateChanged");
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"UIGestureRecognizerStateEnded");
        
        // 弹出操作列表
        
        CGFloat xWidth = kScreenWidth - 40.0f;
        CGFloat yHeight = kPopCellHeight * (_actionList.count + 1);
        CGFloat yOffset = kNavigationBarHeight + 20;
        
        CGFloat subsHeight = kScreenHeight-kNavigationBarHeight-80;
        
        if (yHeight > subsHeight) {
            yHeight = subsHeight;
        }
        
        UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(20, yOffset, xWidth, yHeight)];
        poplistview.delegate = self;
        poplistview.datasource = self;
        [poplistview setTitle:@"请选择操作"];
        _poplistview = poplistview;
        [_poplistview show];
    }
}

#pragma mark - UIPopoverListViewDataSource

- (UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView
                    cellForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    if (popoverListView == _poplistview)
    {
        static NSString *identifier = @"ProvsListViewCell";
        NSString *objectInfo = _actionList[row];
        
        PopTableViewCell *cell = [[PopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:identifier];
        cell.textLabel.text = objectInfo;
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
    return _actionList.count;
}

#pragma mark - UIPopoverListViewDelegate
- (void)popoverListView:(UIPopoverListView *)popoverListView
     didSelectIndexPath:(NSIndexPath *)indexPath
{
    if (popoverListView == _poplistview)
    {
        // 删除
        if (indexPath.row == 0)
        {
            [self getRequestDeleteComment];
        }
        // 复制
        else if (indexPath.row == 1)
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = _selectCommentInfo.comment;
        }
    }
}

- (CGFloat)popoverListView:(UIPopoverListView *)popoverListView
   heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kPopCellHeight;
}

@end