//
//  FKRSearchBarTableViewController.m
//  TableViewSearchBar
//
//  Created by Fabian Kreiser on 10.02.13.
//  Copyright (c) 2013 Fabian Kreiser. All rights reserved.
//

#import "FKRSearchBarTableViewController.h"
#import "TaskListResult.h"
#import "TaskInfo.h"
#import "TaskDetailVC.h"

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

};

static NSString * const kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier = @"kFKRSearchBarTableViewControllerDefaultTableViewCellIdentifier";

@interface FKRSearchBarTableViewController ()<NetworkPtc>

@property(nonatomic, copy) NSArray *famousPersons;
@property(nonatomic, copy) NSArray *filteredArray;
@property(nonatomic, copy) NSArray *sections;

@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, strong, readwrite) UISearchBar *searchBar;

@property(nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;

// add
@property (nonatomic, strong) NSString *fiterText;
@property (nonatomic, strong) TaskListResult *taskListResult;
@property (nonatomic, assign) NSInteger taskType;
@property (nonatomic, assign) NSInteger userRole;      // 用户角色

@end

@implementation FKRSearchBarTableViewController

#pragma mark - Initializer

- (id)initWithSectionIndexes:(BOOL)showSectionIndexes
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.title = @"Search Bar";
        
        _showSectionIndexes = showSectionIndexes;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Top100FamousPersons" ofType:@"plist"];
        _famousPersons = [[NSArray alloc] initWithContentsOfFile:path];
        
        if (showSectionIndexes) {
            UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
            
            NSMutableArray *unsortedSections = [[NSMutableArray alloc] initWithCapacity:[[collation sectionTitles] count]];
            for (NSUInteger i = 0; i < [[collation sectionTitles] count]; i++) {
                [unsortedSections addObject:[NSMutableArray array]];
            }
            
            for (NSString *personName in self.famousPersons) {
                NSInteger index = [collation sectionForObject:personName collationStringSelector:@selector(description)];
                [[unsortedSections objectAtIndex:index] addObject:personName];
            }
            
            NSMutableArray *sortedSections = [[NSMutableArray alloc] initWithCapacity:unsortedSections.count];
            for (NSMutableArray *section in unsortedSections) {
                [sortedSections addObject:[collation sortedArrayFromArray:section collationStringSelector:@selector(description)]];
            }
            
            self.sections = sortedSections;
        }
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // =======================================================================
    // 列表
    // =======================================================================
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-2) style:UITableViewStylePlain];
    tableView.backgroundColor = kWhiteColor;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
//    [viewParent addSubview:tableView];
    
    _tableView = tableView;
    
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.placeholder = @"输入关键字搜索";
    self.searchBar.delegate = self;
    self.searchBar.barStyle = UIBarStyleDefault;

    if ([self.searchBar respondsToSelector:@selector(barTintColor)]) {
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.1) {
            //ios7.1
            [[[[self.searchBar.subviews objectAtIndex:0] subviews] objectAtIndex:0] removeFromSuperview];
            [self.searchBar setBackgroundColor:kBackgroundGreenColor];
        }else{
            //ios7.0
            [self.searchBar setBarTintColor:[UIColor clearColor]];
            [self.searchBar setBackgroundColor:kBackgroundGreenColor];
        }
    }else{
        //iOS7.0 以下
        [[self.searchBar.subviews objectAtIndex:0] removeFromSuperview];
        [self.searchBar setBackgroundColor:kBackgroundGreenColor];
    }
    
    // 背景
    for (UIView *view in [[self.searchBar.subviews lastObject] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *cancelBtn = (UIButton *)view;
            [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
            [cancelBtn setTitleColor:kWhiteColor forState:UIControlStateNormal];
            [cancelBtn setTintColor:kWhiteColor];
        }
    }
    
    // =======================================================================
    // 设置textField样式
    // =======================================================================

    UIView *searchTextField = nil;
    // textfield背景
    if (kSystemVersion >= 7.1)
    {
        self.searchBar.barTintColor = [UIColor whiteColor];
        
        searchTextField = [[[self.searchBar.subviews firstObject] subviews] lastObject];
    }
    else
    { // iOS6以下版本searchBar内部子视图的结构不一样
        for (UIView *subView in self.searchBar.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                searchTextField = subView;
            }
        }
        
    }
    
    searchTextField.backgroundColor = [UIColor colorWithHex:0X039A9B alpha:1.0];
//    searchTextField.tintColor = kWhiteColor;
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    // Change search bar text color
    searchField.textColor = kWhiteColor;
    // Change the search bar placeholder text color
    [searchField setValue:kWhiteColor forKeyPath:@"_placeholderLabel.textColor"];
//    searchField.background = [UIImage imageNamed:@""];
    [_searchBar setImage:[UIImage imageNamed:@""] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];

    
//    self.searchBar.backgroundColor = [UIColor clearColor];
//    for (UIView *subview in self.searchBar.subviews)
//    {
//        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
//        {
//            [subview removeFromSuperview];
//            break;  
//        }   
//    }
    
//    //为UISearchBar添加背景图片
//    UIView *segment = [self.searchBar.subviews objectAtIndex:0];
//    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageFromColor:kBackgroundGreenColor]];
//    [segment addSubview: bgImage];
    
    [self.searchBar sizeToFit];
    
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.delegate = self;
    
    [self getTaskRequest];
}
// 导航
- (void)setupDisplayVCNavigationBar
{
    if (kSystemVersion >= 7.0)
    {
        // 导航背景色
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:1/255.0 green:186/255.0 blue:188/255.0 alpha:1.0]];
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:1/255.0 green:186/255.0 blue:188/255.0 alpha:1.0]];
    }
    
    // 状态栏颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

#pragma mark 搜索框的代理方法，搜索输入框获得焦点（聚焦）
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];	// 修改UISearchBar右侧的取消按钮文字颜色及背景图片
    for (UIView *searchbuttons in [searchBar subviews])
    {
        if ([searchbuttons isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)searchbuttons;			// 修改文字颜色
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
    }
}


#pragma mark - 网络请求
- (void)getTaskRequest
{
    [self loadingAnimation];
    
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"pageIndex"];
    [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"pageSize"];
    
    // 过滤条件
    [parameters setObjectSafe:base64Encode(_fiterText) forKey:@"filter"];
    
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
                if (_strongSearchDisplayController && _strongSearchDisplayController.searchResultsTableView)
                {
                    [_strongSearchDisplayController.searchResultsTableView reloadData];
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

- (void)getSearchNetBackWithFailure:(id)customInfo
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (animated) {
        [self.tableView flashScrollIndicators];
    }
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    NSAssert(YES, @"This method should be handled by a subclass!");
}

#pragma mark - TableView Delegate and DataSource
#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMyCellHeight;
}

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
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Search Delegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
//    self.filteredArray = _taskListResult.taskList;
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.filteredArray = nil;
}
- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller NS_DEPRECATED_IOS(3_0,8_0);
{
//    _fiterText = controller.searchBar.text;
//    
//    [self getTaskRequest];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _fiterText = searchString;
    
    [self getTaskRequest];
    
    return YES;
}


#pragma mark - cell
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
    
    TaskInfo *taskInfo;
    if (_taskListResult.taskList.count > indexPath.row)
    {
        taskInfo = _taskListResult.taskList[indexPath.row];
    }
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

- (void)doDeleteAction:(CustomButton *)button
{
    TaskInfo *taskInfo = button.customInfo;
    
    if ([taskInfo.completeStatus integerValue] == 0)
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
            [parameters setObjectSafe:base64Encode([taskInfo.taskId stringValue]) forKey:@"taskId"];
            [parameters setObjectSafe:base64Encode([taskInfo.studentId stringValue]) forKey:@"studentId"];
            
            // 发送请求
            [NetWorkTask postRequest:kRequestDeleteTask
                         forParamDic:parameters
                        searchResult:[[BusinessSearchNetResult alloc] init]
                         andDelegate:self forInfo:kRequestDeleteTask];
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == eDeleteSuccessAlertTag) {
        [_tableView reloadData];
    }
}
@end