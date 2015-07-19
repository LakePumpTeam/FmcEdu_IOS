//
//  CTAssetsViewCell.h
//  QunariPhone
//
//  Created by Zhuo on 14-1-4.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "PSTCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface CTAssetsViewCell : PSTCollectionViewCell

- (void)bind:(ALAsset *)asset;

@end
