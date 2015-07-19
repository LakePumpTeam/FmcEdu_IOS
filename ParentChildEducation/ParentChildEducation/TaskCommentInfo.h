//
//  TaskCommentInfo.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/14.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskCommentInfo : NSObject

@property (nonatomic, strong) NSNumber *commentId;
@property (nonatomic, strong) NSNumber *userId;             // 评论人Id
@property (nonatomic, strong) NSNumber *sex;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *relationship;

@end
