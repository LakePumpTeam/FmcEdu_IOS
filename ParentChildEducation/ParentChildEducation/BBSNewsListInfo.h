//
//  BBSNewsListInfo.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSNewsListInfo : NSObject

@property (nonatomic, strong) NSNumber *newsId;
@property (nonatomic, strong) NSMutableArray *imageUrls;    // 图片url
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *popular;            // 热门标签标识，bool
@property (nonatomic, strong) NSNumber *participationCount; // 参与数

@property (nonatomic, strong, getter=newsTitle) NSString *subject;
@property (nonatomic, strong, getter=newsDate) NSString *createDate;
@property (nonatomic, strong, getter=newsContent) NSString *content;

@end
