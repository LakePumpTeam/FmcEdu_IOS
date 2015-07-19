//
//  AlterAssociatedInforVC.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/17.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "BaseNameVC.h"

typedef NS_ENUM(NSInteger, FromType)
{
    eFromAppDelegate = 1,      // 首页修改信息
    eFromHomePage              // 审核失败、直接进入修改
};


@interface AlterAssociatedInforVC : BaseNameVC

@property (nonatomic, strong) NSNumber *userId;                 // 登录者id
@property (nonatomic, strong) NSString *parentCellPhone;
@property (nonatomic, assign) FromType fromType;

@end
