//
//  AdvertiseCycleScrollView.h
//
//  Created by zlan on 14-8-01.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "HAdvertiseVIew.h"
//#import "AdditionalImageView.h"
#import "HAdvertiseInfo.h"
//#import "HAdvertiseAndRedEnvelopeResult.h"
#import "NSTimer+Addition.h"

#import "AdInfo.h"

typedef enum
{
    pageControlTag = 2000,
} viewsTag;

@implementation HAdvertiseVIew

- (void)dealloc {
    [_animationTimer invalidate];
    _animationTimer = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setAutoresizesSubviews:YES];
        
        // 滚动视图
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setAutoresizingMask:0xFF];
        [_scrollView setContentSize:CGSizeMake(3 * self.width, self.height)];
        [_scrollView setContentMode:UIViewContentModeCenter];
        [_scrollView setDelegate:self];
        [_scrollView setContentOffset:CGPointMake(self.width, 0)];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:false];
        
        // 保存
        [self addSubview:_scrollView];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0 , self.bounds.size.height-20, self.bounds.size.width, 20)];
        [_pageControl setNumberOfPages:0];
        [_pageControl setCurrentPage:0];
        [_pageControl setEnabled:NO];
        [_pageControl setBackgroundColor:[UIColor clearColor]];
        [_pageControl setTag:pageControlTag ] ;
        // 保存
        [self addSubview:_pageControl];
    }
    return self;
}

- (void)setDataSource: (NSArray*)adBannerList animationDuration:(double)animationDuration
{
    //initDataSource
    _imagesUrlArr = [[NSMutableArray alloc]init];
    _schemaUrlArr = [[NSMutableArray alloc]init];
    _imagesViewArr = [[NSMutableArray alloc]init];
    _contentViews = [[NSMutableArray alloc]init];
    _currentPageIndex = 0;
    _realTotalPageCount = adBannerList.count;
    
    _adList = adBannerList;
    
    // test
//    _realTotalPageCount = 5;
    
    // 添加广告数据
    for (int i = 0; i < _realTotalPageCount; i++)
    {
//        HAdvertiseInfo *advertiseInfo = adBannerList[i];
//        [_schemaUrlArr addObject:advertiseInfo.schemaUrl];
        AdInfo *adInfo = adBannerList[i];
        
        [_imagesUrlArr addObject:LoadImageUrl(adInfo.imageUrl)];

        NSString *imageName = [NSString stringWithFormat:@"test%d",i];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:imageName];
        [imageView sd_setImageWithURL:[NSURL URLWithString:LoadImageUrl(adInfo.imageUrl)]
                     placeholderImage:[UIImage imageNamed:@"adErrorImage"]];
        
//        AdditionalImageView *imageView = [[AdditionalImageView alloc] initWithFrame:CGRectZero withInitImage:kHotelAdvertiseDefaultBgImageFile andTapLoadImage:nil];
        [imageView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];

        // 添加手势
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClickAction:)];
        [imageView addGestureRecognizer:tapGesture];
        [_imagesViewArr addObject:imageView];
    }
    
    // 设置pageControl
    [_pageControl setNumberOfPages:_imagesViewArr.count];
    
    // 广告位数目为2，凑齐4个 0101(任选三个不重复）
    if (_imagesViewArr.count == 2)
    {
        
        for (int i = 0; i < 2; i++) {
//            HAdvertiseInfo *advertiseInfo = adBannerList[i];
//            [_imagesUrlArr addObject:advertiseInfo.imgUrl];
//            [_schemaUrlArr addObject:advertiseInfo.schemaUrl];
            
//            NSString *imageName = [NSString stringWithFormat:@"test%d",i];
            
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView sd_setImageWithURL:[NSURL URLWithString:_imagesUrlArr[i]]
                         placeholderImage:[UIImage imageNamed:@"adErrorImage"]];
//            AdditionalImageView *imageView = [[AdditionalImageView alloc] initWithFrame:CGRectZero withInitImage:kHotelAdvertiseDefaultBgImageFile andTapLoadImage:nil];
            [imageView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//            [imageView replaceWithImageID:_imagesUrlArr[i]
//                           errorImageName:kHotelAdvertiseDefaultBgImageFile
//                         tapLoadImageName:nil];
            // 添加手势
            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClickAction:)];
            [imageView addGestureRecognizer:tapGesture];
            [_imagesViewArr addObject:imageView];
        }
    }
    
    // 定时
    _animationDuration = animationDuration;
    if (_animationDuration > 0.0)
    {
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:_animationDuration
                                                           target:self
                                                         selector:@selector(animationTimerDidFired:)
                                                         userInfo:nil
                                                          repeats:YES];
        [_animationTimer pauseTimer];
    }
    // 刷新
    [self refreshView];
}
#pragma mark -
#pragma mark - 私有函数

- (void)configContentViews
{
    if (_scrollView != nil)
    {
        [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        [self setScrollViewContentDataSource];
        
        NSInteger counter = 0;
        for (UIView *contentView in _contentViews)
        {
            CGRect rightRect = contentView.frame;
            rightRect.origin = CGPointMake(CGRectGetWidth(_scrollView.frame) * (counter ++), 0);
            
            contentView.frame = rightRect;
            [_scrollView addSubview:contentView];
            
            if (counter==2)
            {
                UIPageControl *pageControl = (UIPageControl *) [self viewWithTag:pageControlTag] ;
                if (_realTotalPageCount == 2) {
                        pageControl.currentPage = _currentPageIndex % 2;
                }else{
                    pageControl.currentPage = [self getValidNextPageIndexWithPageIndex:_currentPageIndex ];
                }
            }
        }
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
}
/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex + 1];
    
    [_contentViews removeAllObjects];
    
    if (_imagesViewArr.count != 0)
    {
        [_contentViews addObject:_imagesViewArr[previousPageIndex]];
        [_contentViews addObject:_imagesViewArr[_currentPageIndex]];
        [_contentViews addObject:_imagesViewArr[rearPageIndex]];
    }
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1)
    {
        return _totalPageCount - 1;
    }
    else if (currentPageIndex == _totalPageCount)
    {
        return 0;
    }
    else
    {
        return currentPageIndex;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_animationTimer != nil)
    {
        [_animationTimer pauseTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_animationTimer != nil)
    {
        [_animationTimer resumeTimerAfterTimeInterval:_animationDuration];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != nil && _scrollView != nil)
    {
        int contentOffsetX = scrollView.contentOffset.x;
        if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame)))
        {
            _currentPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex + 1];
            [self configContentViews];
        }
        if(contentOffsetX <= 0)
        {
            _currentPageIndex = [self getValidNextPageIndexWithPageIndex:_currentPageIndex - 1];
            [self configContentViews];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView != nil)
    {
        [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
    }
}

#pragma mark -
#pragma mark - 响应事件

- (void)animationTimerDidFired:(NSTimer *)timer
{
    if (timer != nil && _scrollView != nil)
    {
        CGPoint newOffset = CGPointMake(_scrollView.contentOffset.x + CGRectGetWidth(_scrollView.frame), _scrollView.contentOffset.y);
        [_scrollView setContentOffset:newOffset animated:YES];
    }
}

- (void)imageViewClickAction:(UITapGestureRecognizer *)tap
{
//    if (_schemaUrlArr.count > _currentPageIndex)
//    {
//        NSString *urlString = _schemaUrlArr[_currentPageIndex];
//        if (urlString != nil)
//        {
//            NSURL *url = [NSURL URLWithString:urlString];
//            if (url != nil)
//            {
//                [[UIApplication sharedApplication] openURL:url];
//            }
//        }
//    }
    if (_delegate && [_delegate respondsToSelector:@selector(imageClickReturn:)])
    {
        AdInfo *adInfo = _adList[_currentPageIndex];

        [_delegate imageClickReturn:adInfo.newsId];
    }
}
- (void)refreshView
{
    _totalPageCount = _imagesViewArr.count;
    //只有一个广告，显示图片
    if (_totalPageCount == 1)
    {
        [self removeAllSubviews];
        _currentPageIndex = 0;
        //保存
        [self addSubview:_imagesViewArr[0]];
    }
    else
    {
        [self configContentViews];
        if (_animationTimer != nil)
        {
            [_animationTimer resumeTimerAfterTimeInterval:_animationDuration];
        }
    }
}
@end
