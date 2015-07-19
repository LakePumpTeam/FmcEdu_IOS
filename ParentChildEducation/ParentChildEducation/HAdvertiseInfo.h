//
//  AdvertiseInfo.h
//  Hotel
//
//  Created by zlan.zhang on 14-7-30.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAdvertiseInfo : NSObject

@property (nonatomic, strong, readonly, getter = imgUrl) NSString *imgUrl;	// 酒店红包红包活动Touch页
@property (nonatomic, strong, readonly, getter = schemaUrl) NSString *schemaUrl;	// 酒店红包红包活动Touch页

@end
