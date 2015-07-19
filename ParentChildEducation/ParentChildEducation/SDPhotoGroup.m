//
//  SDPhotoGroup.m
//  SDPhotoBrowser
//
//  Created by aier on 15-2-4.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"
#import "UIButton+WebCache.h"
#import "SDPhotoBrowser.h"

#define SDPhotoGroupImageMargin 10

@interface SDPhotoGroup () <SDPhotoBrowserDelegate>

@end

@implementation SDPhotoGroup 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // 清除图片缓存，便于测试
//        [[SDWebImageManager sharedManager].imageCache clearDisk];
    }
    return self;
}

- (void)setPhotoItemArray:(NSArray *)photoItemArray
{
    _photoItemArray = photoItemArray;
    
    [photoItemArray enumerateObjectsUsingBlock:^(SDPhotoItem *obj, NSUInteger idx, BOOL *stop) {
        CustomButton *btn = [[CustomButton alloc] init];
        if (_fromType == eSingleImageType)
        {
            [btn sd_setImageWithURL:[NSURL URLWithString:obj.thumbnail_pic] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ChildClassError"]];
        }
        else if (_fromType == eFourImagesType)
        {
            [btn sd_setImageWithURL:[NSURL URLWithString:obj.thumbnail_pic] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ListErrorImage"]];
        }

        btn.tag = idx;
        
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    NSInteger imageCount = self.photoItemArray.count;
//    int perRowImageCount = ((imageCount == 4) ? 2 : 3);

//    int totalRowCount = imageCount / perRowImageCount + 0.99999; // ((imageCount + perRowImageCount - 1) / perRowImageCount)
    
    if (_fromType == eSingleImageType)
    {
        [self.subviews enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
            
//            NSInteger rowIndex = idx / perRowImageCount;
//            int columnIndex = idx % perRowImageCount;
//            CGFloat x = columnIndex * (_imageSize + SDPhotoGroupImageMargin);
//            CGFloat y = rowIndex * (_imageSize + SDPhotoGroupImageMargin);
            btn.frame = self.frame;
        }];
    }
    
    if (_fromType == eFourImagesType)
    {
        [self.subviews enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL *stop) {
            int perRowImageCount = 4;
            NSInteger rowIndex = idx / perRowImageCount;
            int columnIndex = idx % perRowImageCount;
            CGFloat x = columnIndex * (_imageSize + SDPhotoGroupImageMargin);
            CGFloat y = rowIndex * (_imageSize + SDPhotoGroupImageMargin);
            btn.frame = CGRectMake(x, y, _imageSize, _imageSize);
        }];
    }
    

//    self.frame = CGRectMake(10, 10, _imageSize, _imageSize);
}

- (void)buttonClick:(CustomButton *)button
{
//    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
//    browser.sourceImagesContainerView = self; // 原图的父控件
//    browser.imageCount = self.photoItemArray.count; // 图片总数
//    browser.currentImageIndex = button.tag;
//    browser.delegate = self;
//    [browser show];
    
    if (_delegate && [_delegate respondsToSelector:@selector(imageButtonClickReturn:)])
    {
        button.customInfo = _originUrlsArray;
        
        [_delegate imageButtonClickReturn:button];
    }
    
}

#pragma mark - photobrowser代理方法

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return [self.subviews[index] currentImage];
}

// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    if (_originUrlsArray.count > 0)
    {
        return [NSURL URLWithString:_originUrlsArray[index]];
    }
    else
    {
        NSString *urlStr = [[self.photoItemArray[index] thumbnail_pic] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        return [NSURL URLWithString:urlStr];
    }
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com