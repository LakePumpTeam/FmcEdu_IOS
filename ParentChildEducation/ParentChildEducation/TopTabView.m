//
//  IBLTopTabView.m
//  ibilling
//
//  Created by 张兰 on 14-3-21.
//  Copyright (c) 2014年 Asiainfo-Linkage. All rights reserved.
//

#import "TopTabView.h"
#import "TopBarButton.h"

@implementation TopTabView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {

    }
    return self;
}
- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles type:(NSString*)type
{
    self = [super initWithFrame:frame];
    self.type = type ;//bar 类型
    _btnArr = [[NSMutableArray alloc] init ] ;
    int btnHeight = frame.size.height;
    self.count = titles.count ;
    float btnWidth = (float)frame.size.width/self.count;
    
    if (self)
    {
        for (int i =0 ; i <self.count; i ++)
        {
            self.backgroundColor = [UIColor whiteColor] ;
            TopBarButton *btn ;
            if ([type isEqualToString:@"top" ])
            {
                btn = [[TopBarButton alloc] initWithFrameTop:CGRectMake(btnWidth*i, 0, btnWidth, btnHeight)  title:titles[i] ];
             } else
             {
                btn = [[TopBarButton alloc] initWithFrame:CGRectMake(btnWidth*i, 0, btnWidth-1, btnHeight)  title:titles[i] ];
             }
            [btn addTarget:self action:@selector(btnSelect:) forControlEvents:UIControlEventTouchUpInside ] ;
            
            // 第一项默认选中
            if (i == 0)
            {
                btn.selected =YES ;
                btn.lineView.backgroundColor = kBackgroundGreenColor;
            }
            [_btnArr addObject:btn ] ;
            
            btn.type = i;
            [self addSubview:btn ];
        }
        
    }
    return self ;
}

-(void) btnSelect:(id)sender
{
    TopBarButton *btnSelected = (TopBarButton *)sender;
    
    for (TopBarButton *btn in _btnArr)
    {
        if (btn.type == btnSelected.type)
        {
            btn.selected = YES;
            
            if (btn.lineView)
            {
                btn.lineView.backgroundColor = kBackgroundGreenColor;
            }

        }else
        {
            btn.selected = NO ;
            
            if (btn.lineView)
            {
                btn.lineView.backgroundColor = kWhiteColor;
            }
        }
    }
    
    if(_delegate&&[_delegate conformsToProtocol:@protocol(TopTabViewDelegate)])
    {
        [_delegate topTabSelect:btnSelected tabView:self];
    }
 }

@end
