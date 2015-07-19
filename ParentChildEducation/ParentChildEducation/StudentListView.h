//
//  StudentListView.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/4.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTaskVC.h"

@interface StudentListView : UIView

@property (nonatomic, strong) UIView *suspendView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *studentList;

@property (nonatomic, strong) AddTaskVC *delegate;

- (id)initWithStudentList:(NSMutableArray *)studentList delegate:(AddTaskVC *)delegate;

@end
