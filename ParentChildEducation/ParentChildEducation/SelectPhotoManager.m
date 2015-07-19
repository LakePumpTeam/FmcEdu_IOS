//
//  SelectPhotoManager.m
//  CommonBusiness
//
//  Created by zlan.zhang on 14-10-17.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "SelectPhotoManager.h"
#import "HDetailPictureInfo.h"
//#import "UploadPhotoQuestAgent.h"
#import "QImagePickerController.h"

@implementation SelectPhotoManager

- (id)init
{
    self = [super init];
    if (self)
    {
        _arrayPictureInfo = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return self;
}


// 选择图片
- (void)choosePhotoWithPresentViewController:(BaseNameVC <SelectPhotoManagerDelegate> *)baseNameVC touchData:(NSMutableArray *)touchData
{
    [_arrayPictureInfo removeAllObjects];
    
    // 已选择的图片
    if (touchData.count != 0)
    {
        __block NSInteger count = 0;
        
        for (int i = 0 ; i <touchData.count; i++)
        {
            HDetailPictureInfo *hasSelectedInfo = touchData[i];
            
            // 图片标识ext
            NSString *imageExt = [[[hasSelectedInfo.asset defaultRepresentation] url] description];
            
            NSURL *imageUrl = [NSURL URLWithString:imageExt] ;
            
            [[self.class defaultAssetsLibrary] assetForURL:imageUrl
                                               resultBlock:^(ALAsset *asset)
             {
                 count++;
                 
                 HDetailPictureInfo *hDetailPictureInfo = [[HDetailPictureInfo alloc] init];
                 [hDetailPictureInfo setAsset:asset];
                 [hDetailPictureInfo setStatus:ePictureUploaded];
                 
                 [_arrayPictureInfo addObject:hDetailPictureInfo];
                 
                 if (count == touchData.count)
                 {
                     UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                              delegate:self
                                                                     cancelButtonTitle:@"取消"
                                                                destructiveButtonTitle:nil
                                                                     otherButtonTitles:@"拍照", @"从手机相册选择", nil];
                     [actionSheet showInView:[baseNameVC view]];
                     
                     _delegate = baseNameVC;
                     
                 }
                 
             }
                                              failureBlock:^(NSError *error)
             {
                 count++;
             }];
            
        }
    }
    
    if (touchData.count == 0)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"拍照", @"从手机相册选择", nil];
        [actionSheet showInView:[baseNameVC view]];
        
        _delegate = baseNameVC;
    }
}

// =======================================================================
#pragma mark - UIActionSheetDelegate
// =======================================================================
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        // 拍照
        [self chooseFromCamera];
    }
    else if (buttonIndex == 1)
    {
        // 从相册选择图片
        [self chooseFromLibrary];
    }
}

- (void)chooseFromLibrary
{
    NSMutableArray *selectedAssets = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ([_arrayPictureInfo count] > 0)
    {
        NSInteger assetCount = [_arrayPictureInfo count];
        for (NSInteger i=0; i<assetCount; i++)
        {
            HDetailPictureInfo *picInfo = [_arrayPictureInfo objectAtIndex:i];
            if (picInfo.asset)
            {
                [selectedAssets addObject:picInfo.asset];
            }
        }
    }
    
    QPhotoPickerVC *qPhotoPickerVC = [[QPhotoPickerVC alloc] init];
    qPhotoPickerVC.maximumNumberOfSelection = 4;
    qPhotoPickerVC.selectedAssets = selectedAssets;
    qPhotoPickerVC.delegate = self;
    
    [_delegate presentViewController:qPhotoPickerVC animated:YES completion:^{
        [qPhotoPickerVC.view setViewY:0];
    }];
}

- (void)chooseFromCamera
{
    if (_arrayPictureInfo.count >= 4)
    {
//        [_arrayPictureInfo removeAllObjects];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已选择4张照片。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        QImagePickerController *picker = [QImagePickerController sharedPickerController];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [_delegate presentViewController:picker animated:YES completion:^{
        }];

    }
}
#pragma mark - Photo Picker Delegate

- (void)pickerController:(QPhotoPickerVC *)picker didFinishPickingPhotos:(NSArray *)assets
{
    NSMutableArray *arrayPictureInfoNew = [[NSMutableArray alloc] initWithCapacity:0];
   
    for (NSInteger i=0; i < assets.count; i++)
    {
        ALAsset *asset = [assets objectAtIndex:i];

        HDetailPictureInfo *hDetailPictureInfo = [[HDetailPictureInfo alloc] init];
        [hDetailPictureInfo setAsset:asset];
        
        [arrayPictureInfoNew addObject:hDetailPictureInfo];
    }
    
    
//    NSInteger assetCount = [assets count];
//    
//    for (NSInteger i=0; i < assetCount; i++)
//    {
//        BOOL isHadSelected = NO;
//        
//        ALAsset *asset = [assets objectAtIndex:i];
//        
//        NSInteger assetInfoCount = [_arrayPictureInfo count];
//        for (NSInteger j=0; j<assetInfoCount; j++)
//        {
//            HDetailPictureInfo *preSelectPictureInfo = [_arrayPictureInfo objectAtIndex:j];
//            
//            if ([preSelectPictureInfo.asset isEqual:asset])
//            {
//                isHadSelected = YES;
//                break;
//            }
//        }
//        
//        if (!isHadSelected)
//        {
//            HDetailPictureInfo *hDetailPictureInfo = [[HDetailPictureInfo alloc] init];
//            [hDetailPictureInfo setAsset:asset];
//            [hDetailPictureInfo setStatus:ePictureWaitingUpload];
//            
//            [arrayPictureInfoNew addObject:hDetailPictureInfo];
//        }
//    }
    
    // 选择完图片回调
    if((_delegate != nil) && ([_delegate respondsToSelector:@selector(choosePhotoBack: upStatus:)] == YES))
    {
        // 汇总
//        [_arrayPictureInfo addObjectsFromArray:arrayPictureInfoNew];
        
        [_delegate choosePhotoBack:arrayPictureInfoNew upStatus:0];
    }
    
//    CGRect frame = _delegate.view.frame;
    [_delegate dismissViewControllerAnimated:YES completion:nil];
//    [_delegate.view setFrame:frame];
}

- (void)pickerControllerDidCancel:(QPhotoPickerVC *)picker
{
    CGRect frame = _delegate.view.frame;
    [_delegate dismissViewControllerAnimated:YES completion:nil];
    [_delegate.view setFrame:frame];
    
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    [_arrayPictureInfo removeAllObjects];
    
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera)
    {
        CGRect frame = [_delegate view].frame;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                
                [[self.class defaultAssetsLibrary] writeImageToSavedPhotosAlbum:image.CGImage
                                                                    orientation:(ALAssetOrientation)image.imageOrientation
                                                                completionBlock:^(NSURL *assetURL, NSError *error )
                 {
                     if (assetURL != nil)
                     {
                         [[self.class defaultAssetsLibrary] assetForURL:assetURL
                                                            resultBlock:^(ALAsset *asset)
                          {
                              HDetailPictureInfo *hDetailPictureInfo = [[HDetailPictureInfo alloc] init];
                              [hDetailPictureInfo setAsset:asset];
                              [hDetailPictureInfo setStatus:ePictureWaitingUpload];
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [_arrayPictureInfo addObject:hDetailPictureInfo];
                                  
                                  // 选择完图片回调
                                  if((_delegate != nil) && ([_delegate respondsToSelector:@selector(choosePhotoBack:upStatus:)] == YES))
                                  {
                                      // 回调
                                      [_delegate choosePhotoBack:_arrayPictureInfo upStatus:0];
                                  }
                              });
                          }
                                                           failureBlock:^(NSError *error)
                          {
                          }];
                         
                         
                         dispatch_async(dispatch_get_main_queue(), ^{

                         });
                     }
                     else
                     {
                         
                         if ((error.code == ALAssetsLibraryAccessGloballyDeniedError) || (error.code == ALAssetsLibraryAccessUserDeniedError)) {
                             
                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"保存照片失败，请允许\"%@\"访问您的照片库", kAppName] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                             [alertView show];
                         }
                         else
                         {
                             
                             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存照片失败，请检查可用内存后重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                             [alertView show];
                         }
                     }
                 }];
            });
        }];
        
        [[_delegate view] setFrame:frame];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    CGRect frame = [_delegate view].frame;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [[_delegate view] setFrame:frame];
    
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    
    return library;
}

#pragma mark - UIAlertViewDelegate
// =======================================================================
// UIAlertViewDelegate代理函数
// =======================================================================
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 选择完图片回调
    if((_delegate != nil) && ([_delegate respondsToSelector:@selector(choosePhotoBack: upStatus:)] == YES))
    {
        // 保存照片失败，返回-1
        [_delegate choosePhotoBack:_arrayPictureInfo upStatus:-1];
    }
}
@end
