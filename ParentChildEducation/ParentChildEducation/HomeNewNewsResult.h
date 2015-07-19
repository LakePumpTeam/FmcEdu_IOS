//
//  HomeNewNewsResult.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/23.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface HomeNewNewsResult : SearchNetResult

@property (nonatomic, strong) NSNumber *schoolNews;                                      // 校园动态
@property (nonatomic, strong) NSNumber *classNews;                                       // 班级动态
@property (nonatomic, strong, getter=educationChild) NSNumber *pcdNews;                  // 亲子教育
@property (nonatomic, strong, getter=childClassNew) NSNumber *parentingClassNews;        // 育儿学堂
@property (nonatomic, strong) NSNumber *bbsNews;                                         // 校园吧


@property (nonatomic, strong) NSNumber *isSuccess;                                      // (1:成功 其他不成功）
@property (nonatomic, strong) NSString *businessMsg;

@end
