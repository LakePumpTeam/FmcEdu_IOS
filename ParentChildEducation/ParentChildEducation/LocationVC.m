//
//  LocationVC.m
//  ParentChildEducation
//
//  Created by zhanglan on 15/6/14.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "LocationVC.h"

@interface LocationVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LocationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupRootViewSubs:self.view];
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height-spaceYStart) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor=[UIColor clearColor];
    tableView.backgroundView = nil;
    [viewParent addSubview:tableView];
    
    _tableView = tableView;
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reusedIdentifier = @"SettingsVCID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = kTextColor;
        [cell.textLabel setFont:kSmallTitleFont];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0:
        {
            if (row == 0)
            {
                [cell.textLabel setText:@"周边环境"];
                [cell.imageView setImage:[UIImage imageNamed:@"Environment"]];
            }
            else if (row == 1)
            {
                [cell.textLabel setText:@"定位"];
                [cell.imageView setImage:[UIImage imageNamed:@"LocationIcon"]];

            }
            
            break;
        }
            
        case 1:
        {
            [cell.textLabel setText:@"手环介绍"];
            [cell.imageView setImage:[UIImage imageNamed:@"BrackletIntroduce"]];

        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
