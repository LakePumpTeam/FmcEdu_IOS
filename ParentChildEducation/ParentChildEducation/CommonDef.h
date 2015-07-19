//
//  CommonDef.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/6.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#ifndef ParentChildEducation_CommonDef_h
#define ParentChildEducation_CommonDef_h

// 屏幕宽
#define kScreenWidth                    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight                   [UIScreen mainScreen].bounds.size.height
#define kNavigationBarHeight            64

// button样式
#define kCornerRadius                               20.0
#define kBorderWidth                                0.5
#define kButtonWidth                                226
#define kButtonHeight                               40
#define kCellHeight                                 54
#define kLeftMargin                                 17
#define kTextFieldLMargin                           25

// =======================================================================
// 系统信息
// =======================================================================

// 系统版本
#define kSystemVersion                  [[[UIDevice currentDevice] systemVersion] floatValue]

// APPName
#define kAppName                        @"相伴教育"

#define kPageSize                       @"500"

#define kPwdKey                         @""

// =======================================================================
// 本地化数据File
// =======================================================================
#define kMyPhotoFile                     @"MyPhotoFile"                  // 头像数据
#define kUserLoginInfo                   @"MyUserLoginInfoFile"          // 用户登录信息

#define kSaveData                        [NSUserDefaults standardUserDefaults]

#define kTeacherIdKey                    @"teacherId"                    // 老师ID
#define kOptionIdKey                     @"optionId"                     // 选择ID
#define kClassIdKey                      @"classId"                      // 班级ID

// 消息设置
#define kMessgeVoiceKey                  @"MessgeVoiceKey"               // 消息声音
#define kMessgeShakeKey                  @"MessgeShakeKey"               // 消息震动

// =======================================================================
// 颜色
// =======================================================================
#define kWhiteColor                     [UIColor whiteColor]
#define kBackgroundGreenColor           [UIColor colorWithHex:0x00bbbb alpha:1.0]
#define kBackgroundColor                kARGBColor(240, 245, 246, 1.0)
#define kTextColor                      [UIColor colorWithHex:0x888888 alpha:1.0]
#define kTextBlackColor                 [UIColor colorWithHex:0x333333 alpha:1.0]
#define kSepartorLineColor              kARGBColor(230, 230, 230, 1.0)
#define kPhotoBrowserBackGroundColor    [UIColor colorWithHex:0x333333 alpha:1.0]

// 通过R/G/B得到color
#define kARGBColor(r,g,b,a)             [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

// =======================================================================
// Font
// =======================================================================
#define kSSmallFont                      [UIFont systemFontOfSize:10]

#define kSmallFont                       [UIFont systemFontOfSize:12]
#define kMiddleFont                      [UIFont systemFontOfSize:14]

#define kSmallTitleFont                  [UIFont systemFontOfSize:15]
#define kMiddleTitleFont                 [UIFont systemFontOfSize:18]
#define kTitleFont                       [UIFont systemFontOfSize:20]
#define kLargeTitleFont                  [UIFont systemFontOfSize:24]
#define kLargeTitleBoldFont              [UIFont boldSystemFontOfSize:24]

// ======================================================================
// VC
// ======================================================================
#define	kAboutVCName							@"AboutVC"

// =======================================================================
// 网络请求
// =======================================================================

// 一期
#define kRequestParentAuditAll                          @"profile/requestParentAuditAll"        // 老师审核家长信息（all）
#define kRequestParentAudit                             @"profile/requestParentAudit"           // 家长审核（单个）
#define kRequestParentList                              @"profile/requestPendingAuditParentList"// 家长列表
#define kRequestTeacherInfo                             @"school/requestTeacherInfo"           // 教师信息
#define kRequestAlterTeacherInfo                        @"school/requestModifyTeacherInfo"     // 修改教师信息
#define kRequestGetRelateInfo                           @"profile/requestGetRelateInfo"         // 获取家长关联信息
#define kRequestRegisterRelateInfo                      @"profile/requestRegisterBaseInfo"      // 注册（修改）关联信息
#define kRequestRegisterCheckPwd                        @"profile/requestRegisterConfirm"       // 注册（验证密码）
#define kRequestSendPhoneCodeOfRegister                 @"profile/requestPhoneIdentify"         // 发送验证码(注册)

#define kRequestHeadTeacher                             @"school/requestHeadTeacher"            // 班主任
#define kRequestPorv                                    @"location/requestProv"                 // 省份列表
#define kRequestCitys                                   @"location/requestCities"               // 城市列表
#define kRequestSchools                                 @"school/requestSchools"                // 学校列表
#define kRequestClasses                                 @"school/requestClasses"                // 班级列表


#define kRequestLogin                                   @"profile/requestLogin"                     // 登录
#define kRequestLoginSalt                               @"/profile/requestSalt"                     // 获取Salt
#define kRequestSendPhoneCodeOfForgetPwd                @"profile/requestSendPhoneCodeOfForgetPwd"  // 发送验证码(忘记密码)
#define kRequestSearchPwd                               @"profile/requestForgetPwd"                 // 找回密码
#define kRequestAlterPwd                                @"profile/requestAlterPwd"                  // 修改密码
#define kRequestHeaderTeacherForHomePage                @"/home/requestHeaderTeacherForHomePage"    // 首页老师信息

// 二期
#define kRequestDistributeClassDynamic                  @"news/postClassNews"              // 发布班级动态
#define kRequestNewsList                                @"news/requestNewsList"            // 新闻列表
#define kRequestChildClassAdImages                      @"news/requestSlides"              // 育儿学堂广告
#define kRequestNewsDetail                              @"news/requestNewsDetail"          // 新闻详情
#define kRequestPostComment                             @"news/postComment"                // 评论
#define kRequestPostCommentList                         @"news/requestComments"            // 评论列表
#define kRequestLikeNews                                @"news/likeNews"                   // 点赞
#define kRequestCheckNewNews                            @"news/checkNewNews"               // 是否有新消息
#define kRequestDeleteClassDynamic                      @"/news/requestDisableNews"        // 删除班级动态

// 三期

// 亲子教育
#define kRequestTaskList                                @"task/requestTaskList"            // 获取任务列表
#define kRequestPublishTask                             @"task/publishTask"                // 发布任务
#define kRequestStudentList                             @"school/requestStudentList"       // 学生列表
#define kRequestTaskDetail                              @"task/requestTaskDetail"          // 获取任务详情
#define kRequestAddComment                              @"task/addComment"                 // 增加评论
#define kRequestDeleteComment                           @"task/deleteComment"              // 删除评论
#define kRequestDeleteTask                              @"task/deleteTask"                 // 删除任务
#define kRequestEditTask                                @"task/editTask"                   // 修改任务
#define kRequestSubmitTask                              @"task/submitTask"                 // 完成任务
#define kRequestSubmitParticipation                     @"news/submitParticipation"        // bbs-提交调查文件



// =======================================================================
// 登录请求参数：userAccount 登录账号 password 登录密码
// =======================================================================
#define kUserCellPhoneKey       @"userAccount"
#define kUserIdKey              @"userId"

#define kUserPwdKey             @"password"
#define kUserVisiblePwdKey      @"VisiblePassword"

//#define kUserSexKey             @"userSex"
#define kUserRoleKey            @"userRole"

// =======================================================================
// base64Encode
// =======================================================================
#define base64Encode(string)                [CommonFunc base64StringFromText:string]

#define LoadImageUrl(RelativePath)          [NSString stringWithFormat:@"%@%@", @"http://182.92.98.174", RelativePath]


// =======================================================================
// mock数据配置 1:mock 0:正式数据
// =======================================================================
#define kIsMock_RequestLogin            0
#define kIsMock_RequestLoginSalt        0
#define kIsMock_RequestSlides           0
#define kIsMock_RequestTaskList         0
#define kIsMock_RequestTaskDetail       0
#define kIsMock_RequestNewsDetail       0

#endif
