//
//  BBSBarVC.m
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "BBSBarVC.h"
#import "JoinBBSVC.h"

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"

#import "BBSNewsListResult.h"
#import "BBSNewsListInfo.h"
#import "NewsListImagesInfo.h"
#import "ImageInfo.h"

typedef NS_ENUM(NSInteger, ControlTag) {
    eCellTitleLabelTag = 11,
    eCellHotIconTag,
    eCellBriefLabelTag,
    eCellImageViewsTag,
    eCellTimeLabelTag,
    eCellMoreButtonTag,
    eCellCommentButtonTag,           // 点评
    eCellCommentClickButtonTag,      // 点评
    eCellLineViewTag,
    
    eCellCommentViewTag,
};

@interface BBSBarVC ()<UITableViewDataSource, UITableViewDelegate, NetworkPtc, UIAlertViewDelegate, SDPhotoGroupDelegate,MWPhotoBrowserDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BBSNewsListResult *newsListResult;
@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation BBSBarVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getNewsListRequest];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupRootViewSubs:self.view];
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
    CGSize contentViewSize = CGSizeMake(tableView.width, 0);
    
    [self setupViewSubsCellActivity:nil inSize:&contentViewSize indexPath:indexPath];
    
    return contentViewSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _newsListResult.newsList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - 网络请求
- (void)getNewsListRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"pageIndex"];
    [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"pageSize"];
    [parameters setObjectSafe:base64Encode(@"7") forKey:@"type"];
    
    NSNumber *classId = [kSaveData objectForKey:kClassIdKey];
    [parameters setObjectSafe:base64Encode([classId stringValue]) forKey:kClassIdKey];

    // 发送请求
    [NetWorkTask postRequest:kRequestNewsList
                 forParamDic:parameters
                searchResult:[[BBSNewsListResult alloc] init]
                 andDelegate:self forInfo:kRequestNewsList];
}

- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    
    if ([customInfo isEqualToString:kRequestNewsList])
    {
        [self getSearchNetBackNewsList:searchResult forInfo:customInfo];
    }
    
}

// 新闻列表请求回调
- (void)getSearchNetBackNewsList:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        BBSNewsListResult *parentRelateInfoResult = (BBSNewsListResult *)searchResult;
        
        if ([parentRelateInfoResult.status integerValue] == 0)
        {
            // 获取成功
            if ([parentRelateInfoResult.isSuccess integerValue] == 0)
            {
                _newsListResult = parentRelateInfoResult;
                
                // 刷新页面
                [_tableView reloadData];
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

#pragma mark - 事件机制
- (void)goJoinBBSAction:(CustomButton *)button
{
    NSArray *newsInfo = button.customInfo;
    
    NSNumber *newsId;
    NSString *newsTitle;
    
    if (newsInfo && newsInfo.count > 1)
    {
        newsId = newsInfo[0];
        newsTitle = newsInfo[1];
    }
    
    // 截断bbsTitle
    if (newsTitle.length > 8)
    {
        newsTitle = [newsTitle substringWithRange:NSMakeRange(0, 8)];
        newsTitle = [NSString stringWithFormat:@"%@...", newsTitle];
    }
    
    JoinBBSVC *joinBBSVC = [[JoinBBSVC alloc] initWithName:newsTitle];
    joinBBSVC.newsId = newsId;
    
    [self.navigationController pushViewController:joinBBSVC animated:YES];
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
    BBSNewsListInfo *newsInfo;
    
    NSMutableArray *originUrls = [[NSMutableArray alloc] init];
    NSMutableArray *thumbUrl = [[NSMutableArray alloc] init];
    
    if (_newsListResult && _newsListResult.newsList.count > indexPath.section)
    {
        newsInfo = _newsListResult.newsList[indexPath.section];
        
        for (int i = 0; i < newsInfo.imageUrls.count; i++)
        {
            
            NewsListImagesInfo *imagesList = newsInfo.imageUrls[i];
            [originUrls addObject:LoadImageUrl(imagesList.origUrl)];
            [thumbUrl addObject:LoadImageUrl(imagesList.thumbUrl)];
            
        }
    }
    
    // =======================================================================
    // 热门标签
    // =======================================================================
    if ([newsInfo.popular boolValue])
    {
        UIButton *hotIconButton = (UIButton *)[viewParent viewWithTag:eCellHotIconTag];
        if (hotIconButton == nil)
        {
            hotIconButton = [[UIButton alloc] initWithFont:[UIFont systemFontOfSize:9] andTitle:@"热门" andTtitleColor:kWhiteColor];
            hotIconButton.tag = eCellHotIconTag;
            [hotIconButton setBackgroundImage:[UIImage imageNamed:@"hotIcon"] forState:UIControlStateNormal];

            [viewParent addSubview:hotIconButton];
        }
        
        [hotIconButton setHidden:NO];
        hotIconButton.frame = CGRectMake(0, 0, 37, 15);
        spaceYStart += 15;
    }
    else
    {
        UIButton *hotIconButton = (UIButton *)[viewParent viewWithTag:eCellHotIconTag];
        if (hotIconButton)
        {
            [hotIconButton setHidden:YES];
        }
    }
    
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
        CGSize realContentSize = [newsInfo.content sizeWithFontCompatible:kMiddleFont forWidth:viewSize->width-spaceXStart*2 lineBreakMode:NSLineBreakByTruncatingTail];
        
        CGFloat contentHeight;
        UILabel *briefLabel = (UILabel *)[viewParent viewWithTag:eCellBriefLabelTag];
        
        if (briefLabel == nil)
        {
            briefLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:newsInfo.content andColor:kTextColor withTag:eCellBriefLabelTag];
            briefLabel.textAlignment = NSTextAlignmentLeft;
            briefLabel.numberOfLines = 0;
            briefLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
            [viewParent addSubview:briefLabel];
        }
        
//        // 判断高度是否超过5行
//        if (realContentSize.height > maxRowCount*rowHeight)
//        {
//            // 展开
//            if (isExpand.boolValue)
//            {
                contentHeight = realContentSize.height;
                briefLabel.numberOfLines = 0;
//            }
//            // 折叠
//            else
//            {
//                contentHeight = rowHeight*maxRowCount;
//                briefLabel.numberOfLines = maxRowCount;
//            }
//        }
//        else
//        {
//            contentHeight = realContentSize.height;
//            briefLabel.numberOfLines = 0;
//        }
        
        
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
        
        CGSize timeSize = [time sizeWithFontCompatible:kSmallFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
        
        UILabel *timeLabel = (UILabel *)[viewParent viewWithTag:eCellTimeLabelTag];
        
        if (timeLabel == nil)
        {
            timeLabel = [[UILabel alloc] initWithFont:kSmallFont andText:time andColor:kTextColor withTag:eCellTimeLabelTag];
            timeLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:timeLabel];
        }
        timeLabel.frame = CGRectMake(spaceXStart, spaceYStart, viewSize->width-20, timeSize.height);
        timeLabel.text = time;
    }
    
    // =======================================================================
    // 我要参与
    // =======================================================================
    NSString *moreString = @"我要参与";
    CGSize moreSize = [moreString sizeWithFontCompatible:kSmallFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
    
    CustomButton *moreButton = (CustomButton *)[viewParent viewWithTag:eCellMoreButtonTag];
    if (moreButton == nil)
    {
        moreButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        moreButton.tag = eCellMoreButtonTag;
        [moreButton setTitle:moreString forState:UIControlStateNormal];
        [moreButton setTitleColor:kBackgroundGreenColor forState:UIControlStateNormal];
        [moreButton.titleLabel setFont:kSmallFont];
        [moreButton addTarget:self action:@selector(goJoinBBSAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewParent addSubview:moreButton];
    }
    
    // 新闻详情所需信息
    NSMutableArray *joinInfo = [[NSMutableArray alloc] init];
    [joinInfo addObject:newsInfo.newsId];
    [joinInfo addObject:newsInfo.subject];
    
    moreButton.customInfo = joinInfo;
    moreButton.frame = CGRectMake(kScreenWidth-10-moreSize.width, spaceYStart, moreSize.width, moreSize.height);
    
    spaceXEnd -= 10;
    spaceXEnd -= moreSize.width;
    
    // =======================================================================
    // 点评
    // =======================================================================
    
    // 点评数
    if (newsInfo.participationCount != nil)
    {
        NSString *commentCount = [NSString stringWithFormat:@"%ld", (long)[newsInfo.participationCount integerValue]];
        
        CGSize commentSize = [commentCount sizeWithFontCompatible:kSmallFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
        
        CustomButton *moreButton = (CustomButton *)[viewParent viewWithTag:eCellCommentButtonTag];
        if (moreButton == nil)
        {
            moreButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            moreButton.tag = eCellCommentButtonTag;
            [moreButton setTitle:moreString forState:UIControlStateNormal];
            [moreButton setTitleColor:kTextColor forState:UIControlStateNormal];
            [moreButton.titleLabel setFont:kSmallFont];
            [viewParent addSubview:moreButton];
        }
        [moreButton setTitle:commentCount forState:UIControlStateNormal];
        moreButton.frame = CGRectMake(spaceXEnd-5-commentSize.width, spaceYStart, commentSize.width, commentSize.height);
        
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
    commentButton.customInfo = newsInfo.newsId;
    commentButton.frame = CGRectMake(spaceXEnd-32, spaceYStart, 28, 18);
    
    // 调整Y
    spaceYStart += moreSize.height;
    spaceYStart += 12;
  
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



@end
