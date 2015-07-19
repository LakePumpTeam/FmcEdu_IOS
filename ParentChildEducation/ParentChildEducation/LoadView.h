//
//  LoadView.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/1.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIView *suspendView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (id)initWithFrame:(CGRect)frame;

- (void)startLoadingView;

- (void)stopLoadingView;

@end
