//
//  JoinBBSVC.m
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "JoinBBSVC.h"
#import "BBSNewsDetailResult.h"
#import "BBSSelectInfo.h"

#import "UIButton+WebCache.h"
#import "SDPhotoBrowser.h"
#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

typedef NS_ENUM(NSInteger, ControllTag)
{
    eTitleLabelTag = 100,
    eSubsTitleLabelTag,
    eNewsDateLabelTag,
    
    // 点评
    eCellCommentButtonTag,
    eCellCommentClickButtonTag,
    
    eContentLabelTag,
    eSubmitButtonTag,
    eSubmitSuccessTag,
    
    // 累加tag
    eImageViewTag = 500,
    
    eBackGroundViewTag = 1000,
    eSelectButtonTag = 1500,
    eCommentContentTag = 2000,
};


@interface JoinBBSVC ()<UITableViewDataSource, UITableViewDelegate, NetworkPtc, MWPhotoBrowserDelegate, SDPhotoGroupDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) BBSNewsDetailResult *newsResult;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation JoinBBSVC

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
    
    [self setupRootViewSubs:self.view];
}

#pragma mark - 网络请求

// 请求新闻详情
- (void)getNewsRequest
{
    [self loadingAnimation];
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    
    // 取userId
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    
    // 参数
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode([_newsId stringValue]) forKey:@"newsId"];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestNewsDetail
                 forParamDic:parameters
                searchResult:[[BBSNewsDetailResult alloc] init]
                 andDelegate:self forInfo:kRequestNewsDetail isMockData:kIsMock_RequestNewsDetail];
}

#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    
    if ([customInfo isEqualToString:kRequestNewsDetail])
    {
        [self getSearchNetBackOfNewsDetail:searchResult forInfo:customInfo];
    }
    else if ([customInfo isEqualToString:kRequestSubmitParticipation])
    {
        [self getSearchNetBackOfSubmitParticipation:searchResult forInfo:customInfo];
    }
}

- (void)getSearchNetBackOfSubmitParticipation:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        BusinessSearchNetResult *parentRelateInfoResult = (BusinessSearchNetResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提交成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
               
                alertView.tag = eSubmitSuccessTag;
                [alertView show];
                
            }
            // 失败
            else
            {
                NSString *errorMsg = @"提交失败";
                
                if ([parentRelateInfoResult.businessMsg isKindOfClass:[NSString class]] && [parentRelateInfoResult.businessMsg isStringSafe])
                {
                    errorMsg = parentRelateInfoResult.businessMsg;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                
                [alertView show];
            }
        }
        else
        {
            NSString *errorMsg = @"提交失败";
            
            if ([parentRelateInfoResult.msg isKindOfClass:[NSString class]] && [parentRelateInfoResult.msg isStringSafe])
            {
                errorMsg = parentRelateInfoResult.msg;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alertView show];

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
        BBSNewsDetailResult *parentRelateInfoResult = (BBSNewsDetailResult *)searchResult;
        
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
                NSString *errorMsg = @"请求失败";
                
                if ([parentRelateInfoResult.businessMsg isKindOfClass:[NSString class]] && [parentRelateInfoResult.businessMsg isStringSafe])
                {
                    errorMsg = parentRelateInfoResult.businessMsg;
                }
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                
                [alertView show];
            }
        }
        else
        {
            NSString *errorMsg = @"请求失败";
            
            if ([parentRelateInfoResult.msg isKindOfClass:[NSString class]] && [parentRelateInfoResult.msg isStringSafe])
            {
                errorMsg = parentRelateInfoResult.msg;
            }
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
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
    [_tableView reloadData];
}
- (void)doSubmitAction
{
    // 已选
    NSMutableString *hasSelected = [[NSMutableString alloc] init];
    
    for (BBSSelectInfo *info in _newsResult.selections) {
        if ([info.isSelected boolValue])
        {
            if (![hasSelected isStringSafe])
            {
                [hasSelected appendString:[info.selectionId stringValue]];
            }
            else
            {
                [hasSelected appendString:[NSString stringWithFormat:@",%@", [info.selectionId stringValue]]];
            }
        }
    }
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode([_newsId stringValue]) forKey:@"newsId"];
    [parameters setObjectSafe:base64Encode(hasSelected) forKey:@"selectionIds"];


    // 发送请求
    [NetWorkTask postRequest:kRequestSubmitParticipation
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestSubmitParticipation];
    
//    [NetWorkTask postRequestWithArray:kRequestSubmitParticipation forParamDic:parameters searchResult:[[BusinessSearchNetResult alloc] init] andDelegate:self forArray:hasSelectedArray forInfo:kRequestSubmitParticipation];
}
- (void)doSelect:(CustomButton *)button
{
    BBSSelectInfo *info = button.customInfo;
    
    if ([info.isSelected boolValue])
    {
        info.isSelected = [NSNumber numberWithBool:NO];
        [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
    }
    else
    {
        info.isSelected = [NSNumber numberWithBool:YES];
        [button setImage:[UIImage imageNamed:@"protocolSelect"] forState:UIControlStateNormal];
        
    }
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
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [viewParent addSubview:tableView];
    
    _tableView = tableView;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    if (section == 0)
    {
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
    }
    else if (section == 1)
    {
        // =======================================================================
        // 评论cell
        // =======================================================================
        if (row == 0)
        {
            CGSize contentViewSize = CGSizeMake(tableView.width, 0);
            [self setupViewSubsComentCell:nil inSize:&contentViewSize];
            
            return contentViewSize.height;
        }
    }
    
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.1;
    }
    
    return 10;
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else if (section == 1)
    {
        return 1;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0)
    {
        NSInteger curRow = 0;

        if (curRow == row)
        {
            NSString *reuseIdentifier = @"JoinBBSVCTitleID";
            
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
            NSString *reuseIdentifier = @"JoinBBSVCContentID";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.contentView setBackgroundColor:kWhiteColor];
            }
            
            CGSize contentViewSize = CGSizeMake(tableView.width, 0);
            [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
            
            [self setupViewSubsContentCell:cell.contentView inSize:&contentViewSize];
            
            return cell;
        }
        curRow++;
    }
    
    if (section == 1)
    {
        if (row == 0)
        {
            NSString *reuseIdentifier = @"JoinBBSVCComentID";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.contentView setBackgroundColor:kWhiteColor];
            }
            
            CGSize contentViewSize = CGSizeMake(tableView.width, 0);
            [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
            
            [self setupViewSubsComentCell:cell.contentView inSize:&contentViewSize];
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - cell布局
- (void)setupViewSubsTitleCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 11;
    NSInteger spaceXStart = 10;
    
    UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eTitleLabelTag];
    titleLabel.text = @"";
    
    // =======================================================================
    // title
    // =======================================================================
    
    if ([_newsResult.subject isStringSafe])
    {
        // 计算尺寸
        CGSize titleSize = [_newsResult.subject sizeWithFontCompatible:kMiddleTitleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

        if (viewParent)
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
            titleLabel.text = _newsResult.subject;
            
            titleLabel.frame = CGRectMake(spaceXStart, spaceYStart, titleSize.width, titleSize.height);
        }
        
        // 调整Y
        spaceYStart += titleSize.height;
    }
    
    // 调整Y
    spaceYStart += 13;
    
    // =======================================================================
    // 调整父尺寸
    // =======================================================================
    viewSize->height = spaceYStart;
    
}

// 内容
- (void)setupViewSubsContentCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    // =======================================================================
    // 将各控件数据置空
    // =======================================================================
    UILabel *contentLabel = (UILabel *)[viewParent viewWithTag:eContentLabelTag];
    contentLabel.text = @"";
    
    UILabel *newsDateLabel = (UILabel *)[viewParent viewWithTag:eNewsDateLabelTag];
    newsDateLabel.text = @"";
    
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 10;
    NSInteger spaceXEnd = viewSize->width;
    
    // =======================================================================
    // 内容
    // =======================================================================
    if ([_newsResult.content isStringSafe])
    {
        UILabel *newsContentLabel = (UILabel *)[viewParent viewWithTag:eContentLabelTag];
        if (newsContentLabel == nil)
        {
            newsContentLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:_newsResult.content andColor:kTextColor withTag:eContentLabelTag];
            newsContentLabel.backgroundColor = kWhiteColor;
            newsContentLabel.numberOfLines = 0;
            newsContentLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:newsContentLabel];
        }
        newsContentLabel.text = _newsResult.content;
        
        CGSize newsContentSize = [_newsResult.content sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

        newsContentLabel.frame = CGRectMake(spaceXStart, spaceYStart, viewSize->width-spaceXStart*2, newsContentSize.height);
        
        // 调整Y
        spaceYStart += newsContentSize.height;
    }
    
    // 调整Y
    spaceYStart += 10;
    
    // =======================================================================
    // 图片
    // =======================================================================

    if (_newsResult.imageUrls && _newsResult.imageUrls.count > 0)
    {
        for (int i = 0; i < _newsResult.imageUrls.count; i++)
        {
            NSMutableArray *orginUrls = [[NSMutableArray alloc] init];
            [orginUrls addObject:LoadImageUrl(_newsResult.imageUrls[i])];
            
            NSMutableArray *thumbUrl = [[NSMutableArray alloc] init];
            [thumbUrl addObject:LoadImageUrl(_newsResult.imageUrls[i])];
            
            // =======================================================================
            // 图片
            // =======================================================================
            UIView *imageView = (UIView *)[viewParent viewWithTag:eImageViewTag+i];
            
            if (imageView == nil)
            {
                imageView = [[UIView alloc] initWithFrame:CGRectZero];
                imageView.tag = eImageViewTag+i;
                [viewParent addSubview:imageView];
            }
            
            imageView.frame = CGRectMake(spaceXStart, spaceYStart, viewSize->width-spaceXStart*2, 200);
            
            // 子视图
            [self setupImageViewSubs:imageView inSize:imageView.size orginUrls:(NSMutableArray *)orginUrls thumbUrls:(NSMutableArray *)thumbUrl];
            
            // 调整Y
            spaceYStart += imageView.height;
            spaceYStart += 10;
            
        }
    }
    // 调整Y
    spaceYStart += 10;
    
    // =======================================================================
    // 日期
    // =======================================================================
    if ([_newsResult.createDate isStringSafe])
    {
        // 计算尺寸
        CGSize newsDateSize = [_newsResult.createDate sizeWithFontCompatible:kSmallFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

        if (viewParent)
        {
            UILabel *newsDateLabel = (UILabel *)[viewParent viewWithTag:eNewsDateLabelTag];
            if (newsDateLabel == nil)
            {
                newsDateLabel = [[UILabel alloc] initWithFont:kSmallFont andText:_newsResult.createDate andColor:kTextColor];
                newsDateLabel.tag = eNewsDateLabelTag;
                newsDateLabel.backgroundColor = kWhiteColor;
                
                [viewParent addSubview:newsDateLabel];
            }
            newsDateLabel.text = _newsResult.createDate;
            
            newsDateLabel.frame = CGRectMake(10, spaceYStart, newsDateSize.width, newsDateSize.height);
        }
    }
    
    // =======================================================================
    // 点评
    // =======================================================================
    
    NSString *commentCount = [NSString stringWithFormat:@"%ld", (long)[_newsResult.participationCount integerValue]];
    
    CGSize commentSize = [commentCount sizeWithFontCompatible:kSmallFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
    
    // 点评数
    if (_newsResult.participationCount != nil)
    {
        if (viewParent)
        {
            CustomButton *moreButton = (CustomButton *)[viewParent viewWithTag:eCellCommentButtonTag];
            if (moreButton == nil)
            {
                moreButton = [CustomButton buttonWithType:UIButtonTypeCustom];
                moreButton.tag = eCellCommentButtonTag;
                [moreButton setTitle:@"" forState:UIControlStateNormal];
                [moreButton setTitleColor:kTextColor forState:UIControlStateNormal];
                [moreButton.titleLabel setFont:kSmallFont];
                [viewParent addSubview:moreButton];
            }
            [moreButton setTitle:commentCount forState:UIControlStateNormal];
            moreButton.frame = CGRectMake(spaceXEnd-5-commentSize.width, spaceYStart, commentSize.width, commentSize.height);
            

        }
        
        spaceXEnd -= 5;
        spaceXEnd -= commentSize.width;
    }
    
    // icon
    CustomButton *commentButton = (CustomButton *)[viewParent viewWithTag:eCellCommentClickButtonTag];
    if (commentButton == nil)
    {
        commentButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        commentButton.tag = eCellCommentClickButtonTag;
        //        [commentButton addTarget:self action:@selector(goCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        [commentButton setImage:[UIImage imageNamed:@"JointPeopleCount"] forState:UIControlStateNormal];
        
        [viewParent addSubview:commentButton];
    }
    commentButton.frame = CGRectMake(spaceXEnd-32, spaceYStart, 28, 18);
    
    // 调整Y
    spaceYStart += commentSize.height;
    spaceYStart += 12;
    
    viewSize->height = spaceYStart;
    
}

// 评论
- (void)setupViewSubsComentCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    // 数据
    NSMutableArray *selections = _newsResult.selections;
    
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 10;
    
    // =======================================================================
    // 评论内容
    // =======================================================================

    if (selections && selections.count > 0)
    {
        // 调整Y
        spaceYStart += 26;
        
        int index = 0;
        
        for (BBSSelectInfo *selectInfo in selections)
        {
            // =======================================================================
            // 选择框
            // =======================================================================
          
            // image背景
            UIView *backGroundView = (UIView *)[viewParent viewWithTag:eBackGroundViewTag+index];
            if (backGroundView == nil)
            {
                backGroundView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, 18, 18)];
                backGroundView.backgroundColor = [UIColor whiteColor];
                backGroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                backGroundView.layer.borderWidth = 0.5;
                backGroundView.tag = eBackGroundViewTag+index;
                
                [viewParent addSubview:backGroundView];
            }
            
            
            CustomButton *selectButton = (CustomButton *)[backGroundView viewWithTag:eSelectButtonTag+index];
            if (selectButton == nil)
            {
                selectButton = [[CustomButton alloc] init];
                selectButton.backgroundColor = [UIColor whiteColor];
                [selectButton addTarget:self action:@selector(doSelect:) forControlEvents:UIControlEventTouchUpInside];
                selectButton.tag = eSelectButtonTag+index;
                
                [backGroundView addSubview:selectButton];
            }
            
            selectButton.frame = CGRectMake((backGroundView.width-14)/2, (backGroundView.height-12)/2, 14, 12);
            selectButton.customInfo = selectInfo;
            
            
            // 是否选中
            if ([selectInfo.isSelected boolValue])
            {
                [selectButton setImage:[UIImage imageNamed:@"protocolSelect"] forState:UIControlStateNormal];
            }
            else
            {
                [selectButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            }
            
            spaceXStart += backGroundView.width;
            spaceXStart += 38;
            // =======================================================================
            // 评论内容
            // =======================================================================
            UILabel *label = (UILabel *)[viewParent viewWithTag:eCommentContentTag+index];
            if (label == nil)
            {
                label = [[UILabel alloc] initWithFont:kSmallTitleFont andText:selectInfo.selection andColor:[UIColor colorWithHex:0x777777 alpha:1.0] withTag:111];
                label.textAlignment = NSTextAlignmentLeft;
                label.tag = eCommentContentTag+index;
                
                [viewParent addSubview:label];

            }
            
            label.frame = CGRectMake(spaceXStart, spaceYStart, viewParent.width-spaceXStart, 18);
            
            // 调整坐标
            spaceYStart += 16;
            spaceYStart += 22;
            spaceXStart = 10;
            
            index++;
        }
        
        // 调整Y
        spaceYStart += 40;
        
        // =======================================================================
        // 提交
        // =======================================================================
        UIButton *submitButton = (UIButton *)[viewParent viewWithTag:eSubmitButtonTag];
        if (submitButton == nil)
        {
            submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [submitButton addTarget:self action:@selector(doSubmitAction) forControlEvents:UIControlEventTouchUpInside ];
            submitButton.titleLabel.font=kSmallTitleFont;
            submitButton.tintColor = [UIColor whiteColor];
            submitButton.backgroundColor = kBackgroundGreenColor;
            submitButton.layer.cornerRadius = 20;
            submitButton.tag = eSubmitButtonTag;
            
            [viewParent addSubview:submitButton];
        }
        submitButton.frame = CGRectMake(spaceXStart, spaceYStart, viewSize->width - spaceXStart*2, 40) ;
        
        if ([_newsResult.isParticipation boolValue])
        {
            submitButton.enabled = NO;
            [submitButton setTitle:@"您已提交过" forState:UIControlStateNormal];
            submitButton.backgroundColor = [UIColor lightGrayColor];
            
        }
        else
        {
            submitButton.enabled = YES;
            [submitButton setTitle:@"提交" forState:UIControlStateNormal];
            submitButton.backgroundColor = kBackgroundGreenColor;
            
        }
        
        // 调整Y
        spaceYStart += submitButton.height;
        spaceYStart += 40;
    }
    
    viewSize->height = spaceYStart;
}

// 图片视图
- (void)setupImageViewSubs:(UIView *)viewParent inSize:(CGSize)viewSize orginUrls:(NSMutableArray *)orginUrls thumbUrls:(NSMutableArray *)thumbUrls
{
    SDPhotoGroup *photoGroup = [[SDPhotoGroup alloc] init];
    photoGroup.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    photoGroup.fromType = 1;
    photoGroup.delegate = self;
    
    NSMutableArray *temp = [NSMutableArray array];
    [thumbUrls enumerateObjectsUsingBlock:^(NSString *src, NSUInteger idx, BOOL *stop) {
        SDPhotoItem *item = [[SDPhotoItem alloc] init];
        item.thumbnail_pic = src;
        [temp addObject:item];
    }];
    
    photoGroup.photoItemArray = [temp copy];
    // 原图
    photoGroup.originUrlsArray = orginUrls;
    
    [viewParent addSubview:photoGroup];
    
}

#pragma mark - SDPhotoGroupDelegate
- (void)imageButtonClickReturn:(CustomButton *)imageButton
{
    NSArray *originUrls = imageButton.customInfo;
    NSInteger selectIndex = imageButton.tag;
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < originUrls.count; i++)
    {
        [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:originUrls[i]]]];
        
    }
    _photos = photos;
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = YES;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = YES;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:selectIndex];
    
    [self.navigationController pushViewController:browser animated:YES];
    
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == eSubmitSuccessTag)
    {
        // 刷新页面
        [self getNewsRequest];
    }
}
@end
