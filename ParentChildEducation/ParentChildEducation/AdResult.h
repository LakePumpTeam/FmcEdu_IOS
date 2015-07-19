//
//  AdResult.h
//  ParentChildEducation
//
//  Created by zhanglan on 15/5/25.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "SearchNetResult.h"

//slideList: [
//            newsId
//            order
//            imageUrl
//            ]
@interface AdResult : SearchNetResult

@property (nonatomic, strong) NSMutableArray *slideList;
@property (nonatomic, strong) NSNumber *isSuccess;              // (1:成功 其他不成功）
@property (nonatomic, strong) NSString *businessMsg;

@end
