//
//  ClassDynamicVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/10.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "ClassDynamicListVC.h"
#import "TopTabView.h"

#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"

#import "CampusDynamicDetailVC.h"
#import "NewsListResult.h"
#import "NewsListInfo.h"
#import "NewsListImagesInfo.h"
#import "ImageInfo.h"
#import "CommentInfo.h"

#import "CustomKeyBoardView.h"

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

typedef NS_ENUM(NSInteger, ControlTag) {
    eCellTitleLabelTag = 11,
    eCellBriefLabelTag,
    eCellImageViewsTag,
    eCellTimeLabelTag,
    eCellMoreButtonTag,
    eCellCommentButtonTag,           // 点评
    eCellCommentClickButtonTag,      // 点评
    eCellDeleteButtonTag,            // 删除
    eDeleteAlertTag,             // 删除alert

    eCellCommentSuccessTag,          // 评论成功
    
    eCellLineViewTag,
    
    eCellCommentViewTag,      // 点评内容
    eCellCommentUserNameTag = 500,      // 点评人
    eCellCommentContentTag = 1000,      // 点评内容
    
};

// 业务类型
typedef NS_ENUM(NSInteger, BusinessType) {
    eBusinessActivityType,
    eNotificationType,
    eNewsType,
};

@interface ClassDynamicListVC ()<TopTabViewDelegate, UITableViewDataSource, UITableViewDelegate, NetworkPtc, CustomKeyBoardViewDelegate, UIAlertViewDelegate, SDPhotoGroupDelegate,MWPhotoBrowserDelegate>

@property (nonatomic, assign) BusinessType businesType;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *srcStringArray;
@property (nonatomic, strong) NewsListResult *newsListResult;

@property (nonatomic, strong) NSMutableDictionary *isExpandDictionary;

@property (nonatomic, strong) CustomKeyBoardView *keyBoard;
@property (nonatomic, assign) CGFloat keyBoardHeight;

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) NSIndexPath *curIndexPath;
@property (nonatomic, assign) CGPoint contentoffset;

@property (nonatomic, strong) NSNumber *deleteNewsId;

@end

@implementation ClassDynamicListVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _photos = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 默认业务类型
    _businesType = eBusinessActivityType;
    _isExpandDictionary = [[NSMutableDictionary alloc] init];
    
    [self setupRootViewSubs:self.view];
    
    [self getNewsRequest];
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    // =======================================================================
    // 列表
    // =======================================================================
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, kScreenWidth, kScreenHeight-spaceYStart-2) style:UITableViewStylePlain];
    tableView.backgroundColor = kWhiteColor;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [viewParent addSubview:tableView];
    
    _tableView = tableView;
    
}

#pragma mark - 事件处理
- (void)goDeleteAction:(CustomButton *)button
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否删除此条班级动态" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = eDeleteAlertTag;
    [alertView show];
    
    _deleteNewsId = button.customInfo;
}
- (void)goDetailAction:(CustomButton *)button
{
    NSIndexPath *indexPath = button.customInfo;
    
    NSNumber *isClick = [_isExpandDictionary objectForKey:indexPath];
    // 选中
    if ([isClick boolValue]) {
        [_isExpandDictionary setObject:[NSNumber numberWithBool:NO] forKey:indexPath];
    }
    else {
        [_isExpandDictionary setObject:[NSNumber numberWithBool:YES] forKey:indexPath];
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

// 点评
-(void)goCommentAction:(CustomButton *)sender
{
    // 行号
    _curIndexPath = sender.customInfo[0];
    
    // =======================================================================
    // 弹出评论视图
    // =======================================================================
    if(_keyBoard == nil)
    {
        _keyBoard = [[CustomKeyBoardView alloc]initWithFrame:CGRectMake(0, self.view.height-44, self.view.width, 44)];
       
    }
    _keyBoard.delegate=self;
    
    // 新闻id
    _keyBoard.newsId = sender.customInfo[1];
    
    [_keyBoard.textView becomeFirstResponder];
    _keyBoard.textView.returnKeyType = UIReturnKeySend;
    
    [self.view addSubview:_keyBoard];
    
}
-(void)keyboardShow:(NSNotification *)note
{
    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY = keyBoardRect.size.height;
    _keyBoardHeight = deltaY;
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        _keyBoard.transform=CGAffineTransformMakeTranslation(0, -deltaY);
    }];
    
    
//    _tableView setContentOffset:CGPointMake(0, <#CGFloat y#>)
    [_tableView scrollToRowAtIndexPath:_curIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}
-(void)keyboardHide:(NSNotification *)note
{
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        _keyBoard.transform=CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
        _keyBoard.textView.text=@"";
        [_keyBoard removeFromSuperview];
    }];
    
}
-(void)keyBoardViewHide:(UITextView *)keyBoardView content:(NSString *)content newsId:(NSNumber *)newsId
{
    [self loadingAnimation];
    
    [keyBoardView resignFirstResponder];
    
    // 发表评论
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode([newsId stringValue]) forKey:@"newsId"];
    [parameters setObjectSafe:base64Encode(content) forKey:@"content"];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestPostComment
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestPostComment];
    
}

- (void)publishComment:(UITextView *)keyBoardView newsId:(NSNumber *)newsId content:(NSString *)content
{
    [self loadingAnimation];
    
    [keyBoardView resignFirstResponder];
    
    // 发表评论
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode([newsId stringValue]) forKey:@"newsId"];
    [parameters setObjectSafe:base64Encode(content) forKey:@"content"];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestPostComment
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestPostComment];
}


-(void)topTabSelect:(TopBarButton * )btn tabView:(TopTabView*) tabView;
{
    NSInteger businessType = btn.type;
    
    _businesType = businessType;
    
    [_tableView reloadData];
    
}

#pragma mark - 网络请求

// 删除班级动态
- (void)getDeleteDynamicRequest:(NSNumber *)newsId
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode([newsId stringValue]) forKey:@"newsId"];

    // 发送请求
    [NetWorkTask postRequest:kRequestDeleteClassDynamic
                 forParamDic:parameters
                searchResult:[[BusinessSearchNetResult alloc] init]
                 andDelegate:self forInfo:kRequestDeleteClassDynamic];
}

// 新闻列表
- (void)getNewsRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    
    // type  (1:育儿学堂, 2: 校园动态--活动，3:校园动态--通知, 4:校园动态--新闻, 5: 班级动态)
    
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"pageIndex"];
    [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"pageSize"];
    [parameters setObjectSafe:base64Encode(@"5") forKey:@"type"];
   
    NSNumber *classId = [kSaveData objectForKey:kClassIdKey];
    [parameters setObjectSafe:base64Encode([classId stringValue]) forKey:kClassIdKey];
    
    // 发送请求
    [NetWorkTask postRequest:kRequestNewsList
                 forParamDic:parameters
                searchResult:[[NewsListResult alloc] init]
                 andDelegate:self forInfo:kRequestNewsList];
}

- (void)getSearchNetBack:(NewsListResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];

    if ([customInfo isEqualToString:kRequestPostComment])
    {
        [self getSearchNetBackOfPublishComment:(BusinessSearchNetResult *)searchResult forInfo:customInfo];
    }
    // 新闻列表
    else if ([customInfo isEqualToString:kRequestNewsList])
    {
        [self getSearchNetBackOfNewsList:searchResult forInfo:customInfo];
    }
    // 删除班级动态
    else if ([customInfo isEqualToString:kRequestDeleteClassDynamic])
    {
        [self getSearchNetBackOfDeleteClassDynamic:searchResult forInfo:customInfo];
    }
    
}

// 删除班级动态
- (void)getSearchNetBackOfDeleteClassDynamic:(NewsListResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];

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
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除动态失败，稍后再试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }
        }
        else
        {
            NSString *errorMsg = @"网络异常，稍后再试！";
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
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

// 新闻列表回调
- (void)getSearchNetBackOfNewsList:(NewsListResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];

    if (searchResult != nil)
    {
        
        if ([searchResult.status integerValue] == 0)
        {
            // 获取成功
            if ([searchResult.isSuccess integerValue] == 0)
            {
                _newsListResult = searchResult;
                
                // 刷新页面
                [_tableView reloadData];
            }
            // 失败
            else
            {
                if ([searchResult.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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

// 发表评论回调
- (void)getSearchNetBackOfPublishComment:(BusinessSearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    
    if (searchResult != nil)
    {
        
        if ([searchResult.status integerValue] == 0)
        {
            // 获取成功
            if ([searchResult.isSuccess integerValue] == 0)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"评论成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = eCellCommentSuccessTag;
                
                [alertView show];
                
            }
            // 失败
            else
            {
                if ([searchResult.businessMsg isStringSafe])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:searchResult.businessMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _newsListResult.newsList.count;
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 初始化展开状态，默认no
    NSNumber *isExpand = [_isExpandDictionary objectForKey:indexPath];
    if (isExpand == nil)
    {
        [_isExpandDictionary setObject:[NSNumber numberWithBool:NO] forKey:indexPath];
    }
    
    NSString *reuseIdentifier = @"campusDynamicActivityCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CGSize contentViewSize = CGSizeMake(tableView.width, 0);
    [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    
    [self setupViewSubsCellActivity:cell.contentView inSize:&contentViewSize indexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize contentViewSize = CGSizeMake(tableView.width, 0);
    
    [self setupViewSubsCellActivity:nil inSize:&contentViewSize indexPath:indexPath];
    
    return contentViewSize.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 活动cell布局

- (void)setupViewSubsCellActivity:(UIView *)viewParent inSize:(CGSize *)viewSize indexPath:(NSIndexPath *)indexPath
{
    // =======================================================================
    // 将各控件数据置空
    // =======================================================================
    UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eCellTitleLabelTag];
    titleLabel.text = @"";
    
    UILabel *briefLabel = (UILabel *)[viewParent viewWithTag:eCellBriefLabelTag];
    briefLabel.text = @"";
    
    UIView *imageSuperView1 = (UIView *)[viewParent viewWithTag:eCellImageViewsTag];
    [imageSuperView1 removeAllSubviews];
    
    UIView *commentView = (UIView *)[viewParent viewWithTag:eCellCommentViewTag];
    [commentView removeAllSubviews];
    
    UILabel *timeLabel1 = (UILabel *)[viewParent viewWithTag:eCellTimeLabelTag];
    timeLabel1.text = @"";
    
    
    // =======================================================================
    // 布局
    // =======================================================================
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
    NSInteger spaceXEnd = viewSize->width;
    
    // 数据
    NewsListInfo *newsInfo;
    
    NSMutableArray *originUrls = [[NSMutableArray alloc] init];
    NSMutableArray *thumbUrl = [[NSMutableArray alloc] init];
    
    if (_newsListResult && _newsListResult.newsList.count > indexPath.row)
    {
        newsInfo = _newsListResult.newsList[indexPath.row];
        
        for (int i = 0; i < newsInfo.imageUrls.count; i++)
        {
            
            NewsListImagesInfo *imagesList = newsInfo.imageUrls[i];
            [originUrls addObject:LoadImageUrl(imagesList.origUrl)];
            [thumbUrl addObject:LoadImageUrl(imagesList.thumbUrl)];
            
        }
    }
    
    // 计算行高
    CGFloat rowHeight = [@"泉" sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail].height;

    NSInteger maxRowCount = 5;
    
    // =======================================================================
    // title
    // =======================================================================
    if ([newsInfo.subject isStringSafe])
    {
        CGSize titleSize = [newsInfo.subject sizeWithFontCompatible:kSmallTitleFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
        
        UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eCellTitleLabelTag];
        
        if (titleLabel == nil)
        {
            titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:newsInfo.subject andColor:[UIColor blackColor] withTag:eCellTitleLabelTag];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:titleLabel];
        }
        titleLabel.frame = CGRectMake(spaceXStart, spaceYStart, titleSize.width, titleSize.height);
        titleLabel.text = newsInfo.subject;
        
        // 调整Y
        spaceYStart += titleSize.height;
        spaceYStart += 10;
        
    }
    
    // =======================================================================
    // content
    // =======================================================================
    if ([newsInfo.content isStringSafe])
    {
        CGSize realContentSize = [newsInfo.content sizeWithFont:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX)];
        
        CGFloat contentHeight;
        NSNumber *isExpand = [_isExpandDictionary objectForKey:indexPath];
        
        UILabel *briefLabel = (UILabel *)[viewParent viewWithTag:eCellBriefLabelTag];
        
        if (briefLabel == nil)
        {
            briefLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:newsInfo.content andColor:kTextColor withTag:eCellBriefLabelTag];
            briefLabel.textAlignment = NSTextAlignmentLeft;
            briefLabel.numberOfLines = 0;
            briefLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
            [viewParent addSubview:briefLabel];
        }
        
        // 判断高度是否超过5行
        if (realContentSize.height > maxRowCount*rowHeight)
        {
            // 展开
            if (isExpand.boolValue)
            {
                contentHeight = realContentSize.height;
                briefLabel.numberOfLines = 0;
            }
            // 折叠
            else
            {
                contentHeight = rowHeight*maxRowCount;
                briefLabel.numberOfLines = maxRowCount;
            }
        }
        else
        {
            contentHeight = realContentSize.height;
            briefLabel.numberOfLines = 0;
        }
        
        
        briefLabel.frame = CGRectMake(spaceXStart, spaceYStart, realContentSize.width, contentHeight);
        briefLabel.text = newsInfo.content;
        
        // 调整Y
        spaceYStart += contentHeight;
        spaceYStart += 10;
        
    }
    
    // =======================================================================
    // 图片
    // =======================================================================
    if (originUrls && originUrls.count > 0)
    {
        UIView *imageSuperView = (UIView *)[viewParent viewWithTag:eCellImageViewsTag];
        
        if (imageSuperView == nil)
        {
            imageSuperView = [[UIView alloc] initWithFrame:CGRectZero];
            imageSuperView.tag = eCellImageViewsTag;
            [viewParent addSubview:imageSuperView];
        }
        NSInteger imageSize = (viewSize->width-50)/4;
        CGSize imageViewSize = CGSizeMake(viewSize->width, imageSize+20);
        
        imageSuperView.frame = CGRectMake(0, spaceYStart, imageViewSize.width, imageViewSize.height);
        
        // 子视图
        [self setupImageViewSubs:imageSuperView inSize:&imageViewSize orginUrls:(NSMutableArray *)originUrls thumbUrls:thumbUrl];
        
        
        // 调整Y
        spaceYStart += imageViewSize.height;
        spaceYStart += 10;
    }
    
    // =======================================================================
    // 时间
    // =======================================================================
    
    if ([newsInfo.createDate isStringSafe])
    {
        NSString *time = newsInfo.createDate;
        
        CGSize timeSize = [time sizeWithFontCompatible:kMiddleFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
        
        UILabel *timeLabel = (UILabel *)[viewParent viewWithTag:eCellTimeLabelTag];
        
        if (timeLabel == nil)
        {
            timeLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:time andColor:kTextColor withTag:eCellTimeLabelTag];
            timeLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:timeLabel];
        }
        timeLabel.frame = CGRectMake(spaceXStart, spaceYStart, viewSize->width-20, timeSize.height);
        timeLabel.text = time;
    }
    
    // =======================================================================
    // 更多
    // =======================================================================
    
    CGSize realContentSize = [newsInfo.content sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

    
    // 内容超过5行，显示查看更多
    if (realContentSize.height > maxRowCount*rowHeight)
    {
        NSString *moreString = @"查看全文>>";
        CGSize moreSize = [moreString sizeWithFontCompatible:kSmallFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
        
        CustomButton *moreButton = (CustomButton *)[viewParent viewWithTag:eCellMoreButtonTag];
        if (moreButton == nil)
        {
            moreButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            moreButton.tag = eCellMoreButtonTag;
            [moreButton setTitle:moreString forState:UIControlStateNormal];
            [moreButton setTitleColor:kTextColor forState:UIControlStateNormal];
            [moreButton.titleLabel setFont:kSmallFont];
            [moreButton addTarget:self action:@selector(goDetailAction:) forControlEvents:UIControlEventTouchUpInside];
            [viewParent addSubview:moreButton];
        }
        moreButton.customInfo = indexPath;
        moreButton.frame = CGRectMake(kScreenWidth-10-moreSize.width, spaceYStart, moreSize.width, moreSize.height);
        moreButton.hidden = NO;
        
        spaceXEnd -= 10;
        spaceXEnd -= moreSize.width;
    }
    else
    {
        CustomButton *moreButton = (CustomButton *)[viewParent viewWithTag:eCellMoreButtonTag];
        if (moreButton != nil)
        {
            moreButton.hidden = YES;
        }
    }
   
    
    // =======================================================================
    // 点评
    // =======================================================================
    
    // 点评数
    if (newsInfo.commentCount != nil)
    {
        NSString *commentCount = [NSString stringWithFormat:@"%ld", (long)[newsInfo.commentCount integerValue]];
        
        CGSize commentSize = [commentCount sizeWithFontCompatible:kSmallFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
        
        CustomButton *moreButton = (CustomButton *)[viewParent viewWithTag:eCellCommentButtonTag];
        if (moreButton == nil)
        {
            moreButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            moreButton.tag = eCellCommentButtonTag;
            [moreButton setTitleColor:kTextColor forState:UIControlStateNormal];
            [moreButton.titleLabel setFont:kSmallFont];
            [viewParent addSubview:moreButton];
        }
        [moreButton setTitle:commentCount forState:UIControlStateNormal];
        moreButton.frame = CGRectMake(spaceXEnd-10-commentSize.width, spaceYStart, commentSize.width, commentSize.height);

        spaceXEnd -= 10;
        spaceXEnd -= commentSize.width;
    }
    
    // icon
    CustomButton *commentButton = (CustomButton *)[viewParent viewWithTag:eCellCommentClickButtonTag];
    if (commentButton == nil)
    {
        commentButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        commentButton.tag = eCellCommentClickButtonTag;
        [commentButton addTarget:self action:@selector(goCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        [commentButton setImage:[UIImage imageNamed:@"CommentIcon"] forState:UIControlStateNormal];
        
        [viewParent addSubview:commentButton];
    }
    
    // 评论携带信息
    NSMutableArray *commentInfo = [[NSMutableArray alloc] init];
    [commentInfo addObject:indexPath];
    [commentInfo addObject:newsInfo.newsId];
    
    commentButton.customInfo = commentInfo;
    commentButton.frame = CGRectMake(spaceXEnd-32, spaceYStart, 28, 18);
    
    
    // 调整X
    spaceXEnd -= 10;
    spaceXEnd -= 28;
    
    // =======================================================================
    // 删除按钮
    // =======================================================================
    
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    
    if ([newsInfo.author integerValue] == [userId integerValue])
    {
        CustomButton *deleteButton = (CustomButton *)[viewParent viewWithTag:eCellDeleteButtonTag];
        if (deleteButton == nil)
        {
            deleteButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            deleteButton.tag = eCellDeleteButtonTag;
            [deleteButton addTarget:self action:@selector(goDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
            [deleteButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
            
            [viewParent addSubview:deleteButton];
        }
        deleteButton.customInfo = newsInfo.newsId;
        deleteButton.hidden = NO;
        deleteButton.frame = CGRectMake(spaceXEnd-32, spaceYStart, 28, 18);
    }
    else
    {
        CustomButton *deleteButton = (CustomButton *)[viewParent viewWithTag:eCellDeleteButtonTag];
        if (deleteButton)
        {
            deleteButton.hidden = YES;
        }
    }
    
    
    CGSize timeSize = [@"11" sizeWithFontCompatible:kMiddleFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
    // 调整Y
    spaceYStart += timeSize.height;
    spaceYStart += 12;
    
    
    // =======================================================================
    // 评论列表
    // =======================================================================
    if (newsInfo.commentList && newsInfo.commentList.count > 0)
    {
        NSMutableArray *commentList = newsInfo.commentList;
        
        UIView *commentView = (UIView *)[viewParent viewWithTag:eCellCommentViewTag];
        
        if (commentView == nil)
        {
            commentView = [[UIView alloc] initWithFrame:CGRectZero];
            commentView.tag = eCellCommentViewTag;
            
            [viewParent addSubview:commentView];
        }
        CGSize commentViewSize = CGSizeMake(viewSize->width, 0);
        [self setupViewSubsCommentView:commentView inSize:&commentViewSize commentList:commentList];
        
        [commentView setFrame:CGRectMake(0, spaceYStart, commentViewSize.width, commentViewSize.height)];
        
        // 调整Y
        spaceYStart += commentViewSize.height;
    }
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *lineView = (UIView *)[viewParent viewWithTag:eCellLineViewTag];
    if (lineView == nil)
    {
        lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, spaceYStart, viewSize->width, 0.5)];
        lineView.tag = eCellLineViewTag;
        
        [viewParent addSubview:lineView];
    }
    lineView.frame = CGRectMake(0, spaceYStart, viewSize->width, 0.5);
    
    // 调整Y
    spaceYStart += 1;
    
    // =======================================================================
    // 父尺寸设置
    // =======================================================================
    
    viewSize->height = spaceYStart;
    
    if (viewParent)
    {
        [viewParent setViewY:spaceYStart];
    }
}

// 图片视图
- (void)setupImageViewSubs:(UIView *)viewParent inSize:(CGSize *)viewSize orginUrls:(NSMutableArray *)orginUrls thumbUrls:(NSMutableArray *)thumbUrls
{
    NSInteger imageSize = (viewSize->width-50)/4;
    
    SDPhotoGroup *photoGroup = [[SDPhotoGroup alloc] init];
    photoGroup.frame = CGRectMake(10, 10, viewSize->width, viewSize->height);
    photoGroup.imageSize = imageSize;
    photoGroup.fromType = 4;
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
    
    viewSize->height = imageSize+20;
    
    if (orginUrls.count == 0)
    {
        UIImageView *placeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ListErrorImage"]];
        [viewParent addSubview:placeImageView];
    }
    
}

// 评论列表视图
- (void)setupViewSubsCommentView:(UIView *)viewParent inSize:(CGSize *)viewSize commentList:(NSMutableArray *)commentList
{
#warning 临时解决
    [viewParent removeAllSubviews];
    
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 10;
    
    for (int i = 0; i < commentList.count; i++)
    {
        CommentInfo *commentInfo = commentList[i];
        
//        // 清空数据
//        UILabel *nameLabel = (UILabel *)[viewParent viewWithTag:eCellCommentUserNameTag+i];
//        if (nameLabel) {
//            [nameLabel setText:@""];
//        }
//        UILabel *commentLabel = (UILabel *)[viewParent viewWithTag:eCellCommentContentTag+i];
//        if (commentLabel) {
//            [commentLabel setText:@""];
//        }
        
        // 点评高度
        NSInteger commentHeight = 0;
        
        // name
        if ([commentInfo.userName isStringSafe])
        {
            NSString *displayName = [NSString stringWithFormat:@"%@%@", commentInfo.userName, @"："];
            CGSize nameSize = [displayName sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-20, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];

            UILabel *nameLabel = (UILabel *)[viewParent viewWithTag:eCellCommentUserNameTag+i];
            
            if (nameLabel == nil)
            {
                nameLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:commentInfo.userName andColor:[UIColor colorWithHex:0x566c94 alpha:1.0] withTag:eCellCommentUserNameTag+i];
                nameLabel.numberOfLines = 0;
                [viewParent addSubview:nameLabel];
            }
            nameLabel.frame = CGRectMake(spaceXStart, spaceYStart, nameSize.width, nameSize.height);
            nameLabel.text = displayName;
            nameLabel.textAlignment = NSTextAlignmentLeft;

            // 调整X
            spaceXStart += nameSize.width;
            
            commentHeight += nameSize.height;
        }
        
        // comtent
        if ([commentInfo.comment isStringSafe])
        {
            CGSize nameSize = [commentInfo.comment sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-10-spaceXStart, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
            
            UILabel *nameLabel = (UILabel *)[viewParent viewWithTag:eCellCommentContentTag+i];
            
            if (nameLabel == nil)
            {
                nameLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:commentInfo.userName andColor:[UIColor colorWithHex:0x101010 alpha:1.0] withTag:eCellCommentContentTag+i];
                nameLabel.numberOfLines = 0;
                nameLabel.textAlignment = NSTextAlignmentLeft;
                
                [viewParent addSubview:nameLabel];
            }
            nameLabel.frame = CGRectMake(spaceXStart, spaceYStart, nameSize.width, nameSize.height);
            nameLabel.text = commentInfo.comment;
            
            // 调整X
            spaceXStart += nameSize.width;
            
            if (commentHeight < nameSize.height)
            {
                commentHeight = nameSize.height;
            }
        }
        
        // 调整X
        spaceXStart = 10;
        spaceYStart += commentHeight;
        spaceYStart += 5;
    }
    
    viewSize->height = spaceYStart;
}

// 滚动屏幕，隐藏
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_keyBoard.textView)
    {
        [_keyBoard.textView resignFirstResponder];
        [_keyBoard.textView setText:@""];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == eCellCommentSuccessTag)
    {
        // 刷新页面
        [self getNewsRequest];
    }
    else if (alertView.tag == eDeleteAlertTag)
    {
        if (buttonIndex == alertView.cancelButtonIndex)
        {
            
        }
        else
        {
            [self getDeleteDynamicRequest:_deleteNewsId];
        }
    }
    
    if (_keyBoard.textView)
    {
        [_keyBoard.textView resignFirstResponder];
        [_keyBoard.textView setText:@""];
    }
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

- (void)customTextViewDidBeginEditing:(UITextView *)textView
{
    [_tableView scrollToRowAtIndexPath:_curIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    CGRect rectintableview=[_tableView rectForRowAtIndexPath:_curIndexPath];
    
    //获取当前cell在屏幕中的位置
    
//    CGRect rectinsuperview=[_tableView convertRect:rectintableview fromView:[_tableView superview]];
    
    _contentoffset.x=_tableView.contentOffset.x;
    
    _contentoffset.y=_tableView.contentOffset.y;
    
//    if ((rectintableview.origin.y+70-_tableView.contentOffset.y)>200) {
    
//    [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x,(rectintableview.origin.y-30 + rectintableview.size.height)) animated:YES];
//
//    [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x,(rectintableview.origin.y)+rectintableview.size.height) animated:YES];
//    [_tableView scrollToRowAtIndexPath:_curIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    if ((rectintableview.origin.y+50-_tableView.contentOffset.y)>200) {
//
//        [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x,((rectintableview.origin.y-_tableView.contentOffset.y)-rectintableview.size.height)+_tableView.contentOffset.y) animated:YES];
//    if ((rectintableview.origin.y+rectintableview.size.height-_tableView.contentOffset.y)>_tableView.height- 220)
    {
//        [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x,((rectintableview.origin.y-_tableView.contentOffset.y)-rectintableview.size.height+30)+_tableView.contentOffset.y) animated:YES];
//        [_tableView setContentOffset:CGPointMake(0,rectintableview.origin.y + rectintableview.size.height-30+_tableView.contentOffset.y)];
    }
//
//    }
//    }
}

- (BOOL)customTextViewShouldReturn:(UITextView *)textView
{
    [textView resignFirstResponder];
    
    [_tableView setContentOffset:CGPointMake(_contentoffset.x,_contentoffset.y) animated:YES];

    return YES;
}
@end
