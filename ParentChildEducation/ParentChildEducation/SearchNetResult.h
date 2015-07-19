//
//  SearchNetResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

@interface SearchNetResult : NSObject

@property (nonatomic, strong, readonly, getter = returnCode) NSNumber *status;            // 返回代码
@property (nonatomic, strong, readonly, getter = returnMsg) NSString *msg;              // 提示信息

// 解析所有数据
- (void)parseAllNetResult:(NSDictionary *)jsonDictionary forInfo:(id)customInfo;

- (void)parseNetResult:(NSDictionary *)jsonDictionary forInfo:(id)customInfo;

@end
