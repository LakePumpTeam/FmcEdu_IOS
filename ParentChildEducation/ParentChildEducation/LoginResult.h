//
//  LoginResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/11.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

//userRole 登录者角色 int (1:老师 2：家长）
//                    auditState 审核状态（家长的审核状态）int 1：通过 2：未通过 0：正在审核 -1:未关联
//                    repayState  续费状态 int 1：已缴费 2：待续费
//                    userId  登录者id
//                    isSuccess
//                    businessMsg

// 新增

//braceletCardNumber 设备卡号
//optionList[
//{
//    optionId
//    optionName
//    classId(选择学生时，学生所属班级ID)
//    auditState  审核状态（家长的审核状态）int 1：通过 2：未通过 0：正在审核 -1:未关联 （学生家长关系的审核状态）
//    braceletCardNumber 设备卡号
//    
//}
//           ]
//userName

@interface LoginResult : SearchNetResult

@property (nonatomic, strong) NSNumber *userRole;               // 用户角色 1：老师 2：家长
@property (nonatomic, strong) NSNumber *auditState;             // 审核状态（家长的审核状态）int 1：通过 2：未通过 3：正在审核 -1:未关联
@property (nonatomic, strong) NSNumber *repayState;             // 续费状态 1：已缴费 2：待续费
@property (nonatomic, strong) NSNumber *userId;                 // 登录者id

// 新增
@property (nonatomic, strong) NSNumber *braceletCardNumber;     // 设备卡号
@property (nonatomic, strong) NSMutableArray *optionList;       // 选择列表
@property (nonatomic, strong) NSString *userName;               // 姓名

@property (nonatomic, strong) NSNumber *isSuccess;              // (1:成功 其他不成功）
@property (nonatomic, strong) NSString *businessMsg;

@end
