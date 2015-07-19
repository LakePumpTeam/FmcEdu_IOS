//
//  IBLButtonForTopbar.h
//  ibilling
//
//  Created by 张兰 on 14-3-21.
//  Copyright (c) 2014年 Asiainfo-Linkage. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopBarButton : UIButton

- (id)initWithFrame:(CGRect)frame title:(NSString*)title ;
- (id)initWithFrameTop:(CGRect)frame title:(NSString*)title ;

@property(assign,nonatomic) int type;

// 分割线
@property (nonatomic, strong) UIView *lineView;

@end
