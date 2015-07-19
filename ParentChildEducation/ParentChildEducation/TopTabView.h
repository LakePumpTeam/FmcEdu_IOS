//
//  IBLTopTabView.h
//  ibilling
//
//  Created by 张兰 on 14-3-21.
//  Copyright (c) 2014年 Asiainfo-Linkage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopBarButton.h"

@protocol TopTabViewDelegate;

@interface TopTabView : UIView

@property(strong, nonatomic) id <TopTabViewDelegate> delegate;
@property(assign, nonatomic) NSInteger count;
@property(strong, nonatomic) NSMutableArray *btnArr;
@property(strong, nonatomic) NSString *type;

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles type:(NSString *) type;
@end

@protocol TopTabViewDelegate <NSObject>

-(void)topTabSelect:(TopBarButton * )btn tabView:(TopTabView*) tabView;

@end
