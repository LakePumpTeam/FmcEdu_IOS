//
//  UITextView+Utility.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/25.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (Utility)

// 是否可以继续输入
- (BOOL)shouldChangeInRange:(NSRange)range withString:(NSString *)string andLength:(NSInteger)maxLength;

@end
