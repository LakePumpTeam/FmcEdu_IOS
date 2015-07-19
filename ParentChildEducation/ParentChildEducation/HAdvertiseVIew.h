//
//  AdvertiseCycleScrollView.h
//
//  Created by zlan on 14-8-01.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HAdvertiseVIewDelegate <NSObject>

- (void)imageClickReturn:(NSNumber *)newsId;

@end

@class HAdvertiseAndRedEnvelopeResult;

/*!
 *  实现原理：保持scrollView上有三个广告资源，始终显示中间的广告，左右滚动才会连续。
 *          当只有两个广告时，数据源再次添加两个广告数据，保持数据源有4个广告资源，保证顺序添加到scrollView的时候，相邻广告信息不相同。
 */

@interface HAdvertiseVIew : UIView<UIScrollViewDelegate>

// view
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong) UIPageControl *pageControl;

// dataSource
@property (nonatomic , strong) NSMutableArray *imagesViewArr;
@property (nonatomic , strong) NSMutableArray *imagesUrlArr;
@property (nonatomic , strong) NSMutableArray *schemaUrlArr;
@property (nonatomic , strong) NSMutableArray *contentViews;
@property (nonatomic, strong) NSArray *adList;
// 定时
@property (nonatomic , strong) NSTimer *animationTimer;
@property (nonatomic , assign) NSTimeInterval animationDuration;

// index
@property (nonatomic , assign) NSInteger previousPageIndex;
@property (nonatomic , assign) NSInteger currentPageIndex;
@property (nonatomic , assign) NSInteger rearPageIndex;//实际后一个索引

@property (nonatomic , assign) NSInteger totalPageCount;
@property (nonatomic , assign) NSInteger realTotalPageCount;

@property (nonatomic, strong) id <HAdvertiseVIewDelegate> delegate;

/**
 数据源
 **/
- (void)setDataSource: (NSArray*)adBannerList animationDuration:(double)animationDuration;
@end