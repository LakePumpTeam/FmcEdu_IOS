//
//  IBLTopTabView.h
//  ibilling
//
//  Created by 张兰 on 14-3-21.
//  Copyright (c) 2014年 Asiainfo-Linkage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBLButtonForTopbar.h"

@protocol IBLTopTabViewDelegate;

@interface IBLTopTabView : UIView

@property(strong, nonatomic) id <IBLTopTabViewDelegate> delegate;
@property(assign, nonatomic) NSInteger count;
@property(strong, nonatomic) NSMutableArray *btnArr;
@property(strong, nonatomic) NSString *type;

- (id)initWithFrame:(CGRect)frame titles:(NSArray *)titles type:(NSString *) type;
@end

@protocol IBLTopTabViewDelegate <NSObject>

-(void)iBLTopTabSelect:(IBLButtonForTopbar * )btn tabView:(IBLTopTabView*) tabView;

@end
