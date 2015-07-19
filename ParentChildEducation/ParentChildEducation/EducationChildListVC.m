//
//  ChildEducationClassVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/10.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "EducationChildListVC.h"
#import "HAdvertiseVIew.h"
#import "EducationChildDetailVC.h"

#import "NewsListResult.h"
#import "NewsListInfo.h"
#import "NewsListImagesInfo.h"
#import "ImageInfo.h"

#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"

#import "AdResult.h"
#import "AdInfo.h"

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"


typedef NS_ENUM(NSInteger, ControlTag) {
    eCellTitleLabelTag = 100,
    eCellBriefLabelTag,
    eCellImageViewTag,
    eCellTimeLabelTag,
    eCellLikeButtonTag,
    eCellLikeClickButtonTag,
    eCellLineViewTag,
};

@interface EducationChildListVC ()<UITableViewDataSource, UITableViewDelegate, NetworkPtc, HAdvertiseVIewDelegate, MWPhotoBrowserDelegate, SDPhotoGroupDelegate>

@property (nonatomic, strong) HAdvertiseVIew *adView;                   // 广告视图
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NewsListResult *newsListResult;
@property (nonatomic, strong) AdResult *adResult;
@property (nonatomic, strong) NSMutableArray *adList;

@property (nonatomic, strong) NSMutableArray *photos;

@end
@implementation EducationChildListVC

- (void)dealloc
{
    _adView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getNewsRequest];
    
    [self getAdRequest];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _adList = [[NSMutableArray alloc] init];
    
    [self setupRootViewSubs:self.view];
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceYEnd = viewParent.height;    
    NSInteger spaceXStart = 0;

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

- (void)refreshHeaderView
{
    // =======================================================================
    // 广告视图
    // =======================================================================
    if (_adList && _adList.count > 0)
    {
        if (_adView == nil)
        {
            _adView = [[HAdvertiseVIew alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 120)];
            _adView.delegate = self;
        }
        
        [_adView setDataSource:_adList animationDuration:10];
        
        // 设置header
        [_tableView setTableHeaderView:_adView];
    }
    else
    {
        [_tableView setTableHeaderView:nil];
    }

}

#pragma mark - 网络请求

- (void)getAdRequest
{
    [self loadingAnimation];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    
    // 发送请求
    [NetWorkTask postRequest:kRequestChildClassAdImages
                 forParamDic:nil
                searchResult:[[AdResult alloc] init]
                 andDelegate:self forInfo:kRequestChildClassAdImages
                  isMockData:kIsMock_RequestSlides];
}
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
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"type"];
    
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
    
    if ([customInfo isEqualToString:kRequestNewsList])
    {
        [self getSearchNetBackOfNewsList:searchResult forInfo:customInfo];
    }
    else if ([customInfo isEqualToString:kRequestChildClassAdImages])
    {
        [self getSearchNetBackOfAdList:(AdResult *)searchResult forInfo:customInfo];
    }
    
}

// 新闻列表回调
- (void)getSearchNetBackOfNewsList:(NewsListResult *)searchResult forInfo:(id)customInfo
{

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

// 轮播广告
- (void)getSearchNetBackOfAdList:(AdResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        if ([searchResult.status integerValue] == 0)
        {
            // 获取成功
            if ([searchResult.isSuccess integerValue] == 0)
            {
                _adResult = searchResult;
                _adList = _adResult.slideList;
                
                [self refreshHeaderView];
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
    NSString *reuseIdentifier = @"ChildEducationClassVCCellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    CGSize contentViewSize = CGSizeMake(tableView.width, 0);
    [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
    
    [self setupViewSubsChildEducationCell:cell.contentView inSize:&contentViewSize indexPath:indexPath];
    
    return cell;

}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize contentViewSize = CGSizeMake(tableView.width, 0);
    
    [self setupViewSubsChildEducationCell:nil inSize:&contentViewSize indexPath:indexPath];
    
    return contentViewSize.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsListInfo *newsItem = [_newsListResult.newsList objectAtIndex:indexPath.row];
    NSNumber *newsId = newsItem.newsId;
    
    EducationChildDetailVC *detailVC = [[EducationChildDetailVC alloc] initWithName:@"育儿学堂"];
    detailVC.newsId = newsId;
    
    [self.navigationController pushViewController:detailVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// cell布局
- (void)setupViewSubsChildEducationCell:(UIView *)viewParent inSize:(CGSize *)viewSize indexPath:(NSIndexPath *)indexPath
{
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

    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
    NSInteger spaceXEnd = viewSize->width;

    // =======================================================================
    // 图片
    // =======================================================================
    UIView *imageView = (UIView *)[viewParent viewWithTag:eCellImageViewTag];
    
    if (imageView == nil)
    {
        imageView = [[UIView alloc] initWithFrame:CGRectZero];
        imageView.tag = eCellImageViewTag;
        [viewParent addSubview:imageView];
    }
    
    imageView.frame = CGRectMake(spaceXStart, spaceYStart, 120, 80);
    
    // 子视图
    [self setupImageViewSubs:imageView inSize:imageView.size orginUrls:(NSMutableArray *)originUrls thumbUrls:(NSMutableArray *)thumbUrl];
    
    spaceXStart += imageView.width;
    spaceXStart += 10;
    
    // =======================================================================
    // title
    // =======================================================================
    if ([newsInfo.subject isStringSafe])
    {
        CGSize titleSize = [newsInfo.subject sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart-10, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
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
        spaceYStart += titleLabel.height;
        spaceYStart += 10;
        
    }
    
    // =======================================================================
    // content
    // =======================================================================
    
    // 计算行高
    CGFloat rowHeight = [@"dd" sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail].height;
    
    NSInteger maxRowCount = 5;
    
    if ([newsInfo.content isStringSafe])
    {
        CGSize realContentSize = [newsInfo.content sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-10*2-imageView.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
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
        
        // 判断高度是否超过5行
        if (realContentSize.height > maxRowCount*rowHeight)
        {
            // 折叠
            briefLabel.numberOfLines = maxRowCount;
            contentHeight = maxRowCount*rowHeight;
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
    // 时间
    // =======================================================================
    if ([newsInfo.createDate isStringSafe])
    {
        NSString *time = newsInfo.createDate;
        CGSize timeSize = [time sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
        UILabel *timeLabel = (UILabel *)[viewParent viewWithTag:eCellTimeLabelTag];
        
        if (timeLabel == nil)
        {
            timeLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:time andColor:kTextColor withTag:eCellTimeLabelTag];
            timeLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:timeLabel];
        }
        timeLabel.frame = CGRectMake(spaceXStart, spaceYStart, timeSize.width, timeSize.height);
        timeLabel.text = newsInfo.createDate;
        
    }

    // =======================================================================
    // 点赞
    // =======================================================================

    // 点赞数
    if (newsInfo.like != nil)
    {
        NSString *commentCount = [NSString stringWithFormat:@"%ld", (long)[newsInfo.like integerValue]];
        
        CGSize commentSize = [commentCount sizeWithFontCompatible:kSmallFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];
        
        CustomButton *moreButton = (CustomButton *)[viewParent viewWithTag:eCellLikeButtonTag];
        if (moreButton == nil)
        {
            moreButton = [CustomButton buttonWithType:UIButtonTypeCustom];
            moreButton.tag = eCellLikeButtonTag;
            [moreButton setTitleColor:kTextColor forState:UIControlStateNormal];
            [moreButton.titleLabel setFont:kSmallFont];
            [viewParent addSubview:moreButton];
        }
        [moreButton setTitle:commentCount forState:UIControlStateNormal];
        moreButton.frame = CGRectMake(viewSize->width-10-commentSize.width, spaceYStart, commentSize.width, commentSize.height);
        
        spaceXEnd -= 10;
        spaceXEnd -= commentSize.width;
    }
    
    // icon
    CustomButton *commentButton = (CustomButton *)[viewParent viewWithTag:eCellLikeClickButtonTag];
    if (commentButton == nil)
    {
        commentButton = [CustomButton buttonWithType:UIButtonTypeCustom];
        commentButton.tag = eCellLikeClickButtonTag;
        [commentButton addTarget:self action:@selector(goLikeAction:) forControlEvents:UIControlEventTouchUpInside];
        [commentButton setImage:[UIImage imageNamed:@"DetailLikeUnSelected"] forState:UIControlStateNormal];
        
        [viewParent addSubview:commentButton];
    }
    commentButton.customInfo = newsInfo.newsId;
    commentButton.frame = CGRectMake(spaceXEnd-32, spaceYStart, 28, 18);
    

    // 调整Y
    spaceYStart += commentButton.height;
    spaceYStart += 5;
    
    // =======================================================================
    // 判断图片、文案高度谁大
    // =======================================================================
    
    if (imageView.height+10 > spaceYStart)
    {
        // 调整Y
        spaceYStart = imageView.height+10;
    }
    
    // 调整Y
    spaceYStart += 8;
    
    // 重新调整image的坐标
    imageView.frame = CGRectMake(10, (spaceYStart-80)/2, 120, 80);
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *lineView = (UIView *)[viewParent viewWithTag:eCellLineViewTag];
    if (lineView == nil)
    {
        lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, spaceYStart, viewParent.width, 0.5)];
        lineView.tag = eCellLineViewTag;
        
        [viewParent addSubview:lineView];
    }
    lineView.frame = CGRectMake(0, spaceYStart, viewParent.width, 0.5);
    
    // 调整Y
    spaceYStart += 2;
    
    // =======================================================================
    // 父尺寸设置
    // =======================================================================
    
    viewSize->height = spaceYStart;
    
    if (viewParent)
    {
        [viewParent setViewY:spaceYStart];
    }

}

- (void)goLikeAction:(CustomButton *)button
{
    
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
    
    if (orginUrls.count == 0)
    {
        UIImageView *placeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ChildClassError"]];
        [viewParent addSubview:placeImageView];
    }
}

- (void)imageClickReturn:(NSNumber *)newsId
{
    EducationChildDetailVC *detailVC = [[EducationChildDetailVC alloc] initWithName:@"育儿学堂"];
    detailVC.newsId = newsId;
    
    [self.navigationController pushViewController:detailVC animated:YES];
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
