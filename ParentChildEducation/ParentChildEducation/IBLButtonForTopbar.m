//
//  IBLButtonForTopbar.m
//  ibilling
//
//  Created by 张兰 on 14-3-21.
//  Copyright (c) 2014年 Asiainfo-Linkage. All rights reserved.
//

#import "IBLButtonForTopbar.h"

@implementation IBLButtonForTopbar

//本月／上月／上上月
- (id)initWithFrame:(CGRect)frame title:(NSString*)title
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundImage:[UIImage imageNamed:@"未选中new"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"选中NEw"] forState:UIControlStateSelected];
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
    return self;
}

//顶部
- (id)initWithFrameTop:(CGRect)frame title:(NSString*)title
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self setTitleColor:kBackgroundGreenColor forState:UIControlStateSelected];
        self.adjustsImageWhenHighlighted = FALSE;
 
        [self setBackgroundColor:kWhiteColor];
        
        // 分割线
        UIView *lineView = [[UIView alloc] initSepartorViewWithFrame:CGRectMake(20, self.height-1, self.width-40, 1)];
        lineView.backgroundColor = kWhiteColor;

        _lineView = lineView;
        [self addSubview:lineView];
     }
    
    return self;
}


@end
