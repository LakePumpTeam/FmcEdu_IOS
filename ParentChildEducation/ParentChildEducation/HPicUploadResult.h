//
//  HPicUploadResult.h
//  QunariPhone
//
//  Created by Zhuo on 14-1-5.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "SearchNetResult.h"

@interface HPicUploadResult : SearchNetResult

@property (nonatomic, strong, getter = picUrl) NSString *url;				// 图片id
@property (nonatomic, strong, readonly, getter = picEncyptWidth) NSString *width;	// 加密后的宽度
@property (nonatomic, strong, readonly, getter = picEncyptHeight) NSString *height; // 加密后的高度

@end
