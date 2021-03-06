//
//  NetworkResultMapper.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "NetworkResultMapper.h"

@implementation NetworkResultMapper

// 全局解析器
static NetworkResultMapper *globalNetworkParseMapper = nil;


// 根据配置文件，获取Class中某个复合变量的数据Type
+ (NSString *)getVarTypeByVar:(NSString *)varName fromClass:(NSString *)className
{
    NetworkResultMapper *networkParseMapper = [NetworkResultMapper getInstance];
    
    // 加载文件
    if([networkParseMapper dictionaryMapper] == nil)
    {
        @autoreleasepool
        {
            // 加载文件
            NSArray *arrayMapperFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"mapper" inDirectory:nil];
            
            NSMutableDictionary *networkParseMapperTmp = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            for (NSString *mapperFilePath in arrayMapperFiles)
            {
                // 该文件存在
                if([[NSFileManager defaultManager] fileExistsAtPath:mapperFilePath])
                {
                    // 加载文件中的数据
                    NSDictionary *dictionaryMapperFromFile = [[NSDictionary alloc] initWithContentsOfFile:mapperFilePath];
                    [networkParseMapperTmp addEntriesFromDictionary:dictionaryMapperFromFile];
                }
            }
            
            [networkParseMapper setDictionaryMapper:networkParseMapperTmp];
        }
    }
    
    // 查找
    NSDictionary *dictionaryMapper = [networkParseMapper dictionaryMapper];
    if(dictionaryMapper != nil)
    {
        NSArray *arrayMapperPair = [dictionaryMapper objectForKey:className];
        if(arrayMapperPair != nil)
        {
            NSInteger pairCount = [arrayMapperPair count];
            for(NSInteger i = 0; i < pairCount; i++)
            {
                NSString *pairString = [arrayMapperPair objectAtIndex:i];
                
                // 通过字符串分割key:var
                NSArray *arrayComponent = [pairString componentsSeparatedByString:@":"];
                NSInteger componentCount = [arrayComponent count];
                if(componentCount == 2)
                {
                    NSString *key = [arrayComponent objectAtIndex:1];
                    if([key isEqualToString:varName])
                    {
                        return [arrayComponent objectAtIndex:0];
                    }
                }
            }
        }
    }
    
    return nil;
}

// 实例化
+ (NetworkResultMapper *)getInstance
{
    @synchronized(self)
    {
        if(globalNetworkParseMapper == nil)
        {
            globalNetworkParseMapper = [[super allocWithZone:NULL] init];
            
            // 初始化
            [globalNetworkParseMapper setDictionaryMapper:nil];
        }
    }
    
    return globalNetworkParseMapper;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self getInstance];
}

@end