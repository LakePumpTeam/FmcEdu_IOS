//
//  OptionInfo.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/10.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//{
//    optionId
//    optionName
//    classId(选择学生时，学生所属班级ID)
//    auditState  审核状态（家长的审核状态）int 1：通过 2：未通过 0：正在审核 -1:未关联 （学生家长关系的审核状态）
//    braceletCardNumber 设备卡号
//
//}

@interface OptionInfo : NSObject

@property (nonatomic, strong) NSNumber *optionId;
@property (nonatomic, strong) NSString *optionName;
@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, strong) NSNumber *auditState;             // 审核状态（家长的审核状态）int 1：通过 2：未通过 3：正在审核 -1:未关联
@property (nonatomic, strong) NSNumber *braceletCardNumber;     // 设备卡号

@end
