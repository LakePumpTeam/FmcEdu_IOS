//
//  SDPhotoGroup.h
//  SDPhotoBrowser
//
//  Created by aier on 15-2-4.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SDPhotoGroupDelegate <NSObject>

- (void)imageButtonClickReturn:(CustomButton *)imageButton;

@end

typedef NS_ENUM(NSInteger, FromType)
{
    eSingleImageType = 1,
    eFourImagesType = 4
};

@interface SDPhotoGroup : UIView 

@property (nonatomic, strong) NSArray *photoItemArray;

@property (nonatomic, strong) NSArray *originUrlsArray;

@property (nonatomic, assign) NSInteger imageSize;
@property (nonatomic, assign) FromType fromType;

@property (nonatomic, strong) id<SDPhotoGroupDelegate> delegate;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com