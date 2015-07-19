//
//  SelectPhotoManager.h
//  CommonBusiness
//
//  Created by zlan.zhang on 14-10-17.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QPhotoPickerVC.h"
#import "BaseNameVC.h"

@class UploadPhotoQuestAgent;

@protocol SelectPhotoManagerDelegate <NSObject>

@optional

- (void)choosePhotoBack:(NSMutableArray *)arrayPictureInfo upStatus:(NSInteger)upStatus;
@end

@interface SelectPhotoManager : NSObject<UIActionSheetDelegate,QPickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, weak) BaseNameVC <SelectPhotoManagerDelegate> *delegate;
@property (nonatomic, strong) NSMutableArray __block *arrayPictureInfo;				// 待上传的图片
@property (nonatomic, strong) UploadPhotoQuestAgent *requestAgent;					// 提交评论请求助手

/*!
 *  选择图片
 *
 *  @param baseNameVC 提交VC
 *  @param touchData  touch数据
 */
- (void)choosePhotoWithPresentViewController:(BaseNameVC <SelectPhotoManagerDelegate> *)baseNameVC touchData:(NSMutableArray *)touchData;


@end
