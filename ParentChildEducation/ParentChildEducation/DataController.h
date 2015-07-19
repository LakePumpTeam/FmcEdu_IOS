//
//  DataController.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/10.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataController : NSObject

+ (DataController *)getInstance;

// =======================================================================
// 头像数据
// =======================================================================

// 保存头像
- (void)savePhotoData:(NSMutableArray *)photoArray;

// 获取头像
- (NSMutableArray *)getPhotoData;

// =======================================================================
// 用户登录信息
// =======================================================================

// kUserLoginInfo
// 保存头像
- (void)saveUserLoginInfo:(NSMutableDictionary *)userLoginInfoDic;

// 获取头像
- (NSMutableDictionary *)getUserLoginInfo;

@end
