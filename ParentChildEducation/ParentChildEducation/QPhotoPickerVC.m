//
//  QPhotoPickerVC.m
//  QunariPhone
//
//  Created by Zhuo on 14-1-4.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QPhotoPickerVC.h"
#import "QPhotoAlbumVC.h"

#define kPopoverContentSize CGSizeMake(320, 480)

@interface QPhotoPickerVC ()

@end

@implementation QPhotoPickerVC

- (id)init
{
    if (self = [super init])
    {
		QPhotoAlbumVC *groupViewController = [[QPhotoAlbumVC alloc] init];
		[self pushViewController:groupViewController animated:NO];
		
        _maximumNumberOfSelection   = NSIntegerMax;
        _assetsFilter               = [ALAssetsFilter allAssets];
		_selectedAssets				= [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationBar setHidden:NO];
    
    if (kSystemVersion >= 7.0)
    {
        // 导航背景色
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:1/255.0 green:186/255.0 blue:188/255.0 alpha:1.0]];
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:1/255.0 green:186/255.0 blue:188/255.0 alpha:1.0]];

    }
    
    // title
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Bold"size:20], NSFontAttributeName, nil]];
    

}

@end
