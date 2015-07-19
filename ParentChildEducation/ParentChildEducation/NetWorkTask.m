//
//  NetWorkTask.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/9.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "NetWorkTask.h"
#import "HDetailPictureInfo.h"

@implementation NetWorkTask

+ (void)postRequest:(NSString *)service forParamDic:(NSDictionary *)paramDic searchResult:(SearchNetResult *)searchResult andDelegate:(__weak id <NetworkPtc>)delegate forInfo:(id)customInfo;
{
    // =======================================================================
    // 地址
    // =======================================================================
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kHostUrl, service];
    
    // 打印请求参数
    NSString *jsonString = [paramDic JSONString];
    
    // =======================================================================
    // 请求
    // =======================================================================
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:urlString
       parameters:paramDic
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // 成功
              if (responseObject != nil)
              {
                  NSData *responseData = responseObject;
                  
                  NSString *returnJsonString = [[NSString alloc] initWithData:responseData  encoding:NSUTF8StringEncoding];
                  
                  
                  // 解码
                  returnJsonString = [returnJsonString base64DecodedString];
                  
                  NSLog(@"*****************接口：%@*****************入参：%@*****************success出参：%@*****************", urlString, jsonString, returnJsonString);
                  
                  // 解析
                  if ([returnJsonString isStringSafe]) {
                      NSDictionary *jsonDictionary = [returnJsonString objectFromJSONString];
                      
                      [searchResult parseAllNetResult:jsonDictionary forInfo:nil];
                  }
                  
                  // 成功回调
                  if((delegate != nil) && ([delegate respondsToSelector:@selector(getSearchNetBack: forInfo:)] == YES))
                  {
                      [delegate getSearchNetBack:searchResult forInfo:customInfo];
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"*****************接口：%@*****************入参：%@*****************fail出参：%@*****************", urlString, jsonString, error.localizedDescription);
              
              // 失败回调
              if((delegate != nil) && ([delegate respondsToSelector:@selector(getSearchNetBackWithFailure:)] == YES))
              {
                  [delegate getSearchNetBackWithFailure:error];
              }
              
          }];
}

// 是否mock数据的请求
+ (void)postRequest:(NSString *)service forParamDic:(NSDictionary *)paramDic searchResult:(SearchNetResult *)searchResult andDelegate:(__weak id <NetworkPtc>)delegate forInfo:(id)customInfo isMockData:(BOOL)isMockData;
{
    // =======================================================================
    // 地址
    // =======================================================================
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kHostUrl, service];
    //    NSLog(@"================环境：%@================\r\r", urlString);
    
    
    // 打印请求参数
    NSString *jsonString = [paramDic JSONString];
    //    NSLog(@"================接口：%@================\r\r", customInfo);
    //    NSLog(@"================入参：%@================\r\r", jsonString);
    
    // =======================================================================
    // 请求
    // =======================================================================
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:urlString
       parameters:paramDic
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              // 成功
              if (responseObject != nil)
              {
                  NSData *responseData = responseObject;
                  
                  NSString *returnJsonString = [[NSString alloc] initWithData:responseData  encoding:NSUTF8StringEncoding];
                  
                  // 正式数据
                  if (isMockData == 0)
                  {
                      // 解码
                      returnJsonString = [returnJsonString base64DecodedString];
                  }
                  
                  NSLog(@"*****************接口：%@*****************入参：%@*****************success出参：%@*****************", urlString, jsonString, returnJsonString);
                  
                  // 解析
                  if ([returnJsonString isStringSafe]) {
                      NSDictionary *jsonDictionary = [returnJsonString objectFromJSONString];
                      
                      [searchResult parseAllNetResult:jsonDictionary forInfo:nil];
                  }
                  
                  // 成功回调
                  if((delegate != nil) && ([delegate respondsToSelector:@selector(getSearchNetBack: forInfo:)] == YES))
                  {
                      [delegate getSearchNetBack:searchResult forInfo:customInfo];
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              NSLog(@"*****************接口：%@*****************入参：%@*****************fail出参：%@*****************", urlString, jsonString, error.localizedDescription);

              // 失败回调
              if((delegate != nil) && ([delegate respondsToSelector:@selector(getSearchNetBackWithFailure:)] == YES))
              {
                  [delegate getSearchNetBackWithFailure:error];
              }
              
          }];
}

// 参数含数组
+ (void)postRequestWithArray:(NSString *)service forParamDic:(NSDictionary *)paramDic searchResult:(SearchNetResult *)searchResult andDelegate:(__weak id <NetworkPtc>)delegate forArray:(NSMutableArray *)array forInfo:(id)customInfo;
{
    // =======================================================================
    // 打印请求参数
    // =======================================================================
    NSString *jsonString = [paramDic JSONString];
    NSLog(@"\r\r=========接口：%@==================\r请求参数：JSON: %@=============================================\r\r", customInfo, jsonString);
    
    // =======================================================================
    // 地址
    // =======================================================================
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kHostUrl, service];
    NSLog(@"==================\r请求地址: %@=============================================\r\r", urlString);
    
    // =======================================================================
    // 请求
    // =======================================================================
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:urlString parameters:paramDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
       
//        for (int i = 0; i<array.count; i++)
//        {
//            NSData *data = [array[i] dataUsingEncoding:NSASCIIStringEncoding];
//            
////            [NSData dataWithBase64EncodedString:stuId.stringValue];
//            [formData appendPartWithFormData:data name:@"students"];
//
//            //            [formData appendPartWithFileData:data name:@"students" fileName:@"students" mimeType:@" "];
//
//        }
        
        for (int i = 0; i<array.count; i++)
        {
            NSData *jsonData = [base64Encode([array[i] stringValue]) dataUsingEncoding:NSUTF8StringEncoding];
            [formData appendPartWithFormData:jsonData name:@"students"];
        }
       
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // =======================================================================
        // 请求成功
        // =======================================================================
        if (responseObject != nil)
        {
            NSData *responseData = responseObject;
            NSString *jsonString = [[NSString alloc] initWithData:responseData  encoding:NSUTF8StringEncoding];
            // 解码
            jsonString = [jsonString base64DecodedString];
            
            NSLog(@"\r\r=========请求成功,接口名：%@==================\r\r JSON: %@=============================================\r\r", customInfo, jsonString);
            
            // 解析
            if ([jsonString isStringSafe]) {
                NSDictionary *jsonDictionary = [jsonString objectFromJSONString];
                
                [searchResult parseAllNetResult:jsonDictionary forInfo:nil];
            }
            
            // =======================================================================
            // 成功回调
            // =======================================================================
            if((delegate != nil) && ([delegate respondsToSelector:@selector(getSearchNetBack: forInfo:)] == YES))
            {
                [delegate getSearchNetBack:searchResult forInfo:customInfo];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // =======================================================================
        // 失败
        // =======================================================================
        NSLog(@"\r\r=========请求失败,接口名：%@==================\r\r Error: %@=============================================\r\r", customInfo, error.localizedDescription);
        
        // =======================================================================
        // 失败回调
        // =======================================================================
        if((delegate != nil) && ([delegate respondsToSelector:@selector(getSearchNetBackWithFailure:)] == YES))
        {
            [delegate getSearchNetBackWithFailure:error];
        }
    }];
}

// 上传图片
+ (void)postRequestAndUploadData:(NSString *)service forParamDic:(NSDictionary *)paramDic searchResult:(SearchNetResult *)searchResult andDelegate:(__weak id <NetworkPtc>)delegate forImageInfo:(NSMutableArray *)imageInfo forInfo:(id)customInfo;
{
    // =======================================================================
    // 打印请求参数
    // =======================================================================
    NSString *jsonString = [paramDic JSONString];
    NSLog(@"\r\r=========接口：%@==================\r请求参数：JSON: %@=============================================\r\r", customInfo, jsonString);
    
    // =======================================================================
    // 地址
    // =======================================================================
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kHostUrl, service];
    NSLog(@"==================\r请求地址: %@=============================================\r\r", urlString);
    
    // =======================================================================
    // 请求
    // =======================================================================
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:urlString parameters:paramDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // =======================================================================
        // 转换图片数据：最大尺寸800、压缩系数0.5
        // =======================================================================
        for (int i = 0; i<imageInfo.count; i++)
        {
            HDetailPictureInfo *picInfo = imageInfo[i];
            
            UIImage *image = [UIImage imageWithCGImage:[[picInfo.asset defaultRepresentation] fullResolutionImage]
                                                 scale:1.0f
                                           orientation:(UIImageOrientation)[[picInfo.asset defaultRepresentation] orientation]];
            
            //            UIImage *reSizeImage = [image imageWithMaxLength:800];
            
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5f) name:@"imgs" fileName:@"imgs" mimeType:@" "];
            
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // =======================================================================
        // 请求成功
        // =======================================================================
        if (responseObject != nil)
        {
            NSData *responseData = responseObject;
            NSString *jsonString = [[NSString alloc] initWithData:responseData  encoding:NSUTF8StringEncoding];
            // 解码
            jsonString = [jsonString base64DecodedString];
            
            NSLog(@"\r\r=========请求成功,接口名：%@==================\r\r JSON: %@=============================================\r\r", customInfo, jsonString);
            
            // 解析
            if ([jsonString isStringSafe]) {
                NSDictionary *jsonDictionary = [jsonString objectFromJSONString];
                
                [searchResult parseAllNetResult:jsonDictionary forInfo:nil];
            }
            
            // =======================================================================
            // 成功回调
            // =======================================================================
            if((delegate != nil) && ([delegate respondsToSelector:@selector(getSearchNetBack: forInfo:)] == YES))
            {
                [delegate getSearchNetBack:searchResult forInfo:customInfo];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // =======================================================================
        // 失败
        // =======================================================================
        NSLog(@"\r\r=========请求失败,接口名：%@==================\r\r Error: %@=============================================\r\r", customInfo, error.localizedDescription);
        
        // =======================================================================
        // 失败回调
        // =======================================================================
        if((delegate != nil) && ([delegate respondsToSelector:@selector(getSearchNetBackWithFailure:)] == YES))
        {
            [delegate getSearchNetBackWithFailure:error];
        }
    }];
}



@end
