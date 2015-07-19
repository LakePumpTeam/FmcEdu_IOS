//
//  BaseNameVC.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseNameVC : UIViewController

@property (nonatomic, strong) NSString *vcName;                                 // 名称
@property (nonatomic, strong) LoadView *loadingView;

// 初始化函数
- (id)init;
- (id)initWithName:(NSString *)vcNameInit;

- (void)setSearchItem;

- (void)setReturnItemHidden;

// =======================================================================
// 加载中
// =======================================================================

- (void)loadingAnimation;
- (void)stopLoadingAnimation;

@end
