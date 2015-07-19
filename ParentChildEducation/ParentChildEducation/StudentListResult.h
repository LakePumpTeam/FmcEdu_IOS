//
//  StudentListResult.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/17.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface StudentListResult : SearchNetResult

@property (nonatomic, strong) NSMutableArray *studentList;
@property (nonatomic, strong) NSNumber *isSuccess;
@property (nonatomic, strong) NSString *businessMsg;

@end
