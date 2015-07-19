//
//  CampusDynamicDetailVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/23.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "CampusDynamicDetailVC.h"
#import "NewsDetailResult.h"
#import "UIButton+WebCache.h"
#import "SDPhotoBrowser.h"
#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

typedef NS_ENUM(NSInteger, ControllTag)
{
    eTitleLabelTag = 1,
    eSubsTitleLabelTag,
    eNewsDateLabelTag,
    
    eContentLabelTag,
    eImageViewTag
};


@interface CampusDynamicDetailVC ()<UITableViewDataSource, UITableViewDelegate, NetworkPtc, MWPhotoBrowserDelegate, SDPhotoGroupDelegate>

@property (nonatomic, strong) NewsDetailResult *newsResult;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation CampusDynamicDetailVC

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
                searchResult:[[NewsDetailResult alloc] init]
                 andDelegate:self forInfo:kRequestNewsDetail];
}

#pragma mark - 网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    [self stopLoadingAnimation];
    if ([customInfo isEqualToString:kRequestNewsDetail])
    {
        [self getSearchNetBackOfNewsDetail:searchResult forInfo:customInfo];
    }
}

- (void)getSearchNetBackOfNewsDetail:(SearchNetResult *)searchResult forInfo:(id)customInfo
{
    if (searchResult != nil)
    {
        NewsDetailResult *parentRelateInfoResult = (NewsDetailResult *)searchResult;
        
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
    [_tableView reloadData];
}

#pragma mark - 布局

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height-spaceYStart)
                                                          style:UITableViewStylePlain];
    tableView.backgroundColor = kWhiteColor;
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
    
    return 50;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
        
        CGSize contentViewSize = CGSizeMake(tableView.width, 0);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];
        
        [self setupViewSubsContentCell:cell.contentView inSize:&contentViewSize];
        
        return cell;
    }
    curRow++;
    
    return nil;
}

#pragma mark - cell布局
- (void)setupViewSubsTitleCell:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 11;
    NSInteger spaceXStart = 10;
    
    // =======================================================================
    // title
    // =======================================================================
    
    if ([_newsResult.subject isStringSafe])
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
        
        // 计算尺寸
        CGSize titleSize = [_newsResult.subject sizeWithFontCompatible:kMiddleTitleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
        titleLabel.frame = CGRectMake(spaceXStart, spaceYStart, titleSize.width, titleSize.height);
        
        // 调整Y
        spaceYStart += titleSize.height;
    }
    
    // 调整Y
    spaceYStart += 13;
    
    // =======================================================================
    // subTitle
    // =======================================================================
    UILabel *subTitleLabel = (UILabel *)[viewParent viewWithTag:eSubsTitleLabelTag];
    if (subTitleLabel == nil)
    {
        subTitleLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:_subsTitle andColor:kTextColor withTag:eSubsTitleLabelTag];
        subTitleLabel.backgroundColor = kWhiteColor;
        
        [viewParent addSubview:subTitleLabel];
    }
    CGSize subTitleSize = [_subsTitle sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
    
    subTitleLabel.frame = CGRectMake(spaceXStart, spaceYStart, subTitleSize.width, subTitleSize.height);
    subTitleLabel.text = _subsTitle;
    
    // =======================================================================
    // 日期
    // =======================================================================
    if ([_newsResult.createDate isStringSafe])
    {
        UILabel *newsDateLabel = (UILabel *)[viewParent viewWithTag:eNewsDateLabelTag];
        if (newsDateLabel == nil)
        {
            newsDateLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:_newsResult.createDate andColor:kTextColor withTag:eNewsDateLabelTag];
            newsDateLabel.backgroundColor = kWhiteColor;
            [viewParent addSubview:newsDateLabel];
        }
        newsDateLabel.text = _newsResult.createDate;
        
        CGSize newsDateSize = [_newsResult.createDate sizeWithFontCompatible:kSmallTitleFont constrainedToSize:CGSizeMake(viewSize->width-spaceXStart*2, CGFLOAT_MAX) lineBreakMode:NSLineBreakByTruncatingTail];
        
        newsDateLabel.frame = CGRectMake(viewSize->width-newsDateSize.width-10, spaceYStart, newsDateSize.width, newsDateSize.height);
        
        // 调整Y
        spaceYStart += newsDateSize.height;
    }
    
    // 调整Y
    spaceYStart += 24;
    
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


@end