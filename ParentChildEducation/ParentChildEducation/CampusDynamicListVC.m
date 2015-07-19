//
//  CampusDynamic.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/10.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "CampusDynamicListVC.h"
#import "TopTabView.h"

#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"

#import "CampusDynamicDetailVC.h"
#import "NewsListResult.h"
#import "NewsListInfo.h"
#import "NewsListImagesInfo.h"
#import "ImageInfo.h"

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

typedef NS_ENUM(NSInteger, ControlTag) {
    eCellTitleLabelTag = 100,
    eCellBriefLabelTag,
    eCellImageViewsTag,
    eCellTimeLabelTag,
    eCellMoreButtonTag,
    eCellLineViewTag,
};

// 业务类型
typedef NS_ENUM(NSInteger, BusinessType) {
    eBusinessActivityType = 2,
    eNotificationType,
    eNewsType,
};

@interface CampusDynamicListVC ()<TopTabViewDelegate, UITableViewDataSource, UITableViewDelegate, NetworkPtc, MWPhotoBrowserDelegate, SDPhotoGroupDelegate>

@property (nonatomic, assign) BusinessType businesType;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *srcStringArray;
@property (nonatomic, strong) NewsListResult *newsListResult;

@property (nonatomic, strong) NSMutableDictionary *isExpandDictionary;

@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation CampusDynamicListVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getNewsRequest:_businesType];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 默认业务类型
    _businesType = eBusinessActivityType;
    
    _isExpandDictionary = [[NSMutableDictionary alloc] init];
    
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
                                                          titles: [NSArray arrayWithObjects:@"活动", @"通知", @"新闻", nil]
                                                            type: @"top"];
    topBar.delegate = self;
    [viewParent addSubview:topBar];
    
    // 调整Y
    spaceYStart += 40;
    spaceYStart += 10;
    
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

#pragma mark - 事件处理
- (void)goDetailAction
{
    CampusDynamicDetailVC *detailVC = [[CampusDynamicDetailVC alloc] initWithName:@"校园动态"];
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)topTabSelect:(TopBarButton * )btn tabView:(TopTabView*) tabView;
{
    NSInteger businessType = btn.type;
    
    _businesType = businessType+2;
    
    [self getNewsRequest:_businesType];
    
}

#pragma mark - 网络请求
- (void)getNewsRequest:(NSInteger) queryType
{
    [self loadingAnimation];
    
    NSString *queryTypeString = [NSString stringWithFormat:@"%ld", (long)queryType];
    
    // =======================================================================
    // 请求参数：cellPhone 登录账号 password
    // =======================================================================
    
    // type  (1:育儿学堂, 2: 校园动态--活动，3:校园动态--通知, 4:校园动态--新闻, 5: 班级动态)
    
    NSNumber *userId = [[[DataController getInstance] getUserLoginInfo] objectForKey:kUserIdKey];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObjectSafe:base64Encode([userId stringValue]) forKey:@"userId"];
    [parameters setObjectSafe:base64Encode(@"1") forKey:@"pageIndex"];
    [parameters setObjectSafe:base64Encode(kPageSize) forKey:@"pageSize"];
    [parameters setObjectSafe:base64Encode(queryTypeString) forKey:@"type"];
  
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
    
    _newsListResult = searchResult;

    if (searchResult != nil)
    {
        
        if ([searchResult.status integerValue] == 0)
        {
            // 获取成功
            if ([searchResult.isSuccess integerValue] == 0)
            {
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

- (void)getSearchNetBackWithFailure:(id)customInfo
{
    [self stopLoadingAnimation];
    
    // 数据置空
    _newsListResult = nil;
    
    // 刷新页面
    [_tableView reloadData];
    
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
    switch (_businesType) {
        case eBusinessActivityType:
        {
            NSString *reuseIdentifier = @"campusDynamicActivityCellID";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                [cell.contentView setBackgroundColor:kWhiteColor];
            }
            
            CGSize contentViewSize = CGSizeMake(tableView.width, 0);
            [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
            
            [self setupViewSubsCellActivity:cell.contentView inSize:&contentViewSize curRow:indexPath.row];
            
            return cell;
            
            break;
        }
            
        case eNotificationType:
        {
            // 初始化展开状态，默认no
            NSNumber *isExpand = [_isExpandDictionary objectForKey:indexPath];
            if (isExpand == nil)
            {
                [_isExpandDictionary setObject:[NSNumber numberWithBool:NO] forKey:indexPath];
            }
            
            NSString *reuseIdentifier = @"campusDynamicNotificationCellID";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            CGSize contentViewSize = CGSizeMake(tableView.width, 0);
            [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
            
            [self setupViewSubsCellNotification:cell.contentView inSize:&contentViewSize indexPath:indexPath];
            
            return cell;

            break;
        }
        case eNewsType:
        {
            NSString *reuseIdentifier = @"campusDynamicNewsCellID";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            }
            
            CGSize contentViewSize = CGSizeMake(tableView.width, 0);
            [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
            
            [self setupViewSubsCellNews:cell.contentView inSize:&contentViewSize indexPath:indexPath];
            
            return cell;

            break;
        }
        default:
            break;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize contentViewSize = CGSizeMake(tableView.width, 0);
    
    switch (_businesType) {
        case eBusinessActivityType:
        {
            [self setupViewSubsCellActivity:nil inSize:&contentViewSize curRow:indexPath.row];
            break;
        }
        case eNotificationType:
        {
            [self setupViewSubsCellNotification:nil inSize:&contentViewSize indexPath:indexPath];
            break;
        }
        case eNewsType:
        {
            [self setupViewSubsCellNews:nil inSize:&contentViewSize indexPath:indexPath];
            break;
        }
            
        default:
            break;
    }
            
    
    return contentViewSize.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsListInfo *newsItem = [_newsListResult.newsList objectAtIndex:indexPath.row];
    NSNumber *newsId = newsItem.newsId;
    
    if (_businesType == eBusinessActivityType)
    {
        CampusDynamicDetailVC *detailVC = [[CampusDynamicDetailVC alloc] initWithName:@"校园动态"];
        detailVC.newsId = newsId;
        detailVC.subsTitle = @"校园活动";
        
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    else if (_businesType == eNewsType)
    {
        CampusDynamicDetailVC *detailVC = [[CampusDynamicDetailVC alloc] initWithName:@"校园动态"];
        detailVC.newsId = newsId;
        detailVC.subsTitle = @"校园新闻";
        
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 活动cell布局

- (void)setupViewSubsCellActivity:(UIView *)viewParent inSize:(CGSize *)viewSize curRow:(NSInteger)curRow
{
    // =======================================================================
    // 将各控件数据置空
    // =======================================================================
    UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eCellTitleLabelTag];
    titleLabel.text = @"";
    
    UILabel *briefLabel = (UILabel *)[viewParent viewWithTag:eCellBriefLabelTag];
    briefLabel.text = @"";
    
    UIView *imageSuperView = (UIView *)[viewParent viewWithTag:eCellImageViewsTag];
    [imageSuperView removeAllSubviews];
    
    UILabel *timeLabel = (UILabel *)[viewParent viewWithTag:eCellTimeLabelTag];
    timeLabel.text = @"";

    
    // =======================================================================
    // 布局
    // =======================================================================
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
    
    // 数据
    NewsListInfo *newsInfo;
    
    if (_newsListResult && _newsListResult.newsList.count > curRow)
    {
        newsInfo = _newsListResult.newsList[curRow];
    }
    
    NSMutableArray *originUrls = [[NSMutableArray alloc] init];
    NSMutableArray *thumbUrl = [[NSMutableArray alloc] init];
    
    if (newsInfo.imageUrls && newsInfo.imageUrls.count > 0)
    {
        for (int i = 0; i < newsInfo.imageUrls.count; i++)
        {
            NewsListImagesInfo *imagesList = newsInfo.imageUrls[i];
            [originUrls addObject:LoadImageUrl(imagesList.origUrl)];
            [thumbUrl addObject:LoadImageUrl(imagesList.thumbUrl)];
        }
    }
 
    
    // 构造数据
//    newsInfo = [[NewsListInfo alloc] init];
//    newsInfo.subject = @"大宝二宝最理想的年龄差";
//    newsInfo.content = @"带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧";
//    originUrls = @[@"http://ww2.sinaimg.cn/thumbnail/904c2a35jw1emu3ec7kf8j20c10epjsn.jpg",
//                        @"http://ww2.sinaimg.cn/thumbnail/98719e4agw1e5j49zmf21j20c80c8mxi.jpg",
//                        @"http://ww2.sinaimg.cn/thumbnail/67307b53jw1epqq3bmwr6j20c80axmy5.jpg",
//                        @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg"];
    

    // =======================================================================
    // title
    // =======================================================================
    if ([newsInfo.subject isStringSafe])
    {
        CGSize titleSize = [newsInfo.subject sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width - spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
        UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eCellTitleLabelTag];
        
        if (titleLabel == nil)
        {
            titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:newsInfo.subject andColor:[UIColor blackColor] withTag:eCellTitleLabelTag];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.numberOfLines = 0;
            
            [viewParent addSubview:titleLabel];
        }
        titleLabel.frame = CGRectMake(spaceXStart, spaceYStart, viewSize->width - spaceXStart*2, titleSize.height);
        titleLabel.text = newsInfo.subject;
        
        // 调整Y
        spaceYStart += titleSize.height;
        spaceYStart += 10;
    }
    
    // =======================================================================
    // content
    // =======================================================================
    
    // 计算行高
    CGFloat rowHeight = [@"泉吧" sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail].height;
    NSInteger maxRowCount = 5;
    
    if ([newsInfo.content isStringSafe])
    {
        CGSize realContentSize = [newsInfo.content sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
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
        CGSize timeSize = [time sizeWithFontCompatible:kMiddleFont forWidth:viewParent.width lineBreakMode:NSLineBreakByTruncatingTail];
        
        UILabel *timeLabel = (UILabel *)[viewParent viewWithTag:eCellTimeLabelTag];
        
        if (timeLabel == nil)
        {
            timeLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:time andColor:kTextColor withTag:eCellTimeLabelTag];
            timeLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:timeLabel];
        }
        timeLabel.frame = CGRectMake(spaceXStart, spaceYStart, timeSize.width, timeSize.height);
        timeLabel.text = newsInfo.createDate;
        
        // 调整Y
        spaceYStart += timeSize.height;
        spaceYStart += 5;
    }
    
    
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
}

#pragma mark - 通知cell布局
- (void)setupViewSubsCellNotification:(UIView *)viewParent inSize:(CGSize *)viewSize indexPath:(NSIndexPath *)indexPath
{
    // =======================================================================
    // 将各控件数据置空
    // =======================================================================
    UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eCellTitleLabelTag];
    titleLabel.text = @"";
    
    UILabel *briefLabel = (UILabel *)[viewParent viewWithTag:eCellBriefLabelTag];
    briefLabel.text = @"";
    
    UIView *imageSuperView = (UIView *)[viewParent viewWithTag:eCellImageViewsTag];
    [imageSuperView removeAllSubviews];
    
    UILabel *timeLabel1 = (UILabel *)[viewParent viewWithTag:eCellTimeLabelTag];
    timeLabel1.text = @"";
    
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
//    NSInteger spaceXEnd = viewSize->width;
//    
    // 数据
    NewsListInfo *newsInfo;
    if (_newsListResult.newsList && _newsListResult.newsList.count > indexPath.row)
    {
        newsInfo = _newsListResult.newsList[indexPath.row];
    }
//    NewsListImagesInfo *imagesList = newsInfo.imageUrls[0];
//    NSArray *originUrls = imagesList.origUrl;
//    NSMutableArray *thumbUrl = imagesList.thumbUrl;
    
    // 构造数据
//    newsInfo = [[NewsListInfo alloc] init];
//    newsInfo.subject = @"大宝二宝最理想的年龄差";
//    newsInfo.commentCount = [NSNumber numberWithInteger:99999];
//    newsInfo.content = @"带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧";
//    originUrls = @[@"http://ww2.sinaimg.cn/thumbnail/904c2a35jw1emu3ec7kf8j20c10epjsn.jpg",
//                   @"http://ww2.sinaimg.cn/thumbnail/98719e4agw1e5j49zmf21j20c80c8mxi.jpg",
//                   @"http://ww2.sinaimg.cn/thumbnail/67307b53jw1epqq3bmwr6j20c80axmy5.jpg",
//                   @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg"];
    
    // 计算行高
    CGFloat rowHeight = [@"泉吧" sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail].height;
    NSInteger maxRowCount = 5;
    
    // =======================================================================
    // title
    // =======================================================================
    if ([newsInfo.subject isStringSafe])
    {
        CGSize titleSize = [newsInfo.subject sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
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
        CGSize realContentSize = [newsInfo.content sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
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
            [moreButton addTarget:self action:@selector(goExpandAction:) forControlEvents:UIControlEventTouchUpInside];
            [viewParent addSubview:moreButton];
        }
        moreButton.customInfo = indexPath;
        moreButton.frame = CGRectMake(kScreenWidth-10-moreSize.width, spaceYStart, moreSize.width, moreSize.height);
        moreButton.hidden = NO;
        
    }
    else
    {
        CustomButton *moreButton = (CustomButton *)[viewParent viewWithTag:eCellMoreButtonTag];
        if (moreButton)
        {
            moreButton.hidden = YES;
        }
    }
    
    // 调整Y
    CGSize timeSize = [@"22" sizeWithFontCompatible:kMiddleFont forWidth:viewSize->width lineBreakMode:NSLineBreakByTruncatingTail];

    // 调整Y
    spaceYStart += timeSize.height;
    spaceYStart += 5;
    
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

// 通知展开
- (void)goExpandAction:(CustomButton *)button
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

#pragma mark - 新闻Cell布局
- (void)setupViewSubsCellNews:(UIView *)viewParent inSize:(CGSize *)viewSize indexPath:(NSIndexPath *)indexPath
{
    // =======================================================================
    // 将各控件数据置空
    // =======================================================================
    UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eCellTitleLabelTag];
    titleLabel.text = @"";
    
    UILabel *briefLabel = (UILabel *)[viewParent viewWithTag:eCellBriefLabelTag];
    briefLabel.text = @"";
    
    UIView *imageSuperView = (UIView *)[viewParent viewWithTag:eCellImageViewsTag];
    [imageSuperView removeAllSubviews];
    
    UILabel *timeLabel = (UILabel *)[viewParent viewWithTag:eCellTimeLabelTag];
    timeLabel.text = @"";
    
    NSInteger spaceYStart = 10;
    NSInteger spaceXStart = 10;
    
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

//    // 数据
//    NewsListInfo *newsInfo = _newsListResult.newsList[indexPath.row];
//    NewsListImagesInfo *imagesList = newsInfo.imageUrls[0];
//    NSArray *originUrls = imagesList.origUrl;
//    NSMutableArray *thumbUrl = imagesList.thumbUrl;
//    
//    // 构造数据
//    newsInfo = [[NewsListInfo alloc] init];
//    newsInfo.subject = @"大宝二宝最理想的年龄差";
//    newsInfo.content = @"带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧带上全家去泡温泉吧";
//    originUrls = @[@"http://ww2.sinaimg.cn/thumbnail/904c2a35jw1emu3ec7kf8j20c10epjsn.jpg",
//                   @"http://ww2.sinaimg.cn/thumbnail/98719e4agw1e5j49zmf21j20c80c8mxi.jpg",
//                   @"http://ww2.sinaimg.cn/thumbnail/67307b53jw1epqq3bmwr6j20c80axmy5.jpg",
//                   @"http://ww2.sinaimg.cn/thumbnail/9ecab84ejw1emgd5nd6eaj20c80c8q4a.jpg"];
//    
    
    // =======================================================================
    // title
    // =======================================================================
    if ([newsInfo.subject isStringSafe])
    {
        CGSize titleSize = [newsInfo.subject sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width - spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
        UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eCellTitleLabelTag];
        
        if (titleLabel == nil)
        {
            titleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:newsInfo.subject andColor:[UIColor blackColor] withTag:eCellTitleLabelTag];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.numberOfLines = 0;
            
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
    CGFloat rowHeight = [@"泉吧" sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail].height;
    NSInteger maxRowCount = 5;
    
    if ([newsInfo.content isStringSafe])
    {
        CGSize realContentSize = [newsInfo.content sizeWithFontCompatible:kMiddleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
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
        CGSize timeSize = [time sizeWithFontCompatible:kMiddleFont forWidth:viewParent.width lineBreakMode:NSLineBreakByTruncatingTail];
        
        UILabel *timeLabel = (UILabel *)[viewParent viewWithTag:eCellTimeLabelTag];
        
        if (timeLabel == nil)
        {
            timeLabel = [[UILabel alloc] initWithFont:kMiddleFont andText:time andColor:kTextColor withTag:eCellTimeLabelTag];
            timeLabel.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:timeLabel];
        }
        timeLabel.frame = CGRectMake(spaceXStart, spaceYStart, timeSize.width, timeSize.height);
        timeLabel.text = newsInfo.createDate;
        
        // 调整Y
        spaceYStart += timeSize.height;
        spaceYStart += 5;
    }

    
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
