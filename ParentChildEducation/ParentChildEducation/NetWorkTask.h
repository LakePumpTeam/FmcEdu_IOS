//
//  NetWorkTask.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/9.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchNetResult.h"
//#import "NetworkPtc.h"

@protocol NetworkPtc <NSObject>

@optional

// 获取网络请求回调
- (void)getSearchNetBack:(SearchNetResult *)searchResult forInfo:(id)customInfo;

// 获取网络请求失败回调
- (void)getSearchNetBackWithFailure:(id)customInfo;

@end

@interface NetWorkTask : NSObject

/*!
 *  网络请求
 *
 *  @param service      接口名
 *  @param paramDic     参数
 *  @param searchResult 结果集
 *  @param delegate     回调delegate
 *  @param customInfo   自定义信息
 */
+ (void)postRequest:(NSString *)service
        forParamDic:(NSDictionary *)paramDic
       searchResult:(SearchNetResult *)searchResult
        andDelegate:(id <NetworkPtc>)delegate
            forInfo:(id)customInfo;

/*!
 *  网络请求
 *
 *  @param service      接口名
 *  @param paramDic     参数
 *  @param searchResult 结果集
 *  @param delegate     回调delegate
 *  @param customInfo   自定义信息
 *  @param isMockData   是否mock数据

 */
+ (void)postRequest:(NSString *)service forParamDic:(NSDictionary *)paramDic searchResult:(SearchNetResult *)searchResult andDelegate:(__weak id <NetworkPtc>)delegate forInfo:(id)customInfo isMockData:(BOOL)isMockData;


+ (void)postRequestWithArray:(NSString *)service forParamDic:(NSDictionary *)paramDic searchResult:(SearchNetResult *)searchResult andDelegate:(__weak id <NetworkPtc>)delegate forArray:(NSMutableArray *)array forInfo:(id)customInfo;

/*!
 *  图片上传
 *
 *  @param service      接口名
 *  @param paramDic     参数
 *  @param searchResult 结果集
 *  @param delegate     回调delegate
 *  @param imageInfo    图片数据
 *  @param customInfo   自定义信息
 */
+ (void)postRequestAndUploadData:(NSString *)service
                     forParamDic:(NSDictionary *)paramDic
                    searchResult:(SearchNetResult *)searchResult
                     andDelegate:(__weak id <NetworkPtc>)delegate
                    forImageInfo:(NSMutableArray *)imageInfo
                         forInfo:(id)customInfo;

@end
