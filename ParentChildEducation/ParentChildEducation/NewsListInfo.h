//
//  NewsListInfo.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/23.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsListInfo : NSObject

@property (nonatomic, strong) NSNumber *newsId;
@property (nonatomic, strong, getter=newsTitle) NSString *subject;
@property (nonatomic, strong, getter=newsDate) NSString *createDate;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSNumber *like;               // 点赞数
@property (nonatomic, strong) NSNumber *author;             // 发布人id
@property (nonatomic, strong) NSMutableArray *imageUrls;    // 图片url
@property (nonatomic, strong) NSNumber *commentCount;       // 评论数

@property (nonatomic, strong) NSMutableArray *commentList;  // 评论列表

@end
