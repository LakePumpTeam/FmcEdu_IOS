//
//  TeacherInfoResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/16.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"
//  teacherName teacherBirth cellPhone resume

@interface TeacherInfoResult : SearchNetResult

@property (nonatomic, strong) NSString *teacherName;
@property (nonatomic, strong) NSNumber *teacherSex;
@property (nonatomic, strong) NSString *teacherBirth;
@property (nonatomic, strong) NSString *cellPhone;
@property (nonatomic, strong) NSString *course;
@property (nonatomic, strong) NSString *resume;

@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
