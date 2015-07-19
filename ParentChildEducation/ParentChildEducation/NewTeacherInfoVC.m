//
//  NewTeacherInfoVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/16.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "NewTeacherInfoVC.h"
#import "TeacherInfoResult.h"

#define kMyCellHeight                   50
#define kResumeCellHeight               200
#define kTotalCellCount                 6

@interface NewTeacherInfoVC ()<UITableViewDataSource, UITableViewDelegate, NetworkPtc, UITextViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TeacherInfoResult *teacherInfoResult;

@property (nonatomic, strong) UILabel *nameTitleLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *sexTitleLabel;
@property (nonatomic, strong) UILabel *sexLabel;

@property (nonatomic, strong) UILabel *courseTitleLabel;
@property (nonatomic, strong) UILabel *courseLabel;

@property (nonatomic, strong) UILabel *birthTitleLabel;
@property (nonatomic, strong) __block UILabel *birthLabel;

@property (nonatomic, strong) UILabel *cellPhoneTitleLabel;
@property (nonatomic, strong) UILabel *cellPhoneLabel;

@property (nonatomic, strong) UILabel *resumeLabel;

@end

@implementation NewTeacherInfoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupRootViewSubs:self.view];
    
    [self getSearchTeacherInfo];
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 0;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height-spaceYStart-10)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [viewParent addSubview:tableView];
    
    _tableView = tableView;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kTotalCellCount-1) {
        return 200;
    }
    else {
        return 50;
    }
   
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kTotalCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger curRow = 0;
    
    // 姓名
    if (curRow == row) {
        NSString *reuseIdentifier = @"NewTeacherInfoVCNameId";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];
        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, kMyCellHeight);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsNameCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    // 性别
    if (curRow == row) {
        NSString *reuseIdentifier = @"NewTeacherInfoVCSexId";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, kMyCellHeight);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsSexCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    // 所授课程
    if (curRow == row) {
        NSString *reuseIdentifier = @"NewTeacherInfoVCCourseId";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, kMyCellHeight);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsCourseCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    
    
    // 出生日期
    if (curRow == row) {
        NSString *reuseIdentifier = @"NewTeacherInfoVCBirthId";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, kMyCellHeight);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
            [self setupViewSubsBirthCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    if (curRow == row) {
        NSString *reuseIdentifier = @"NewTeacherInfoVCCellPhoneId";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, kMyCellHeight);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
            [self setupViewSubsCellPhoneCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    if (curRow == row) {
        NSString *reuseIdentifier = @"NewTeacherInfoVCResumeId";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kBackgroundColor];
        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, kResumeCellHeight);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
            [self setupViewSubsResumeCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
   
    return nil;
}

#pragma mark - cell布局
- (void)setupViewSubsNameCell:(UIView *)viewParent inSize:(CGSize *)viewSize
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
        titleLabel.textAlignment = NSTextAlignmentLeft;
        
        [viewParent addSubview:titleLabel];
        
        _nameTitleLabel = titleLabel;
    }
    _nameTitleLabel.frame = CGRectMake(kTextFieldLMargin, 1, 16*3, viewParent.height-1);
    _nameTitleLabel.text = @"姓名：";
    
    if (_teacherInfoResult && [_teacherInfoResult.teacherName isStringSafe])
    {
        if (_nameLabel == nil) {
            _nameLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"姓名：" andColor:kTextColor];
            _nameLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:_nameLabel];
        }
        _nameLabel.frame = CGRectMake(_nameTitleLabel.right, 1, kScreenWidth-_nameTitleLabel.right, viewParent.height-1);
        _nameLabel.text = _teacherInfoResult.teacherName;

    }
    
}

// 性别
- (void)setupViewSubsSexCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    // =======================================================================
    // 顶部分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // =======================================================================
    // title
    // =======================================================================
    if (_sexTitleLabel == nil)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"姓名：" andColor:kTextColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        
        [viewParent addSubview:titleLabel];
        
        _sexTitleLabel = titleLabel;
    }
    _sexTitleLabel.frame = CGRectMake(kTextFieldLMargin, 1, 16*3, viewParent.height-1);
    _sexTitleLabel.text = @"性别：";
    
    if (_teacherInfoResult && _teacherInfoResult.teacherSex)
    {
        if (_sexLabel == nil) {
            _sexLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"性别：" andColor:kTextColor];
            _sexLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:_sexLabel];
        }
        _sexLabel.frame = CGRectMake(_sexTitleLabel.right, 1, kScreenWidth-_sexTitleLabel.right, viewParent.height-1);
        if ([_teacherInfoResult.teacherSex boolValue])
        {
            _sexLabel.text = @"男";
        }
        else
        {
            _sexLabel.text = @"女";
        }
        
    }
    
}

// 课程
- (void)setupViewSubsCourseCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    // =======================================================================
    // 顶部分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // =======================================================================
    // title
    // =======================================================================
    if (_courseTitleLabel == nil)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"所授课程：" andColor:kTextColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        
        [viewParent addSubview:titleLabel];
        
        _courseTitleLabel = titleLabel;
    }
    _courseTitleLabel.frame = CGRectMake(kTextFieldLMargin, 1, 16*5, viewParent.height-1);
    _courseTitleLabel.text = @"所授课程：";
    
    if (_teacherInfoResult && [_teacherInfoResult.teacherName isStringSafe])
    {
        if (_courseLabel == nil) {
            _courseLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"姓名：" andColor:kTextColor];
            _courseLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:_courseLabel];
        }
        _courseLabel.frame = CGRectMake(_courseTitleLabel.right, 1, kScreenWidth-_courseTitleLabel.right, viewParent.height-1);
        _courseLabel.text = _teacherInfoResult.course;
        
    }
    
}
- (void)setupViewSubsBirthCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    // =======================================================================
    // 顶部分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // =======================================================================
    // title
    // =======================================================================
    if (_birthTitleLabel == nil)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"出生日期：" andColor:kTextColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;

        [viewParent addSubview:titleLabel];
        
        _birthTitleLabel = titleLabel;
    }
    _birthTitleLabel.frame = CGRectMake(kTextFieldLMargin, 1, 16*5, viewParent.height-1);
    _birthTitleLabel.text = @"出生日期：";
    
    if (_teacherInfoResult && [_teacherInfoResult.teacherBirth isStringSafe])
    {
        if (_birthLabel == nil) {
            _birthLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"姓名：" andColor:kTextColor];
            _birthLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:_birthLabel];
        }
        _birthLabel.frame = CGRectMake(_birthTitleLabel.right, 1, kScreenWidth-_birthTitleLabel.right, viewParent.height-1);
        _birthLabel.text = _teacherInfoResult.teacherBirth;
    }
    

}


- (void)setupViewSubsCellPhoneCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    // =======================================================================
    // 顶部分割线
    // =======================================================================
    UIView *topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, 0, viewParent.width, 0.5)];
    [viewParent addSubview:topLine];
    
    // =======================================================================
    // title
    // =======================================================================
    if (_cellPhoneTitleLabel == nil)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@"姓名：" andColor:kTextColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;

        [viewParent addSubview:titleLabel];
        
        _cellPhoneTitleLabel = titleLabel;
    }
    _cellPhoneTitleLabel.frame = CGRectMake(kTextFieldLMargin, 1, 16*5, viewParent.height-1);
    _cellPhoneTitleLabel.text = @"电话号码：";
    
    if (_teacherInfoResult && [_teacherInfoResult.cellPhone isStringSafe])
    {
        if (_cellPhoneLabel == nil) {
            _cellPhoneLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:@" " andColor:kTextColor];
            _cellPhoneLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:_cellPhoneLabel];
        }
        _cellPhoneLabel.frame = CGRectMake(_cellPhoneTitleLabel.right, 1, kScreenWidth-_cellPhoneTitleLabel.right, viewParent.height-1);
        _cellPhoneLabel.text = _teacherInfoResult.cellPhone;
    }
    
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *bottomLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, viewParent.height-1, viewParent.width, 0.5)];
    [viewParent addSubview:bottomLine];
    
}


- (void)setupViewSubsResumeCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    UITextView *textView = [[UITextView  alloc] initWithFrame:CGRectMake(10, 10, viewParent.width-20, viewParent.height-10)];
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
    textView.editable = NO;
    [viewParent addSubview: textView];
    
    if (_teacherInfoResult && [_teacherInfoResult.resume isStringSafe])
    {
        textView.text = [NSString stringWithFormat:@"%@%@", @"履历：", _teacherInfoResult.resume];
    }
}

#pragma mark - 网络
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

- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}

@end
