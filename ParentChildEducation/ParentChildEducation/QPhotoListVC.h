//
//  QPhotoListVC.h
//  QunariPhone
//
//  Created by Zhuo on 14-1-4.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "BaseNameVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PSTCollectionView.h"

@interface QPhotoListVC : BaseNameVC <PSTCollectionViewDelegate, PSTCollectionViewDataSource>

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@end
