//
//  DistributeDynamicVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/21.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "DistributeDynamicVC.h"
#import "SelectPhotoManager.h"
#import "HDetailPictureInfo.h"
#import "GCPlaceholderTextView.h"
#import "MainVC.h"

#define kMaxContentLength               200

typedef NS_ENUM(NSInteger, ControllTag)
{
    eDistributeSuccessAlertTag = 1,
    
    eImageViewTag = 100,
};

@interface DistributeDynamicVC ()<UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, SelectPhotoManagerDelegate, UIScrollViewDelegate, NetworkPtc, UIAlertViewDelegate>

@property (nonatomic, strong) GCPlaceholderTextView *distributeTextView;
@property (nonatomic, strong) NSString *distributeString;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *upImagesArray;
@property (nonatomic, strong) SelectPhotoManager *selectPhotoManager;
@property (nonatomic, strong) UIButton *settingButton;

@end

@implementation DistributeDynamicVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _upImagesArray = [[NSMutableArray alloc] init];
    _selectPhotoManager = [[SelectPhotoManager alloc] init];
    
    [self setDistributeItem];
    
    // 根视图
    [self setupRootViewSubs:self.view];
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
    _tableView = tableView;
    
}

// 输入cell
- (void)setupViewSubsInputCell:(UIView *)viewParent
{
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
    
    // =======================================================================
    // 手机号输入
    // =======================================================================
    if (_distributeTextView == nil)
    {
        _distributeTextView = [[GCPlaceholderTextView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width-spaceXStart*2, viewParent.height-spaceYStart)];
        _distributeTextView.textColor = kTextColor;
        _distributeTextView.font = kSmallTitleFont;
        _distributeTextView.placeholderColor = kTextColor;
        _distributeTextView.placeholder = NSLocalizedString(@"编辑内容",);
        _distributeTextView.returnKeyType = UIReturnKeyDone;
        _distributeTextView.backgroundColor = kWhiteColor;
        _distributeTextView.delegate = self;
        _distributeTextView.scrollEnabled = YES;
        [viewParent addSubview: _distributeTextView];
    }
    _distributeTextView.frame = CGRectMake(spaceXStart, spaceYStart, viewParent.width-spaceXStart*2, viewParent.height-spaceYStart);
    _distributeTextView.text = _distributeString;
}

// 图片cell
- (void)setupViewSubsImagesCell:(UIView *)viewParent
{
    [viewParent removeAllSubviews];
    
    NSInteger spaceYStart = 5;
    NSInteger spaceXStart = 15;
    
    if (_upImagesArray && _upImagesArray.count > 0)
    {
        for (int i = 0; i < _upImagesArray.count; i++)
        {
            // 图片信息
            HDetailPictureInfo *detailPictureInfo = _upImagesArray[i];
            ALAsset *asset = detailPictureInfo.asset;
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            
            UIImageView *imageView = (UIImageView *)[viewParent viewWithTag:eImageViewTag+i];
            if (imageView == nil)
            {
                imageView = [[UIImageView alloc] init];
                imageView.tag = eImageViewTag+i;
                [viewParent addSubview:imageView];
            }
            
            imageView.frame = CGRectMake(spaceXStart, spaceYStart, viewParent.height-10, viewParent.height-10);
            imageView.image = image;
            
            
            // 调整X
            spaceXStart += imageView.width;
            spaceXStart += 7;
            
        }
    }
}

// 图片cell
- (void)setupViewSubsSelectCell:(UIView *)viewParent
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
    
    // =======================================================================
    // 图片选择
    // =======================================================================
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectZero];
    selectView.frame = CGRectMake(0, spaceYStart, kScreenWidth-100, viewParent.height-2);
    selectView.backgroundColor = kWhiteColor;
    
    [viewParent addSubview:selectView];
    // 子视图
    [self setupViewSubsSelectView:selectView];
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *bottomLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(spaceXStart, viewParent.height-1, viewParent.width, 0.5)];
    [viewParent addSubview:bottomLine];
}

- (void)setupViewSubsSelectView:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 20;
    
    // 选择Icon
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    iconImageView.frame = CGRectMake(spaceXStart, (viewParent.height-19)/2, 22, 19);
    iconImageView.image = [UIImage imageNamed:@"AddImageIcon"];
    [viewParent addSubview:iconImageView];
    
    // 调整X
    spaceXStart += iconImageView.width;
    spaceXStart += 10;
    
    // 提示
    UILabel *tintLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:@"点击添加图片" andColor:kTextColor];
    tintLabel.frame = CGRectMake(spaceXStart, spaceYStart, viewParent.width-spaceXStart, viewParent.height);
    tintLabel.textAlignment = NSTextAlignmentLeft;
    [viewParent addSubview:tintLabel];
    
    UIButton *clickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clickButton.backgroundColor = [UIColor clearColor];
    clickButton.frame = viewParent.frame;
    [clickButton addTarget:self action:@selector(doSelectImageAction) forControlEvents:UIControlEventTouchUpInside];
    [viewParent addSubview:clickButton];
    
}

#pragma mark - 事件处理
// 选择图片
- (void)doSelectImageAction
{
    [_selectPhotoManager choosePhotoWithPresentViewController:self touchData:_upImagesArray];
}

#pragma mark - 选择图片回调
- (void)choosePhotoBack:(NSMutableArray *)arrayPictureInfo upStatus:(NSInteger)upStatus;
{
    [_upImagesArray removeAllObjects];
    
    [_upImagesArray addObjectsFromArray:arrayPictureInfo];
    
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    // 内容输入
    if (row == 0)
    {
        return 200;
    }
    
    if (row == 1) {
        return (kScreenWidth-51)/4+10;
    }
    
    return 45;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger curRow = 0;
    
    if (curRow == row)
    {
        NSString *reuseIdentifier = @"DistributeDynamicVCInputID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];
        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, 200);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsInputCell:cell.contentView];
        
        return cell;
    }
    curRow++;
    
    if (curRow == row)
    {
        NSString *reuseIdentifier = @"DistributeDynamicVCImagesID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];
        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, (kScreenWidth-51)/4+10);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsImagesCell:cell.contentView];
        
        return cell;
    }
    curRow++;
    
    if (curRow == row)
    {
        NSString *reuseIdentifier = @"DistributeDynamicVCSelectID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.contentView setBackgroundColor:kWhiteColor];

        }
        
        CGSize contentViewSize = CGSizeMake(tableView.width, 45);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsSelectCell:cell.contentView];
        
        return cell;
    }
    curRow++;
    
    return nil;
}

// 发布按钮
- (void)setDistributeItem
{
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setTitle:@"发送" forState:UIControlStateNormal];
    [settingButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(doDistributeAction) forControlEvents:UIControlEventTouchUpInside];
    settingButton.frame = CGRectMake(0, 0, 50, 21);
    
    _settingButton = settingButton;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

// 发布
- (void)doDistributeAction
{
    [_distributeTextView resignFirstResponder];
    
    [_settingButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [_settingButton setEnabled:NO];
    
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode(_distributeTextView.text) forKey:@"content"];
    
    NSNumber *classId = [kSaveData objectForKey:kClassIdKey];
    [parameters setObjectSafe:base64Encode([classId stringValue]) forKey:kClassIdKey];

    // 发送请求
    [NetWorkTask postRequestAndUploadData:kRequestDistributeClassDynamic
                              forParamDic:parameters
                             searchResult:[BusinessSearchNetResult alloc]
                              andDelegate:self
                             forImageInfo:_upImagesArray
                                  forInfo:kRequestDistributeClassDynamic];
}

#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [_settingButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [_settingButton setEnabled:YES];
    
    [self stopLoadingAnimation];
    
    if (searchResult != nil)
    {
        BusinessSearchNetResult *parentRelateInfoResult = (BusinessSearchNetResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                // 刷新页面
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发布成功，返回首页" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = eDistributeSuccessAlertTag;
                
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
            if ([parentRelateInfoResult.msg isKindOfClass:[NSString class]] && [parentRelateInfoResult.msg isStringSafe])
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:parentRelateInfoResult.msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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

- (void)getSearchNetBackWithFailure:(id)customInfo
{
    [_settingButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [_settingButton setEnabled:YES];
    
    [self stopLoadingAnimation];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //隐藏键盘
    [_distributeTextView resignFirstResponder];
}

// 取消输入
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    [_distributeTextView resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == eDistributeSuccessAlertTag)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    _distributeString = text;
    
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    //删除退格按钮
    if (text.length == 0) {
        return YES;
    }
    
    return [textView shouldChangeInRange:range withString:text andLength:kMaxContentLength];
}

@end
