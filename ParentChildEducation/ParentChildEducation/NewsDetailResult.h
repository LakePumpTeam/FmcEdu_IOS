//
//  NewsDetailResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/23.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

//    newsId
//    subject
//    content
//    imageUrl
//    createDate
//    like
//    liked
//commentList: [
//              userId
//              userName
//              comment
//              ]

@interface NewsDetailResult : SearchNetResult

@property (nonatomic, strong) NSNumber *newsId;

@property (nonatomic, strong, getter=newsTitle) NSString *subject;
@property (nonatomic, strong, getter=newsDate) NSString *createDate;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSMutableArray *imageUrls;                  // 图片url
@property (nonatomic, strong) NSNumber *like;                            // 点赞数量
@property (nonatomic, strong) NSNumber *liked;                           // 点赞状态

@property (nonatomic, strong) NSMutableArray *commentList;               // 点评列表
@property (nonatomic, strong) NSNumber *participationCount;              // 点评总数
@property (nonatomic, strong) NSNumber *isSuccess;                       // (1:成功 其他不成功）
@property (nonatomic, strong) NSString *businessMsg;

@end
