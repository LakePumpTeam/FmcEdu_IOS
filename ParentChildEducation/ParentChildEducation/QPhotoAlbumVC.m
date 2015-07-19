//
//  QPhotoLibraryVC.m
//  QunariPhone
//
//  Created by Zhuo on 14-1-4.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QPhotoAlbumVC.h"
#import "QPhotoListVC.h"
#import "QPhotoPickerVC.h"

#define kQPhotoPickerVCThumbnailSize		75
#define kQPhotoPickerVCThumbnailMargin		10

@interface QPhotoAlbumVC ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation QPhotoAlbumVC

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    if (kSystemVersion >= 7.0)
    {
        // 导航背景色
        [self.navigationController.navigationBar setBarTintColor:kBackgroundGreenColor];
    }
    else
    {
        [self.navigationController.navigationBar setTintColor:kBackgroundGreenColor];
    }
    
    // title
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Bold"size:20], NSFontAttributeName, nil]];
    
    // 隐藏返回item
    [self setReturnItemHidden];
    
    [self setupNavigationBarSubs];
    
	[self setupViewRootSubs:[self view]];
	
    [self setupGroup];
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

- (void)setupGroup
{
    if (!self.assetsLibrary)
	{
        self.assetsLibrary = [self.class defaultAssetsLibrary];
	}
    
    if (!self.groups)
	{
        self.groups = [[NSMutableArray alloc] init];
	}
    else
	{
        [self.groups removeAllObjects];
	}
    
    QPhotoPickerVC *picker = (QPhotoPickerVC *)self.navigationController;
    ALAssetsFilter *assetsFilter = picker.assetsFilter;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
		
        if (group)
        {
            [group setAssetsFilter:assetsFilter];
            if (group.numberOfAssets > 0)
			{
                [self.groups addObject:group];
			}
        }
        else
        {
			if (self.groups.count == 0)
			{
				[self showNoAssets];
			}
			
			[self.tableView reloadData];
        }
    };
    
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        [self showNotAllowed];
    };
    
    // Enumerate Camera roll first
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
	
    // Then all other groups
    NSUInteger type = ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupPhotoStream;
    
    [self.assetsLibrary enumerateGroupsWithTypes:type
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
}

#pragma mark - Not allowed / No assets

- (void)showNotAllowed
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您没有允许\"去哪儿旅行\"访问您的照片库" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
	
	[_tableView setHidden:YES];
}


- (void)showNoAssets
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您照片库中没有照片" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
	
	[_tableView setHidden:YES];
}

// =======================================================================
#pragma mark - 布局函数
// =======================================================================
// 创建Root View的子界面
- (void)setupViewRootSubs:(UIView *)viewParent
{
    // 父窗口的尺寸
	CGRect parentFrame = [viewParent frame];
	 
	// 子窗口高宽
    NSInteger spaceYStart = 0;

    // =======================================================================
    // 搜索条件TableView
    // =======================================================================
    // 创建TableView
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	[_tableView setFrame:CGRectMake(0, spaceYStart, parentFrame.size.width,
										   parentFrame.size.height - spaceYStart)];
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
	[_tableView setBackgroundColor:[UIColor whiteColor]];
    [_tableView setBackgroundView:nil];
	[_tableView setDataSource:self];
	[_tableView setDelegate:self];
	
	[viewParent addSubview:_tableView];
}

// 创建NavigationBar的子界面
- (void)setupNavigationBarSubs
{
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
	[self.navigationItem setTitle:@"照片"];
}

- (void)setupCell:(UITableViewCell *)cell withAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    CGImageRef posterImage      = assetsGroup.posterImage;
    size_t height               = CGImageGetHeight(posterImage);
    float scale                 = height / kQPhotoPickerVCThumbnailSize;
    
    cell.imageView.image        = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    cell.textLabel.text         = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    cell.detailTextLabel.text   = [NSString stringWithFormat:@"%ld", (long)[assetsGroup numberOfAssets]];
    cell.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QAlbumAssetsGroupCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
	ALAssetsGroup *assetsGroup = [self.groups objectAtIndex:indexPath.row];
	[self setupCell:cell withAssetsGroup:assetsGroup];
    
    return cell;
}

#pragma mark - TableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kQPhotoPickerVCThumbnailSize + kQPhotoPickerVCThumbnailMargin;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QPhotoListVC *vc = [[QPhotoListVC alloc] init];
    vc.assetsGroup = [self.groups objectAtIndex:indexPath.row];
	
    [self.navigationController pushViewController:vc animated:YES];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 关闭照片选择

- (void)dismiss:(id)sender
{
    QPhotoPickerVC *picker = (QPhotoPickerVC *)self.navigationController;
    
    if ([picker.delegate respondsToSelector:@selector(pickerControllerDidCancel:)])
	{
        [picker.delegate pickerControllerDidCancel:picker];
    }
}

@end
