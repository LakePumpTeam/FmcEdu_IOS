//
//  ParentRelateInfoResult.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/15.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "ParentRelateInfoResult.h"

@implementation ParentRelateInfoResult

// 深拷贝
- (id)mutableCopyWithZone:(NSZone *) zone
{
    ParentRelateInfoResult *parentRelateInfoResult = [[ParentRelateInfoResult allocWithZone:zone] init];
    
    NSString *cellPhone = [_cellPhone mutableCopy];
    [parentRelateInfoResult setCellPhone:cellPhone];
    
//    NSNumber *provId = [NSNumber numberWithInteger:[_provId integerValue]];
    NSNumber *provId = [[NSNumber alloc] initWithInteger:_provId.integerValue];
    
    
    [parentRelateInfoResult setProvId:provId];
    
    NSString *provName = [_provName mutableCopy];
    [parentRelateInfoResult setProvName:provName];
    
//    NSNumber *cityId = [NSNumber numberWithInteger:[_cityId integerValue]];
    NSNumber *cityId = [[NSNumber alloc] initWithInteger:_cityId.integerValue];

    [parentRelateInfoResult setCityId:cityId];
    
    NSString *cityName = [_cityName mutableCopy];
    [parentRelateInfoResult setCityName:cityName];

//    NSNumber *schoolId = [NSNumber numberWithInteger:[_schoolId integerValue]];
    NSNumber *schoolId = [[NSNumber alloc] initWithInteger:_schoolId.integerValue];

    [parentRelateInfoResult setSchoolId:schoolId];

    NSString *schoolName = [_schoolName mutableCopy];
    [parentRelateInfoResult setSchoolName:schoolName];
    
//    NSNumber *classId = [NSNumber numberWithInteger:[_classId integerValue]];
    NSNumber *classId = [[NSNumber alloc] initWithInteger:_classId.integerValue];

    [parentRelateInfoResult setClassId:classId];
    
    NSString *className = [_className mutableCopy];
    [parentRelateInfoResult setClassName:className];

//    NSNumber *teacherId = [NSNumber numberWithInteger:[_teacherId integerValue]];
    NSNumber *teacherId = [[NSNumber alloc] initWithInteger:_teacherId.integerValue];

    [parentRelateInfoResult setTeacherId:teacherId];
    
    NSString *teacherName = [_teacherName mutableCopy];
    [parentRelateInfoResult setTeacherName:teacherName];
    
    NSString *studentName = [_studentName mutableCopy];
    [parentRelateInfoResult setStudentName:studentName];
    
//    NSNumber *studentSex = [NSNumber numberWithInteger:[_studentSex integerValue]];
    NSNumber *studentSex = [[NSNumber alloc] initWithInteger:_studentSex.integerValue];

    [parentRelateInfoResult setStudentSex:studentSex];
    
    NSString *studentBirth = [_studentBirth mutableCopy];
    [parentRelateInfoResult setStudentBirth:studentBirth];
    
    NSString *parentName = [_parentName mutableCopy];
    [parentRelateInfoResult setParentName:parentName];
    
    NSString *relation = [_relation mutableCopy];
    [parentRelateInfoResult setRelation:relation];
    
    NSString *address = [_address mutableCopy];
    [parentRelateInfoResult setAddress:address];
    
    NSString *braceletCardNumber = [_braceletCardNumber mutableCopy];
    [parentRelateInfoResult setBraceletCardNumber:braceletCardNumber];
    
    NSString *braceletNumber = [_braceletNumber mutableCopy];
    [parentRelateInfoResult setBraceletNumber:braceletNumber];
    
//    NSNumber *isSuccess = [NSNumber numberWithInteger:[_isSuccess integerValue]];
    NSNumber *isSuccess = [[NSNumber alloc] initWithInteger:_isSuccess.integerValue];

    [parentRelateInfoResult setIsSuccess:isSuccess];
    
    NSString *businessMsg = [_businessMsg mutableCopy];
    [parentRelateInfoResult setBusinessMsg:businessMsg];
    
    
    // =======================================================================
    // 修改接口新增
    // =======================================================================
    
    NSNumber *parentId = [[NSNumber alloc] initWithInteger:_parentId.integerValue];
    [parentRelateInfoResult setParentId:parentId];
    
    NSNumber *studentId = [[NSNumber alloc] initWithInteger:_studentId.integerValue];
    [parentRelateInfoResult setStudentId:studentId];
    
    NSNumber *addressId = [[NSNumber alloc] initWithInteger:_addressId.integerValue];
    [parentRelateInfoResult setAddressId:addressId];
    
    return parentRelateInfoResult;
}
@end
