//
//  UIImage+Utility.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/5.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

+ (UIImage *)imageFromColor:(UIColor *)color;

-(UIImage *)scaleToSize:(CGSize)size;

- (UIImage *)imageWithMaxLength:(CGFloat)sideLenght;

+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;

@end
