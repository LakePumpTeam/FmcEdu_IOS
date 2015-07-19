//
//  CommentInfo.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/23.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// 点评信息

@interface CommentInfo : NSObject

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *comment;

@end
