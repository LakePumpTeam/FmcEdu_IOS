//
//  StudentListView.m
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "StudentListView.h"
#import "StudentInfo.h"

typedef NS_ENUM(NSInteger, ControllTag)
{
    eTitleLabelTag = 1,
    eCloseIconTag,
    eSepartorLineTag,
};


@implementation StudentListView

- (id)initWithStudentList:(NSMutableArray *)studentList delegate:(AddTaskVC *)delegate;
{
    self = [super init];
    if (self)
    {
        _studentList = studentList;
        _delegate = delegate;
        
        // 布局界面
        [self setupSuspendedView];
        [self setFrame:[UIScreen mainScreen].bounds];
    }
    
    return self;
}

- (void)doClose:(UIButton *)tapGesture
{
    [self removeFromSuperview];
}

- (void)setupSuspendedView
{
    // =======================================================================
    // 游标
    // =======================================================================
    NSInteger spaceXStart = 20;
    NSInteger spaceYStart = kNavigationBarHeight+5;
    
    // =======================================================================
    // 底层半透明浮窗
    // =======================================================================
    
    CGSize suspendedViewSize = [UIScreen mainScreen].bounds.size;
    _suspendView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, suspendedViewSize.width, suspendedViewSize.height)];
    
    [_suspendView setBackgroundColor:[UIColor colorWithHex:0x333333 alpha:0.5f]];
    
    // 添加
    [_suspendView setUserInteractionEnabled:NO];
    [self addSubview:_suspendView];
    
    // =======================================================================
    // title
    // =======================================================================
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = kWhiteColor;
    titleView.frame = CGRectMake(spaceXStart, spaceYStart, kScreenWidth-spaceXStart*2, 44);
    
    CGSize titleViewSize = CGSizeMake(kScreenWidth-spaceXStart*2, 0);
    [self setupTitleViewSubs:titleView inSize:&titleViewSize];
    
    [self addSubview:titleView];
    
    // 调整Y
    spaceYStart += 44;
    
    // =======================================================================
    // _scrollView
    // =======================================================================
    
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setFrame:CGRectMake(spaceXStart, spaceYStart, kScreenWidth-spaceXStart*2, kScreenHeight-spaceYStart-30-90)];
    
    CGSize scrollSize = CGSizeMake(kScreenWidth-spaceXStart*2, 0);
    // 子View
    [self setupSuspendedScrollViewSubs:_scrollView inSize:&scrollSize];
    
    [_scrollView setContentSize:scrollSize];
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    [self addSubview:_scrollView];
    
    if (scrollSize.height < kScreenHeight-spaceYStart-30-90)
    {
        [_scrollView setFrame:CGRectMake(spaceXStart, spaceYStart+30, kScreenWidth-spaceXStart*2, scrollSize.height)];
    }
    
    spaceYStart += _scrollView.height;
    spaceYStart += 35;
    // =======================================================================
    // 确定
    // =======================================================================
    UIView *confirmView = [[UIView alloc] init];
    confirmView.backgroundColor = kWhiteColor;
    confirmView.frame = CGRectMake(spaceXStart, spaceYStart, kScreenWidth-spaceXStart*2, 55);
    
    [self addSubview:confirmView];
    
    CGSize confirmViewSize = CGSizeMake(kScreenWidth-spaceXStart*2, 90);
    [self setupConfirmViewSubs:confirmView inSize:&confirmViewSize];
    
    // =======================================================================
    // 调整垂直居中
    // =======================================================================
    [titleView setViewY:(kScreenHeight-kNavigationBarHeight-titleView.height-_scrollView.height)/2+10];
    [_scrollView setViewY:titleView.bottom];
    [confirmView setViewY:_scrollView.bottom];
}

- (void)setupConfirmViewSubs:(UIView *)viewParent inSize:(CGSize *)viewSize
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 20;
    
    // =======================================================================
    // 确定
    // =======================================================================
    UIButton *logOutBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [logOutBtn setTitle:@"确定" forState:UIControlStateNormal];
    [logOutBtn addTarget:self action:@selector(doSubmitAction) forControlEvents:UIControlEventTouchUpInside ];
    logOutBtn.titleLabel.font=kSmallTitleFont;
    logOutBtn.tintColor = [UIColor whiteColor];
    logOutBtn.backgroundColor = kBackgroundGreenColor;
    logOutBtn.layer.cornerRadius = 20;
    logOutBtn.frame = CGRectMake(spaceXStart, spaceYStart, viewSize->width - spaceXStart*2, 40) ;
    
    [viewParent addSubview:logOutBtn];
    
    // 调整Y
    spaceYStart += logOutBtn.height;
    spaceYStart += 15;
    
    viewSize->height = spaceYStart;
}

- (void)setupSuspendedScrollViewSubs:(UIView *)viewParent inSize:(CGSize *)inSize
{
    NSInteger spaceYStart = 22;
    NSInteger spaceXStart = 60;
    
    if (_studentList && _studentList.count > 0)
    {
        for (StudentInfo *student in _studentList)
        {
            // =======================================================================
            // 选择框
            // =======================================================================
            // image背景
            UIView *backGroundView = [[UIView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, 18, 18)];
            backGroundView.backgroundColor = [UIColor whiteColor];
            backGroundView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            backGroundView.layer.borderWidth = 0.5;
            [viewParent addSubview:backGroundView];
            
            CustomButton *imageView = [[CustomButton alloc] init];
            [imageView setImage:[UIImage imageNamed:@"protocolSelect"] forState:UIControlStateNormal];
            imageView.frame = CGRectMake((backGroundView.width-14)/2, (backGroundView.height-12)/2, 14, 12);
            imageView.backgroundColor = [UIColor whiteColor];
            [imageView addTarget:self action:@selector(doSelect:) forControlEvents:UIControlEventTouchUpInside];
            imageView.customInfo = student;
            
            [backGroundView addSubview:imageView];
            
            // 是否选中
            if (student.status)
            {
                [imageView setImage:[UIImage imageNamed:@"protocolSelect"] forState:UIControlStateNormal];
            }
            else
            {
                [imageView setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            }
            
            spaceXStart += backGroundView.width;
            spaceXStart += 38;
            // =======================================================================
            // 学生姓名
            // =======================================================================
            UILabel *label = [[UILabel alloc] initWithFont:kSmallTitleFont andText:student.name andColor:[UIColor colorWithHex:0x777777 alpha:1.0] withTag:11];
            label.frame = CGRectMake(spaceXStart, spaceYStart, viewParent.width-spaceXStart, 18);
            label.textAlignment = NSTextAlignmentLeft;
            
            [viewParent addSubview:label];
            
            // 调整坐标
            spaceYStart += 18;
            spaceYStart += 25;
            spaceXStart = 60;

        }
    }
    
    
    inSize->height = spaceYStart;
    
}

// titleView
- (void)setupTitleViewSubs:(UIView *)viewParent inSize:(CGSize *)inSize
{
    // =======================================================================
    // title
    // =======================================================================
    UILabel *titleLabel = (UILabel *)[viewParent viewWithTag:eTitleLabelTag];
    if (titleLabel == nil)
    {
        titleLabel = [[UILabel alloc] initWithFont:kMiddleTitleFont andText:@"学生列表" andColor:[UIColor colorWithHex:0x3c3c3c alpha:1.0] withTag:eTitleLabelTag];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [viewParent addSubview:titleLabel];
    }
    titleLabel.frame = CGRectMake(0, 0, viewParent.width, viewParent.height-1);
    titleLabel.text = @"学生列表";
    
    // =======================================================================
    // 关闭按钮
    // =======================================================================
    UIButton *closeIcon = (UIButton *)[viewParent viewWithTag:eCloseIconTag];
    if (closeIcon == nil)
    {
        closeIcon = [[UIButton alloc] init];
        closeIcon.tag = eCloseIconTag;
        [closeIcon setImage:[UIImage imageNamed:@"closeIcon"] forState:UIControlStateNormal];
        [closeIcon addTarget:self action:@selector(doClose:) forControlEvents:UIControlEventTouchUpInside];
        
        [viewParent addSubview:closeIcon];
    }
    closeIcon.frame = CGRectMake(viewParent.width-20, 0, 20, 20);
    
    // =======================================================================
    // 分割线
    // =======================================================================
    UIView *topLine = (UIView *)[viewParent viewWithTag:eSepartorLineTag];
    
    if (topLine == nil)
    {
        topLine = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(0, viewParent.height-1, viewParent.width, 0.5)];
        topLine.tag = eSepartorLineTag;
        
        [viewParent addSubview:topLine];
    }
    
}

- (void)doSelect:(CustomButton *)sender
{
    StudentInfo *info = sender.customInfo;
    
    if (info.status)
    {
        info.status = NO;
        [sender setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];

    }
    else
    {
        info.status = YES;
        [sender setImage:[UIImage imageNamed:@"protocolSelect"] forState:UIControlStateNormal];

    }
}

- (void)doSubmitAction
{
    _delegate.studentList = _studentList;
    [_delegate refreshPage];
    
    [self removeFromSuperview];    
}

@end
