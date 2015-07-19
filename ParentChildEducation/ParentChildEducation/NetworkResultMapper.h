//
//  NetworkResultMapper.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

@interface NetworkResultMapper : NSObject

@property (nonatomic, strong) NSDictionary *dictionaryMapper;	// 对照表

// 根据配置文件，获取Class中某个复合变量的数据Type
+ (NSString *)getVarTypeByVar:(NSString *)varName fromClass:(NSString *)className;


@end
