//
//  AddTaskVC.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/6/3.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "BaseNameVC.h"

@interface AddTaskVC : BaseNameVC

@property (nonatomic, strong) NSMutableArray *studentList;

- (void)refreshPage;

@end
