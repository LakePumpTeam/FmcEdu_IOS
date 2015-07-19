//
//  BaseNameVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "BaseNameVC.h"
#import "NSString+Utility.h"

@interface BaseNameVC ()<UIGestureRecognizerDelegate>

@end

@implementation BaseNameVC

- (id)init
{
    self = [super init];

    if (self) {
        // 默认name
        _vcName = @"相伴教育";
        
    }
    
    return self;
}

- (id)initWithName:(NSString *)vcNameInit
{
    self = [self init];
    
    if(self)
    {
        if ([vcNameInit isStringSafe]) {
            _vcName = vcNameInit;
        }
        
        return self;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置导航
    [self setupNavigationBar];
    
    // 背景色
    [self.view setBackgroundColor:kBackgroundColor];
    
    [self.view setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
   
}

// 导航
- (void)setupNavigationBar
{
    if (kSystemVersion >= 7.0)
    {
        // 导航背景色
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:1/255.0 green:186/255.0 blue:188/255.0 alpha:1.0]];
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:1/255.0 green:186/255.0 blue:188/255.0 alpha:1.0]];
    }
    
    // title
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Bold"size:20], NSFontAttributeName, nil]];
    
    [self.navigationItem setTitle:_vcName];

    // 自定义返回
    UIImage *backButtonImage = [[UIImage imageNamed:@"Back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    backButton.frame = CGRectMake(10, 0, backButtonImage.size.width, backButtonImage.size.height);
    
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = item;
    self.navigationItem.backBarButtonItem = nil;
    
    
    // 状态栏颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}
#pragma mark - 事件
- (void)goBack
{
   	[self.navigationController popViewControllerAnimated:YES];
}

- (void)setSearchItem
{
    // 增加搜索
    UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(doSearchAction) forControlEvents:UIControlEventTouchUpInside];
    settingButton.frame = CGRectMake(0, 0, 21, 21);
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:settingButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)doSearchAction
{
    
}

// 隐藏返回
- (void)setReturnItemHidden
{
    // 隐藏返回按钮
    UIBarButtonItem *nItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationItem.leftBarButtonItem = nItem;
    self.navigationItem.backBarButtonItem = nItem;
    
    if (kSystemVersion < 7) {
        UIBarButtonItem *nItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
        self.navigationItem.backBarButtonItem = nItem;
        self.navigationItem.leftBarButtonItem = nItem;
        
    }
}

- (void)loadingAnimation
{
    if (_loadingView == nil)
    {
        // 加载中视图
        _loadingView = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _loadingView.center = self.view.center;
    }
    [self.view addSubview:_loadingView];

    [_loadingView setHidden:NO];
    [_loadingView startLoadingView];
}
- (void)stopLoadingAnimation
{
    if (_loadingView)
    {
        [_loadingView setHidden:YES];
        [_loadingView stopLoadingView];
    }
    
}

@end
