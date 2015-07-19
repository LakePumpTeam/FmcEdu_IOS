//
//  QPhotoPickerVC.h
//  QunariPhone
//
//  Created by Zhuo on 14-1-4.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CustomNavigationController.h"

@protocol QPickerControllerDelegate;

@interface QPhotoPickerVC : CustomNavigationController

/**
 *  最大照片选择数量
 */
@property (nonatomic, assign) NSInteger maximumNumberOfSelection;

@property (nonatomic, strong) NSMutableArray *selectedAssets;

/**
 *	设置选择"照片"，"视频"，或"照片和视频"
 */
@property (nonatomic, strong, readonly) ALAssetsFilter *assetsFilter;

/**
 *  选择照片Delegate
 */
@property (nonatomic, weak) id <UINavigationControllerDelegate, QPickerControllerDelegate> delegate;

@end


/**
 *  QPickerControllerDelegate
 */
@protocol QPickerControllerDelegate <NSObject>

/**
 *  完成照片选择时调用该 Delegate
 *
 *  @param picker 照片选择VC对象
 *  @param assets 已选择的照片数组
 */
- (void)pickerController:(QPhotoPickerVC *)picker didFinishPickingPhotos:(NSArray *)assets;

@optional

/**
 *  当取消照片选择时调用该 Delegate
 *
 *  @param picker 照片选择VC对象
 */
- (void)pickerControllerDidCancel:(QPhotoPickerVC *)picker;

@end
