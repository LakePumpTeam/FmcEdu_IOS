//
//  DataController.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/10.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "DataController.h"

// 全局数据控制器
static DataController *globalDataController = nil;

@implementation DataController

// 获取数据管理的控制器
+ (DataController *)getInstance
{
    @synchronized(self)
    {
        // 实例对象只分配一次
        if(globalDataController == nil)
        {
            globalDataController = [[super allocWithZone:NULL] init];
            
        }
    }
    
    return globalDataController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

// =======================================================================
// 保存数据
// =======================================================================

// 保存头像
- (void)savePhotoData:(NSMutableArray *)photoArray
{
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *stringFileName = [stringPath stringByAppendingPathComponent: kMyPhotoFile];
    
    if(![NSKeyedArchiver archiveRootObject: photoArray toFile: stringFileName])
    {
        NSLog(@"-------------testNSKeyedArchiver error");
    }
    // archive successfully
    else
    {
        NSLog(@"-----------%@", stringFileName);
    }
}

// 获取头像
- (NSMutableArray *)getPhotoData
{
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *stringFileName = [stringPath stringByAppendingPathComponent: kMyPhotoFile];
    
    NSMutableArray *photoArray = [NSKeyedUnarchiver unarchiveObjectWithFile: stringFileName];

    return photoArray;
}

// =======================================================================
// 用户登录信息
// =======================================================================
- (void)saveUserLoginInfo:(NSMutableDictionary *)userLoginInfoDic
{
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *stringFileName = [stringPath stringByAppendingPathComponent: kUserLoginInfo];
    
    if(![NSKeyedArchiver archiveRootObject: userLoginInfoDic toFile: stringFileName])
    {
        NSLog(@"-------------testNSKeyedArchiver error");
    }
    // archive successfully
    else
    {
        NSLog(@"-----------%@", stringFileName);
    }

}
- (NSMutableDictionary *)getUserLoginInfo;
{
    NSString *stringPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *stringFileName = [stringPath stringByAppendingPathComponent: kUserLoginInfo];
    
    NSMutableDictionary *userLoginInfo = [NSKeyedUnarchiver unarchiveObjectWithFile: stringFileName];
    
    return userLoginInfo;
}

@end
