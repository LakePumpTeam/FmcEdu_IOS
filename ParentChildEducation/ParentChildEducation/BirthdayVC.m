//
//  BirthdayVC.m
//  QunariPhone
//
//  Created by mt on 13-1-14.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "BirthdayVC.h"

// ==================================================================
// 布局参数
// ==================================================================
// 控件高宽
#define	kBirthdayToolBarHeight					44
#define kBirthdayDatePickerHeight				216

@interface BirthdayVC ()

@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation BirthdayVC

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.view setBackgroundColor:[UIColor clearColor]];
	
	// 创建Root View的子视图
	[self setupViewRootSubs:[self view]];
}

#pragma mark - 布局函数
// =======================================================================
// 布局函数
// =======================================================================
// 创建Root View的子界面
- (void)setupViewRootSubs:(UIView *)viewParent
{
	// 父窗口尺寸
	CGRect parentFrame = [viewParent frame];
	
	UIView *pickBGView = [[UIView alloc] initWithFrame:CGRectMake(0, (NSInteger)(parentFrame.size.height - kBirthdayDatePickerHeight - kBirthdayToolBarHeight),
																 parentFrame.size.width, kBirthdayDatePickerHeight + kBirthdayToolBarHeight)];
	[pickBGView setBackgroundColor:[UIColor whiteColor]];
	[viewParent addSubview:pickBGView];
	
	// 子窗口高宽
	NSInteger spaceYEnd = pickBGView.frame.size.height;
	
	// =======================================================================
	// 时间选择器
	// =======================================================================
	_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	[_datePicker setFrame:CGRectMake(0, (NSInteger)(spaceYEnd - kBirthdayDatePickerHeight),
									 parentFrame.size.width, kBirthdayDatePickerHeight)];
    
    // DatePicker的日历
    NSCalendar *calendarCur = [NSCalendar defaultCalendar];
    [_datePicker setCalendar:calendarCur];
    
    // DatePicker的格式
    NSLocale * gregorianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [_datePicker setLocale:gregorianLocale];
    
	[_datePicker setDatePickerMode:UIDatePickerModeDate];
    if(_curValidDate != nil)
    {
        [_datePicker setDate:_curValidDate];
    }
	[_datePicker setMinimumDate:_minValidDate];
	[_datePicker setMaximumDate:_maxValidDate];
	
	// 添加到父窗口
	[pickBGView addSubview:_datePicker];
	
	spaceYEnd -= kBirthdayDatePickerHeight;
	
	// =======================================================================
	// toolBar
	// =======================================================================
	// 创建Toolbar
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
	[toolbar setFrame:CGRectMake(0, spaceYEnd - kBirthdayToolBarHeight, parentFrame.size.width, kBirthdayToolBarHeight)];
	
	// 创建Toolbar子界面
	[self setupToolbarSubs:toolbar];
	
	// 添加到父窗口
	[pickBGView addSubview:toolbar];
}

// 创建ToolBar的子界面
- (void)setupToolbarSubs:(UIToolbar *)viewParent
{
	// =======================================================================
	// Item数组
	// =======================================================================
	NSMutableArray *arrayItems = [[NSMutableArray alloc] init];
	
	// 取消Item
	UIBarButtonItem *barButtonCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消"
																		style:UIBarButtonItemStyleBordered
																	   target:self
																	   action:@selector(doCancel:)];
	[arrayItems addObject:barButtonCancel];
	
	// 占位Item1
	UIBarButtonItem *barButtonSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					target:self
																					action:nil];
	[arrayItems addObject:barButtonSpace];
	
	// 选择Item
	UIBarButtonItem *barButtonConfirm = [[UIBarButtonItem alloc] initWithTitle:@"确定"
																		 style:UIBarButtonItemStyleBordered
																		target:self
																		action:@selector(doConfirm:)];
	[arrayItems addObject:barButtonConfirm];
	
	// 添加到父窗口中
	[viewParent setItems:arrayItems animated:YES];
}

#pragma mark - 事件处理函数
// =======================================================================
// 事件处理函数
// =======================================================================
// 选择时间
- (void)doConfirm:(id)sender
{
    if((_delegate != nil) && ([_delegate respondsToSelector:@selector(BirthdayVCBack:withInfo:)] == YES))
    {
        [_delegate BirthdayVCBack:[_datePicker date] withInfo:_delgtInfo];
    }
	
	[self.view removeFromSuperview];
}

// 取消选择
- (void)doCancel:(id)sender
{
	[self.view removeFromSuperview];
}


@end
