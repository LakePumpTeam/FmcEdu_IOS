//
//  HDetailPictureInfo.h
//  QunariPhone
//
//  Created by Zhuo on 14-1-5.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HPicUploadResult.h"

typedef enum PictureUploadStatus : NSUInteger
{
	ePictureWaitingUpload = 1,
	ePictureUploaded = 2,
} PictureUploadStatus;

@interface HDetailPictureInfo : NSObject

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) PictureUploadStatus status;

@end
