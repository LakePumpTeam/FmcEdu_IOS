//
//  QPhotoListVC.m
//  QunariPhone
//
//  Created by Zhuo on 14-1-4.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QPhotoListVC.h"
#import "QPhotoPickerVC.h"
#import "CTAssetsViewCell.h"
#import "NetworkTask.h"

#import "NSMutableAttributedString+Append.h"
#import "OHAttributedLabel.h"

#define kQPhotoPickerVCThumbnailSize		75
#define kQPhotoPickerSeparatorWidth			2
#define kPhotoLibrarySubmitButtonHeight		44

#define kQPhotoPickerHMargin				10

#define kQPhotoPickerHintTextLabelFont		kCurNormalFontOfSize(12)
#define kQPhotoPickerCountTextLabelFont		kCurNormalFontOfSize(21)

#define kAssetsViewCellIdentifier           @"QPhotoCollectionViewCellIdentifier"

@interface QPhotoListVC ()

@property (nonatomic, strong) PSTCollectionView *collectionView;
@property (nonatomic, strong) UIView *viewBottom;
@property (nonatomic, strong) PSTCollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) NSInteger numberOfPhotos;
@property (nonatomic, assign) NSInteger numberOfVideos;

@end

@implementation QPhotoListVC

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self setupNavigationBarSubs];
	
	[self setupViewRootSubs:[self view]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssets];
}

- (void)setupAssets
{
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.numberOfPhotos = 0;
    self.numberOfVideos = 0;
    
    if (!self.assets)
	{
        self.assets = [[NSMutableArray alloc] init];
	}
    else
	{
        [self.assets removeAllObjects];
	}
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
		
        if (asset)
        {
            [self.assets addObject:asset];
            
            NSString *type = [asset valueForProperty:ALAssetPropertyType];
            
            if ([type isEqual:ALAssetTypePhoto])
			{
                self.numberOfPhotos ++;
			}
            if ([type isEqual:ALAssetTypeVideo])
			{
                self.numberOfVideos ++;
			}
        }
        else if (self.assets.count > 0)
        {
            [self.collectionView reloadData];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.assets.count-1 inSection:0]
                                        atScrollPosition:PSTCollectionViewScrollPositionTop
                                                animated:YES];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

#pragma mark - Actions
- (void)finishPickingAssets:(id)sender
{
    QPhotoPickerVC *picker = (QPhotoPickerVC *)self.navigationController;
    
	if ([picker.delegate respondsToSelector:@selector(pickerController:didFinishPickingPhotos:)])
	{
		[picker.delegate pickerController:picker didFinishPickingPhotos:picker.selectedAssets];
	}
}

// =======================================================================
#pragma mark - 布局函数
// =======================================================================
// 创建Root View的子界面
- (void)setupViewRootSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceYEnd = viewParent.height;
    
    if (kSystemVersion > 7)
    {
        spaceYStart += kNavigationBarHeight;
    }
    else
    {
        spaceYStart = 0;
        spaceYEnd -= kNavigationBarHeight;
    }
    
    // =======================================================================
    // 底部View
    // =======================================================================
    _viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0,
														   spaceYEnd - 44,
														   viewParent.width,
														   44)];
	[_viewBottom setBackgroundColor:[UIColor whiteColor]];
    
    // 创建viewBottom的子界面
    [self setupViewBottomSubs:_viewBottom];
    
    // 调整子界面位置
    spaceYEnd -= _viewBottom.frame.size.height;
    
    // 保存
    [viewParent addSubview:_viewBottom];
	
    // =======================================================================
	// PSTCollectionView
	// =======================================================================
	
    self.layout                         = [[PSTCollectionViewFlowLayout alloc] init];
    self.layout.itemSize                = CGSizeMake(kQPhotoPickerVCThumbnailSize, kQPhotoPickerVCThumbnailSize);
    self.layout.footerReferenceSize     = CGSizeMake(0, 4.0);
	self.layout.sectionInset            = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
	self.layout.minimumInteritemSpacing = 0.0;
	self.layout.minimumLineSpacing      = 4.0;
	
	_collectionView = [[PSTCollectionView alloc] initWithFrame:CGRectZero
										  collectionViewLayout:self.layout];
	[_collectionView setFrame:CGRectMake(0,
										 spaceYStart,
										 viewParent.width,
										 spaceYEnd - spaceYStart)];
	
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
	[_collectionView setAllowsMultipleSelection:YES];
	[_collectionView setDelegate:self];
	[_collectionView setDataSource:self];
    
	[_collectionView registerClass:[CTAssetsViewCell class]
		forCellWithReuseIdentifier:kAssetsViewCellIdentifier];
	
	[viewParent addSubview:_collectionView];
}

// 创建NavigationBar的子界面
- (void)setupNavigationBarSubs
{
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
    
    // =======================================================================
    // 右Button
    // =======================================================================
    UIButton *closeItem = [UIButton buttonWithType:UIButtonTypeCustom];
    closeItem.frame = CGRectMake(0, 0, 50, 20);
    [closeItem setTitle:@"关闭" forState:UIControlStateNormal];
    [closeItem setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [closeItem addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:closeItem];
    self.navigationItem.rightBarButtonItem = rightItem;
        
    // =======================================================================
    // 标题
    // =======================================================================
    [self setTitle:@"照片"];
}

// 创建viewBottom的子界面
- (void)setupViewBottomSubs:(UIView *)viewParent
{
    // 父窗口属性
    CGRect parentFrame = [viewParent frame];
    
    // 子窗口属性
    NSInteger spaceXStart = 0;
    NSInteger spaceXEnd = parentFrame.size.width;
    
    // 调整窗口尺寸
    spaceXStart += kQPhotoPickerHMargin;
    spaceXEnd -= kQPhotoPickerHMargin;
	
	[viewParent removeAllSubviews];
	
	// 创建Label
	if(viewParent != nil)
	{
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, parentFrame.size.width, 1)];
		[topLine setBackgroundColor:kBackgroundGreenColor];
		[viewParent addSubview:topLine];
	}
	
	NSMutableAttributedString *countHintText = [[NSMutableAttributedString alloc] initWithString:@""];
	
	[countHintText setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByWordWrapping];
	
	[countHintText appendAttributedString:@"已选照片"
								 withFont:kSmallTitleFont
							 andTextColor:[UIColor blackColor]];
	
    QPhotoPickerVC *vc = (QPhotoPickerVC *)self.navigationController;
	
	NSInteger maxCount = vc.maximumNumberOfSelection;
	NSInteger selectCount = vc.selectedAssets.count;
	
	[countHintText appendAttributedString:[NSString stringWithFormat:@"%ld/%ld", (long)selectCount, (long)maxCount]
								 withFont:kMiddleTitleFont
							 andTextColor:[UIColor colorWithHex:0x229ea5 alpha:1.0f]];
	
	[countHintText appendAttributedString:@"张"
								 withFont:kSmallTitleFont
							 andTextColor:[UIColor blackColor]];
	
	// 获取字体空间
	CGSize countHintTextSize = [countHintText sizeConstrainedToSize:CGSizeMake(spaceXEnd - spaceXStart, CGFLOAT_MAX)];
	
	// 创建Label
	if(viewParent != nil)
	{
		// 创建Label
		OHAttributedLabel *attributedLabelCount = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
		[attributedLabelCount setFrame:CGRectMake(spaceXStart, (parentFrame.size.height - countHintTextSize.height)/2,
												  countHintTextSize.width, countHintTextSize.height)];
		[attributedLabelCount setBackgroundColor:[UIColor clearColor]];
		[attributedLabelCount setLineBreakMode:NSLineBreakByWordWrapping];
		[attributedLabelCount setAttributedText:countHintText];
		
		// 保存
		[viewParent addSubview:attributedLabelCount];
	}
	
    // =======================================================================
	// 确定 Button
	// =======================================================================
    if(viewParent != nil)
    {
        UIButton *buttonSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonSubmit setFrame:CGRectMake(parentFrame.size.width / 2,
										  (parentFrame.size.height - kPhotoLibrarySubmitButtonHeight) / 2,
										  parentFrame.size.width / 2,
										  kPhotoLibrarySubmitButtonHeight)];
		[buttonSubmit setTitleColor:kWhiteColor forState:UIControlStateNormal];
		[buttonSubmit setTitleColor:kTextColor forState:UIControlStateDisabled];
        [buttonSubmit setBackgroundColor:kBackgroundGreenColor];
        [buttonSubmit setTitle:@"确 定" forState:UIControlStateNormal];
        [buttonSubmit addTarget:self action:@selector(finishPickingAssets:) forControlEvents:UIControlEventTouchUpInside];
        
        // 保存
        [viewParent addSubview:buttonSubmit];
    }
}

#pragma mark - 关闭照片选择

- (void)goNaviControllerBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismiss:(id)sender
{
    QPhotoPickerVC *picker = (QPhotoPickerVC *)self.navigationController;
    
    if ([picker.delegate respondsToSelector:@selector(pickerControllerDidCancel:)])
	{
        [picker.delegate pickerControllerDidCancel:picker];
    }
	
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(PSTCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assets.count;
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QPhotoCollectionViewCellIdentifier";
	
    CTAssetsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	
    ALAsset* asset = [self.assets objectAtIndex:indexPath.row];
    [cell bind:asset];
	
    if([self isContainOject:asset])
	{
		// 不完美解决方案，也可以先判断indexPath是否已存在于collectionView.indexSelectItems中
		[collectionView deselectItemAtIndexPath:indexPath animated:NO];
		[collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:PSTCollectionViewScrollPositionNone];
	}
	else
	{
		[collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:PSTCollectionViewScrollPositionNone];
		[collectionView deselectItemAtIndexPath:indexPath animated:NO];
	}
	
    return cell;
}
- (BOOL)isContainOject:(ALAsset *)assert
{
    QPhotoPickerVC *vc = (QPhotoPickerVC *)self.navigationController;

    for(ALAsset *assertTmp in vc.selectedAssets)
    {
        if([assertTmp.description isEqualToString:assert.description])
        {
            return YES;
        }
    }
    return NO;
}

- (void)removeSelectObject:(ALAsset *)assert
{
    QPhotoPickerVC *vc = (QPhotoPickerVC *)self.navigationController;
    
    ALAsset *deleteAssertTmp;
    for(ALAsset *assertTmp in vc.selectedAssets)
    {
        if([assertTmp.description isEqualToString:assert.description])
        {
            deleteAssertTmp = assertTmp;
        }
    }
    
    [vc.selectedAssets removeObjectIdenticalTo:deleteAssertTmp];

}

#pragma mark - Collection View Delegate

- (BOOL)collectionView:(PSTCollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QPhotoPickerVC *vc = (QPhotoPickerVC *)self.navigationController;
	
	if (vc.selectedAssets.count < vc.maximumNumberOfSelection)
	{
		return YES;
	}
	else
	{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多只能选择%ld张照片", (long)vc.maximumNumberOfSelection] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
		
		return NO;
	}
}

- (void)collectionView:(PSTCollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	ALAsset *asset = [_assets objectAtIndex:indexPath.row];
	
    QPhotoPickerVC *vc = (QPhotoPickerVC *)self.navigationController;
	[vc.selectedAssets addObject:asset];
	
	[self setupViewBottomSubs:_viewBottom];
}

- (void)collectionView:(PSTCollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	ALAsset *asset = [_assets objectAtIndex:indexPath.row];
	
//    QPhotoPickerVC *vc = (QPhotoPickerVC *)self.navigationController;
//	[vc.selectedAssets removeObject:asset];
    [self removeSelectObject:asset];
    
	[self setupViewBottomSubs:_viewBottom];
}

#pragma mark - Title

- (void)setTitleWithSelectedIndexPaths:(NSArray *)indexPaths
{
    // Reset title to group name
    if (indexPaths.count == 0)
    {
        self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        return;
    }
    
    BOOL photosSelected = NO;
    BOOL videoSelected  = NO;
    
    for (NSIndexPath *indexPath in indexPaths)
    {
        ALAsset *asset = [self.assets objectAtIndex:indexPath.item];
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto])
            photosSelected  = YES;
        
        if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
            videoSelected   = YES;
        
        if (photosSelected && videoSelected)
            break;
    }
    
    NSString *format;
    
    if (photosSelected && videoSelected)
        format = NSLocalizedString(@"%ld Items Selected", nil);
    
    else if (photosSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"%ld Photos Selected", nil) : NSLocalizedString(@"%ld Photo Selected", nil);
	
    else if (videoSelected)
        format = (indexPaths.count > 1) ? NSLocalizedString(@"%ld Videos Selected", nil) : NSLocalizedString(@"%ld Video Selected", nil);
    
    self.title = [NSString stringWithFormat:format, (long)indexPaths.count];
}

@end
