//
//  Debug.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/11.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#ifndef ParentChildEducation_Debug_h
#define ParentChildEducation_Debug_h

#define AppDebug

// =======================================================================
// DEBUG配置
// =======================================================================

// 服务器地址
#ifdef _AppDebug

#define kHostUrl                        @"http://182.92.98.174/dev/"

#else

#define kHostUrl                        @"http://182.92.98.174/"

#endif

// =======================================================================
// 项目周期
// =======================================================================
#define kProgramVersion                 3

#endif
