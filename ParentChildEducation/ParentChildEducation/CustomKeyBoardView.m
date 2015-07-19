//
//  YcKeyBoardView.m
//  KeyBoardAndTextView
//
//  Created by zzy on 14-5-28.
//  Copyright (c) 2014年 zzy. All rights reserved.
//

#import "CustomKeyBoardView.h"

@interface CustomKeyBoardView()<UITextViewDelegate>

@property (nonatomic,assign) CGFloat textViewWidth;
@property (nonatomic,assign) BOOL isChange;
@property (nonatomic,assign) BOOL reduce;
@property (nonatomic,assign) CGRect originalKey;
@property (nonatomic,assign) CGRect originalText;

@property (nonatomic, assign) CGFloat buttonWidth;

@end

@implementation CustomKeyBoardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kBackgroundColor;
        _buttonWidth = 80;
        
        // 默认100
        _maxWords = 100;
        
        [self initTextView:frame];
    }
    return self;
}
-(void)initTextView:(CGRect)frame
{
    NSInteger spaceYStart = 4;
    NSInteger spaceXStart = 10;
    
    _textView = [[GCPlaceholderTextView alloc]init];
   _textView.delegate = self;

    self.textViewWidth = frame.size.width - 2*spaceXStart - _buttonWidth - 5;
    _textView.frame = CGRectMake(spaceXStart, spaceYStart,self.textViewWidth , frame.size.height-2*spaceYStart);
    _textView.backgroundColor = kWhiteColor;
    _textView.font = kMiddleFont;
    _textView.textColor = kTextColor;
    
    _textView.layer.borderColor = kSepartorLineColor.CGColor;
    _textView.layer.borderWidth = 0.5;
    
    [self addSubview:_textView];
    
    _commentButton = [[UIButton alloc] initWithFont:kMiddleFont andTitle:@"发表评论" andTtitleColor:kTextColor andCornerRadius:20];
    _commentButton.backgroundColor = kBackgroundGreenColor;
    [_commentButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    _commentButton.frame = CGRectMake(_textView.right+5, spaceYStart, _buttonWidth, _textView.height);
    [_commentButton addTarget:self action:@selector(doCommentAciton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_commentButton];
}

- (void)doCommentAciton:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(publishComment:newsId:content:)]) {
        [_delegate publishComment:_textView newsId:_newsId content:_textView.text];
    }
}

- (BOOL)textView:(GCPlaceholderTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    //删除退格按钮
    if (text.length == 0) {
        return YES;
    }
    
    if ([text isEqualToString:@"\n"]){
        
        if([self.delegate respondsToSelector:@selector(keyBoardViewHide:content:newsId:)]){
        
            [self.delegate keyBoardViewHide:_textView content:_textView.text newsId:_newsId];
        }
        return NO;
    }
    
    // 限制输入字数
    return [textView shouldChangeInRange:range withString:text andLength:_maxWords];
    
}
-(void)textViewDidChange:(UITextView *)textView
{
      NSString *content=textView.text;
    
      CGSize contentSize=[content sizeWithFontCompatible:[UIFont systemFontOfSize:20.0]];
      if(contentSize.width>self.textViewWidth){
          
          if(!self.isChange){
              
              CGRect keyFrame=self.frame;
              self.originalKey=keyFrame;
              keyFrame.size.height+=keyFrame.size.height;
              keyFrame.origin.y-=keyFrame.size.height*0.25;
              self.frame=keyFrame;
              
              CGRect textFrame=self.textView.frame;
              self.originalText=textFrame;
              textFrame.size.height+=textFrame.size.height*0.5+kStartLocation*0.2;
              self.textView.frame=textFrame;
              self.isChange=YES;
              self.reduce=YES;
            }
      }
    
    if(contentSize.width<=self.textViewWidth){
        
        if(self.reduce){
            
            self.frame=self.originalKey;
            self.textView.frame=self.originalText;
            self.isChange=NO;
            self.reduce=NO;
       }
    }
}

#pragma mark - 解决键盘遮挡问题

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(customTextViewDidBeginEditing:)])
    {
        [_delegate customTextViewDidBeginEditing:textView];
    }
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    if (_delegate && [_delegate respondsToSelector:@selector(customTextFieldShouldReturn:)])
//    {
//        return [_delegate customTextFieldShouldReturn:textField];
//    }
//    
//    return YES;
//}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (_delegate && [_delegate respondsToSelector:@selector(customTextViewShouldReturn:)])
    {
        return [_delegate customTextViewShouldReturn:textView];
    }
    
    return YES;
}

@end
