//
//  CityInfo.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/11.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityInfo : NSObject

@property (nonatomic, strong, getter = cityId) NSNumber *cityId;     // 省份id
@property (nonatomic, strong, getter = cityName) NSString *name;

@end
