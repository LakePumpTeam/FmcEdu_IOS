//
//  BBSNewsDetailResult.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/18.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface BBSNewsDetailResult : SearchNetResult

@property (nonatomic, strong) NSNumber *newsId;

@property (nonatomic, strong, getter=newsTitle) NSString *subject;
@property (nonatomic, strong, getter=newsDate) NSString *createDate;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSMutableArray *imageUrls;                  // 图片url

@property (nonatomic, strong) NSNumber *participationCount;              // 参与数
@property (nonatomic, strong) NSNumber *popular;                         // 热门”标志位
@property (nonatomic, strong) NSNumber *isParticipation;                 // 是否已参加评论
@property (nonatomic, strong) NSMutableArray *selections;                // 选择

@property (nonatomic, strong) NSNumber *isSuccess;                       // (1:成功 其他不成功）
@property (nonatomic, strong) NSString *businessMsg;

@end
