//
//  AddTaskVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/6/3.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "AddTaskVC.h"
#import "GCPlaceholderTextView.h"
#import "StudentListView.h"

#import "StudentInfo.h"
#import "StudentListResult.h"

#import "BirthdayVC.h"

#define kSection2CellHeight                 200

typedef NS_ENUM(NSInteger, ControllTag)
{
    eSepartorLineTag = 1,
    ePublishSuccessAlertTag,
};

@interface AddTaskVC ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, NetworkPtc, BirthdayVCDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITextField *titleTextField;
@property (nonatomic, strong) GCPlaceholderTextView *taskDescribeTextView;
@property (nonatomic, strong) NSString *taskTitle;
@property (nonatomic, strong) NSString *taskDescribe;

@property (nonatomic, assign) BOOL isHasRequestStudentList;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BirthdayVC *birthdayVC;
@property (nonatomic, strong) NSString *studentBirth;

@property (nonatomic, strong) UIView *inputCellBackGroundView;

@end

@implementation AddTaskVC

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _studentList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)refreshPage
{
    [_tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isHasRequestStudentList = NO;
    
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
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (_titleTextField)
    {
//        [_tableView setContentOffset:CGPointMake(0, 150)];
    }
    
    if (_taskDescribeTextView)
    {
//        [_tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES];

    }
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    
}

#pragma mark - 布局
- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height-spaceYStart)
                                                          style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [viewParent addSubview:tableView];
    _tableView = tableView;
    
    // 添加手势，触摸即键盘消失
//    UITapGestureRecognizer *dismissKeyboardTap = [[UITapGestureRecognizer alloc] initWithTarget:self                                                 action:@selector(dismissKeyboard)];
//    [tableView addGestureRecognizer:dismissKeyboardTap];
}

// 输入cell
- (void)setupViewSubsInputCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
    
    // =======================================================================
    // 背景
    // =======================================================================
    if (_inputCellBackGroundView == nil)
    {
        _inputCellBackGroundView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewSize->width-spaceXStart*2, kSection2CellHeight-spaceYStart*2)];
        _inputCellBackGroundView.backgroundColor = kARGBColor(250, 250, 250, 1);
        _inputCellBackGroundView.layer.borderWidth = 1.0;
        _inputCellBackGroundView.layer.borderColor = kSepartorLineColor.CGColor;
        _inputCellBackGroundView.layer.cornerRadius = 4.0;
        
        [viewParent addSubview:_inputCellBackGroundView];
    }
    _inputCellBackGroundView.frame = CGRectMake(spaceXStart, spaceYStart, viewSize->width-spaceXStart*2, kSection2CellHeight-spaceYStart*2);
    
    // 调整Y
    spaceYStart += 1;
    spaceXStart += 5;
    
    // =======================================================================
    // 任务标题
    // =======================================================================
    if (_titleTextField == nil)
    {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        [textField setTextColor:kTextColor];
        [textField setBackgroundColor:[UIColor clearColor]];
        [textField setFont:kSmallTitleFont];
        [textField setPlaceholder:@"请输入任务标题"
                 placeholderColor:kTextColor
              placeholderFontSize:kSmallTitleFont];
        [textField setDelegate:self];
        [textField setClearsOnBeginEditing:NO];
        [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField addTarget:self action:@selector(titleChanged:) forControlEvents:UIControlEventEditingChanged];
        
        // 保存
        [viewParent addSubview:textField];
        
        _titleTextField = textField;
    }
    [_titleTextField setFrame:CGRectMake(spaceXStart+10, spaceYStart, _inputCellBackGroundView.width-spaceXStart*2, 34)];
    
    if ([_taskTitle isStringSafe])
    {
        _titleTextField.text = _taskTitle;
    }
    
    // 调整Y
    spaceYStart += 34;
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *separtorLine = (UIView *)[viewParent viewWithTag:eSepartorLineTag];
    if (separtorLine == nil)
    {
        separtorLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(_titleTextField.left, spaceYStart, _titleTextField.width, 0.5)];
        [viewParent addSubview:separtorLine];
    }
    separtorLine.frame = CGRectMake(_titleTextField.left, spaceYStart, _titleTextField.width, 0.5);
    
    // 调整Y
    spaceYStart += 1;
    
    // =======================================================================
    // 任务描述-输入
    // =======================================================================
    if (_taskDescribeTextView == nil)
    {
        _taskDescribeTextView = [[GCPlaceholderTextView alloc] initWithFrame:CGRectZero];
        _taskDescribeTextView.textColor = kTextColor;
        _taskDescribeTextView.font = kSmallTitleFont;
        _taskDescribeTextView.placeholderColor = kTextColor;
        _taskDescribeTextView.placeholder = NSLocalizedString(@"请输入任务描述",);
        _taskDescribeTextView.returnKeyType = UIReturnKeyDone;
        _taskDescribeTextView.backgroundColor = [UIColor clearColor];
        _taskDescribeTextView.delegate = self;
        _taskDescribeTextView.scrollEnabled = YES;

        [viewParent addSubview: _taskDescribeTextView];
    }
    _taskDescribeTextView.frame = CGRectMake(spaceXStart+3, spaceYStart, _titleTextField.width, kSection2CellHeight-spaceYStart);

    if ([_taskDescribe isStringSafe])
    {
        _taskDescribeTextView.text = _taskDescribe;
    }
    
}

#pragma mark - 网络请求
- (void)getStudentListRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *classId = [kSaveData objectForKey:kClassIdKey];

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([classId stringValue]) forKey:@"classId"];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestStudentList
                 forParamDic:parameters
                searchResult:[[StudentListResult alloc] init]
                 andDelegate:self forInfo:kRequestStudentList];
}

- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    
    if ([customInfo isEqualToString:kRequestPublishTask])
    {
        [self getSearchNetBackOfPublishTask:searchResult forInfo:customInfo];

    }
    else if ([customInfo isEqualToString:kRequestStudentList])
    {
        [self getSearchNetBackOfStudentList:searchResult forInfo:customInfo];
    }
    
}

// 学生列表回调
- (void)getSearchNetBackOfStudentList:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        StudentListResult *parentRelateInfoResult = (StudentListResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                // 刷新页面
                if (parentRelateInfoResult.studentList)
                {
                    _studentList = parentRelateInfoResult.studentList;
                    _isHasRequestStudentList = YES;
                    
                    StudentListView *studentListView = [[StudentListView alloc] initWithStudentList:_studentList delegate:self];
                    
                    [self.view addSubview:studentListView];
                }
            }
            // 失败
            else
            {
                NSString *errorString = @"请求失败";
                
                if ([parentRelateInfoResult.businessMsg isKindOfClass:[NSString class]] &&[parentRelateInfoResult.businessMsg isStringSafe])
                {
                    errorString = parentRelateInfoResult.businessMsg;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
        }
        else
        {
            NSString *errorString = @"服务异常";
            
            if ([parentRelateInfoResult.msg isKindOfClass:[NSString class]] &&[parentRelateInfoResult.msg isStringSafe])
            {
                errorString = parentRelateInfoResult.msg;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 发布任务回调
- (void)getSearchNetBackOfPublishTask:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        BusinessSearchNetResult *parentRelateInfoResult = (BusinessSearchNetResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                NSString *successMsg = @"发布成功";
                
                if (parentRelateInfoResult.businessMsg && [parentRelateInfoResult.businessMsg isStringSafe])
                {
                    successMsg = parentRelateInfoResult.businessMsg;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:successMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = ePublishSuccessAlertTag;
                [alertView show];
            }
            // 失败
            else
            {
                NSString *errorString = @"请求失败";
                
                if ([parentRelateInfoResult.businessMsg isKindOfClass:[NSString class]] &&[parentRelateInfoResult.businessMsg isStringSafe])
                {
                    errorString = parentRelateInfoResult.businessMsg;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
        }
        else
        {
            NSString *errorString = @"服务异常";
            
            if ([parentRelateInfoResult.msg isKindOfClass:[NSString class]] &&[parentRelateInfoResult.msg isStringSafe])
            {
                errorString = parentRelateInfoResult.msg;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
    if (indexPath.section == 0)
    {
        return 45;
    }
    else if (indexPath.section == 1)
    {
        return kSection2CellHeight;
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 80;
    }
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // 选择学生列表
        if (indexPath.row == 0)
        {
            if (_isHasRequestStudentList)
            {
                // 弹出学生列表
                StudentListView *studentListView = [[StudentListView alloc] initWithStudentList:_studentList delegate:self];
                
                [self.view addSubview:studentListView];
            }
            else
            {
                // 请求学生列表
                [self getStudentListRequest];
            }
        }
        if (indexPath.row == 1)
        {
            [self doSelectCalendar:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 1;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (section == 0)
    {
        NSString *reuseIdentifier = @"AddTaskVCID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.textLabel setTextColor:kTextColor];
        }
        
        if (row == 0)
        {
            [cell.imageView setImage:[UIImage imageNamed:@"PeopleIcon"]];
            [cell.textLabel setText:@"选择学生"];
            
            int count = 0;
            NSMutableString *selectInfo = [[NSMutableString alloc] init];
            for (StudentInfo *studentInfo in _studentList)
            {
                if (studentInfo.status)
                {
                    count++;
                    [selectInfo appendString:[NSString stringWithFormat:@"%@ ",studentInfo.name]];
                }
                
                if (count == 3)
                {
                    [selectInfo appendString:@"..."];
                    break;

                }
            }
            
            if ([selectInfo isStringSafe])
            {
                [cell.textLabel setText:selectInfo];
            }

        }
        else if (row == 1)
        {
            [cell.imageView setImage:[UIImage imageNamed:@"TimeIcon"]];
            [cell.textLabel setText:@"设置任务截止时间"];
            
            if ([_studentBirth isStringSafe])
            {
                [cell.textLabel setText:_studentBirth];
            }
        }
        
        return cell;
        
    }
    
    else if (section == 1)
    {
        NSString *reuseIdentifier = @"AddTaskVCInputCellID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        CGSize contentViewSize = CGSizeMake(tableView.width, 0);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsInputCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, tableView.width, 10);
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, tableView.width, 80);
        view.backgroundColor = kWhiteColor;
        
        UIButton *logOutBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [logOutBtn setTitle:@"确认添加任务" forState:UIControlStateNormal];
        [logOutBtn addTarget:self action:@selector(doAddTaskAction) forControlEvents:UIControlEventTouchUpInside];
        logOutBtn.titleLabel.font = kSmallTitleFont;
        logOutBtn.frame = CGRectMake(40, 30, view.width - 40*2, view.height-40) ;
        logOutBtn.tintColor = [UIColor whiteColor];
        logOutBtn.backgroundColor = kBackgroundGreenColor;
        logOutBtn.layer.cornerRadius = 20;
        [view addSubview:logOutBtn];
        
        return view;
        
    }
    else
    {
        return nil;
    }
}

- (void)doAddTaskAction
{
    NSMutableArray *stuIdArray = [[NSMutableArray alloc] init];
    
    // 学生列表
    for (StudentInfo *info in _studentList) {
        if (info.status)
        {
            [stuIdArray addObject:info.studentId];
        }
    }
    
    if (stuIdArray.count == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择学生" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if (![_studentBirth isStringSafe])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择截止日期" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if (![_taskTitle isStringSafe])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入任务标题" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if (![_taskDescribeTextView.text isStringSafe])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入任务描述" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        [self loadingAnimation];
        
        // =======================================================================
        // 请求参数：cellPhone 登录账号 password
        // =======================================================================
        NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
        [parameters setObjectSafe:base64Encode(_studentBirth) forKey:@"deadline"];
        
        [parameters setObjectSafe:base64Encode(_taskTitle) forKey:@"title"];
        [parameters setObjectSafe:base64Encode(_taskDescribeTextView.text) forKey:@"task"];

//        [parameters setObject:base64Encode([stuIdArray JSONString]) forKey:@"students"];
//        NSNumber *iddd = stuIdArray[0];
//        
//        [parameters setObjectSafe:base64Encode([iddd stringValue]) forKey:@"students"];
//        [parameters setObjectSafe:stuIdArray forKey:@"students"];

        // 发送请求 
        [NetWorkTask postRequestWithArray:kRequestPublishTask forParamDic:parameters searchResult:[[BusinessSearchNetResult alloc] init] andDelegate:self forArray:stuIdArray forInfo:kRequestPublishTask];
        
//        [NetWorkTask postRequest:kRequestPublishTask forParamDic:parameters searchResult:[[BusinessSearchNetResult alloc] init]andDelegate:self forInfo:kRequestPublishTask];
    }
    
}

// 触碰隐藏键盘
- (void)dismissKeyboard
{
    
}

- (void)doSelectCalendar:(UIButton *)sender
{
    _birthdayVC = [[BirthdayVC alloc] initWithName:@"选择任务日期"];
    [_birthdayVC setDelegate:self];
    [_birthdayVC setMinValidDate:[NSDate date]];
    
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
    
    _studentBirth = birthdayText;
    
    [_tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_titleTextField resignFirstResponder];
    [_taskDescribeTextView resignFirstResponder];
}

//恢复原始视图位置
-(void)resumeView
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //如果当前View是父视图，则Y为20个像素高度，如果当前View为其他View的子视图，则动态调节Y的高度
    float Y = 0.0f;
    CGRect rect=CGRectMake(0.0f,Y,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
}

#pragma mark - UITextViewDelegate

//UITextView的协议方法，当开始编辑时监听
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //上移70个单位，按实际情况设置
    CGRect rect=CGRectMake(0.0f,-160,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _taskDescribe = textView.text;
    
    [textView resignFirstResponder];
    [self resumeView];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    _taskDescribe = textView.text;
    
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    // 删除退格按钮
    if (text.length == 0)
    {
        return YES;
    }
    
    return [textView shouldChangeInRange:range withString:text andLength:200];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _taskTitle = textField.text;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
        // .length == 0,表示输入更多， .length == 1则表示删除
        if (range.location >= 15 && (textField.markedTextRange == nil && range.length == 0)){
            return NO;
        }
    
    return YES;
}

- (void)titleChanged:(UITextField *)sender
{
    // 保存文本
    _taskTitle = [(UITextField *)sender text];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ePublishSuccessAlertTag)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
