//
//  HeadTeacherResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/14.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

//headTeacherId  班主任id
//headTeacherName  班主任名字

@interface HeadTeacherResult : SearchNetResult

@property (nonatomic, strong) NSNumber *headTeacherId;
@property (nonatomic, strong) NSString *headTeacherName;

@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
