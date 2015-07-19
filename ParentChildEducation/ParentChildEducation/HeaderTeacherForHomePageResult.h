//
//  HeaderTeacherForHomePageResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/17.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface HeaderTeacherForHomePageResult : SearchNetResult

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *teacherName;
@property (nonatomic, strong) NSNumber *teacherId;
@property (nonatomic, strong) NSNumber *userRole;
@property (nonatomic, strong) NSNumber *sex;
@property (nonatomic, strong) NSString *className;

@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
