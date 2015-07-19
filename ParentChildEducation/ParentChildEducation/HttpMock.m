//
//  HttpMock.m
//  AFNetWorkingDemo
//
//  Created by Marshal Wu on 14-9-17.
//  Copyright (c) 2014年 Marshal Wu. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>

#import "HttpMock.h"
#import "OCFURLQuery.h"

#define LoadRequestUrl(requestService)      [NSString stringWithFormat:@"%@%@", kHostUrl, requestService]

@implementation HttpMock

+ (void)initMock
{
    // =======================================================================
    // bbs详情
    // =======================================================================
    if (kIsMock_RequestNewsDetail) {
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            
            return [[request.URL absoluteString] rangeOfString:LoadRequestUrl(kRequestNewsDetail)].location==0;
            
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSString *fixture = OHPathForFileInBundle(@"requestNewsDetail_BBS.json",[NSBundle mainBundle]);
            return [[OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                     statusCode:200 headers:@{@"Content-Type":@"text/json"}
                     ]requestTime:0 responseTime:0];
        }];
    }
    // =======================================================================
    // 任务详情
    // =======================================================================
    if (kIsMock_RequestTaskDetail) {
        
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            
            return [[request.URL absoluteString] rangeOfString:LoadRequestUrl(kRequestTaskDetail)].location==0;
            
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSString *fixture = OHPathForFileInBundle(@"requestTaskDetail.json",[NSBundle mainBundle]);
            return [[OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                     statusCode:200 headers:@{@"Content-Type":@"text/json"}
                     ]requestTime:0 responseTime:0];
        }];
    }
    // =======================================================================
    // 任务列表
    // =======================================================================
    if (kIsMock_RequestTaskList == 1)
    {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            
            return [[request.URL absoluteString] rangeOfString:LoadRequestUrl(kRequestTaskList)].location==0;
            
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSString *fixture = OHPathForFileInBundle(@"RequestTaskList.json",[NSBundle mainBundle]);
            return [[OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                     statusCode:200 headers:@{@"Content-Type":@"text/json"}
                     ]requestTime:0 responseTime:0];
        }];
    }
    // =======================================================================
    // 育儿学堂广告
    // =======================================================================
    if (kIsMock_RequestSlides == 1)
    {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            
            return [[request.URL absoluteString] rangeOfString:LoadRequestUrl(kRequestChildClassAdImages)].location==0;
            
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSString *fixture = OHPathForFileInBundle(@"RequestSlides.json",[NSBundle mainBundle]);
            return [[OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                     statusCode:200 headers:@{@"Content-Type":@"text/json"}
                     ]requestTime:0 responseTime:0];
        }];
        
    }
    
    // =======================================================================
    // 登陆
    // =======================================================================
    if (kIsMock_RequestLogin == 1)
    {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            
            return [[request.URL absoluteString] rangeOfString:LoadRequestUrl(kRequestLogin)].location==0;
            
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            
            NSString *fixture = OHPathForFileInBundle(@"RequestLogin.json",[NSBundle mainBundle]);
            return [[OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                     statusCode:200 headers:@{@"Content-Type":@"text/json"}
                     ]requestTime:0 responseTime:0];
        }];

    }
    
    // =======================================================================
    // salt请求
    // =======================================================================
    if (kIsMock_RequestLoginSalt == 1)
    {
        [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
            
            return [[request.URL absoluteString] rangeOfString:LoadRequestUrl(kRequestLoginSalt)].location==0;
            
        } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
            NSLog(@"reqeust: %@",request);
            NSString *fixture = OHPathForFileInBundle(@"RequestSalt.json",[NSBundle mainBundle]);
            return [[OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                     statusCode:200 headers:@{@"Content-Type":@"text/json"}
                     ]requestTime:0 responseTime:0];
        }];
    }
    
    // =======================================================================
    // 新闻列表
    // =======================================================================
//
//    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
//        
//        return [[request.URL absoluteString] rangeOfString:LoadRequestUrl(kRequestNewsList)].location==0;
//        
//    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
//        NSLog(@"reqeust: %@",request);
//        NSString *fixture = OHPathForFileInBundle(@"RequestNewsList.json",[NSBundle mainBundle]);
//        return [[OHHTTPStubsResponse responseWithFileAtPath:fixture
//                                                 statusCode:200 headers:@{@"Content-Type":@"text/json"}
//                 ]requestTime:0 responseTime:0];
//    }];
    
    //GET image with sdwebimage
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [[request.URL absoluteString] isEqualToString:@"http://www.sogou.com/images/logo/new/sogou.png"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSLog(@"reqeust: %@",request);
        NSString* fixture = OHPathForFileInBundle(@"taobao.png",nil);
        return [[OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                 statusCode:200 headers:@{@"Content-Type":@"image/png"}
                 ]requestTime:0 responseTime:0];
    }];
    
    //GET image with afnetworking
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [[request.URL absoluteString] isEqualToString:@"http://www.baidu.com/img/bdlogo.png"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSLog(@"reqeust: %@",request);
        NSString* fixture = OHPathForFileInBundle(@"yklogo.png",nil);
        return [[OHHTTPStubsResponse responseWithFileAtPath:fixture
                                                 statusCode:200 headers:@{@"Content-Type":@"image/png"}
                 ]requestTime:0 responseTime:0];
    }];
    
}

@end
