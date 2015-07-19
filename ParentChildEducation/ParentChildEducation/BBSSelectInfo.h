//
//  BBSSelectInfo.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/18.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBSSelectInfo : NSObject

@property (nonatomic, strong) NSNumber *selectionId;
@property (nonatomic, strong) NSString *selection;
@property (nonatomic, strong) NSNumber *sortOrder;            // 摆放顺序
@property (nonatomic, strong) NSNumber *isSelected;

@end
