//
//  ParentDetailView.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/16.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParentRelateInfoResult.h"

@interface ParentDetailView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, strong) ParentRelateInfoResult *parentInfo;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIView *suspendView;
@property (nonatomic, strong) UIScrollView *scrollView;

- (id)initWithParentInfo:(ParentRelateInfoResult *)parentInfo;

@end
