//
//  YcKeyBoardView.h
//  KeyBoardAndTextView
//
//  Created by zzy on 14-5-28.
//  Copyright (c) 2014年 zzy. All rights reserved.
//
#define kStartLocation 20
#import <UIKit/UIKit.h>
#import "GCPlaceholderTextView.h"

@class CustomKeyBoardView;
@protocol CustomKeyBoardViewDelegate <NSObject>

-(void)keyBoardViewHide:(UITextView *)keyBoardView content:(NSString *)content newsId:(NSNumber *)newsId;

@optional

// 发表点评
- (void)publishComment:(UITextView *)keyBoardView newsId:(NSNumber *)newsId content:(NSString *)content;

- (void)customTextViewDidBeginEditing:(UITextView *)textView;

- (BOOL)customTextViewShouldReturn:(UITextView *)textView;

@end

@interface CustomKeyBoardView : UIView

@property (nonatomic,strong) GCPlaceholderTextView *textView;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) NSNumber *newsId;

@property (nonatomic, assign) NSInteger maxWords;  // 最大输入字数

@property (nonatomic,assign) id<CustomKeyBoardViewDelegate> delegate;

@end
