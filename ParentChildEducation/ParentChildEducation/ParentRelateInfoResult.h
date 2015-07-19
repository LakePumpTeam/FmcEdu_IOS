//
//  ParentRelateInfoResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/15.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface ParentRelateInfoResult : SearchNetResult

@property (nonatomic, strong) NSString *cellPhone;

@property (nonatomic, strong) NSNumber *provId;
@property (nonatomic, strong) NSString *provName;

@property (nonatomic, strong) NSNumber *cityId;
@property (nonatomic, strong) NSString *cityName;

@property (nonatomic, strong) NSNumber *schoolId;
@property (nonatomic, strong) NSString *schoolName;

@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, strong) NSString *className;

@property (nonatomic, strong) NSNumber *teacherId;
@property (nonatomic, strong) NSString *teacherName;

@property (nonatomic, strong) NSString *studentName;
@property (nonatomic, strong) NSNumber *studentSex;
@property (nonatomic, strong) NSString *studentBirth;
@property (nonatomic, strong) NSString *parentName;
@property (nonatomic, strong) NSString *relation;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *braceletCardNumber;
@property (nonatomic, strong) NSString *braceletNumber;

// 修改接口新增
@property (nonatomic, strong) NSNumber *parentId;
@property (nonatomic, strong) NSNumber *studentId;
@property (nonatomic, strong) NSNumber *addressId;

@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
