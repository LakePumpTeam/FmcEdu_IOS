//
//  NewNotificationSettingVC.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/12.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "NewNotificationSettingVC.h"

@interface NewNotificationSettingVC ()

@property (nonatomic, strong) UILabel *cellLabel;
@property (nonatomic, strong) UISwitch *cellShakeSwitch;
@property (nonatomic, strong) UILabel *cellVoiceLabel;
@property (nonatomic, strong) UISwitch *cellVoiceSwitch;

@end
@implementation NewNotificationSettingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupRootViewSubs:self.view];
}

- (void)setupRootViewSubs:(UIView *)viewParent
{
    NSInteger spaceYStart = 0;
    NSInteger spaceXStart = 0;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(spaceXStart, spaceYStart, viewParent.width, viewParent.height-spaceYStart-80) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor=[UIColor clearColor];
    tableView.backgroundView = nil;
    [viewParent addSubview:tableView];
    
}

// cell布局
- (void)setupViewSubsCellVoice:(UIView *)viewParent inSize:(CGSize *)viewSize initText:(NSString *)initText
{
    if (_cellLabel == nil)
    {
        _cellLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:initText andColor:kTextColor];
        _cellLabel.textAlignment = NSTextAlignmentLeft;
        [viewParent addSubview:_cellLabel];
    }
    _cellLabel.frame = CGRectMake(17, 0, viewParent.width-130-17, viewParent.height);
    _cellLabel.text = initText;
    
    if (_cellVoiceSwitch == nil) {
        _cellVoiceSwitch = [[UISwitch alloc] init];
        _cellVoiceSwitch.onTintColor = kBackgroundGreenColor;
        [_cellVoiceSwitch addTarget:self action:@selector(voiceSwitchAction:) forControlEvents:UIControlEventValueChanged];

        [viewParent addSubview:_cellVoiceSwitch];
    }
    _cellVoiceSwitch.frame = CGRectMake(viewParent.width-15-_cellVoiceSwitch.width, (viewParent.height-_cellVoiceSwitch.height)/2, _cellVoiceSwitch.width, viewParent.height);
    _cellVoiceSwitch.on = [[kSaveData objectForKey:kMessgeVoiceKey] boolValue];
}

// cell布局
- (void)setupViewSubsCellShake:(UIView *)viewParent inSize:(CGSize *)viewSize initText:(NSString *)initText
{
    if (_cellVoiceLabel == nil)
    {
        _cellVoiceLabel = [[UILabel alloc] initWithFont:kSmallTitleFont andText:initText andColor:kTextColor];
        _cellVoiceLabel.textAlignment = NSTextAlignmentLeft;
        [viewParent addSubview:_cellVoiceLabel];
    }
    _cellVoiceLabel.frame = CGRectMake(17, 0, viewParent.width-130-17, viewParent.height);
    _cellVoiceLabel.text = initText;
    
    if (_cellShakeSwitch == nil) {
        _cellShakeSwitch = [[UISwitch alloc] init];
        _cellShakeSwitch.onTintColor = kBackgroundGreenColor;
        [_cellShakeSwitch addTarget:self action:@selector(shakeSwitchAction:) forControlEvents:UIControlEventValueChanged];

        [viewParent addSubview:_cellShakeSwitch];
    }
    
    _cellShakeSwitch.frame = CGRectMake(viewParent.width-15-_cellShakeSwitch.width, (viewParent.height-_cellShakeSwitch.height)/2, _cellShakeSwitch.width, viewParent.height);
    _cellShakeSwitch.on = [[kSaveData objectForKey:kMessgeShakeKey] boolValue];

}

#pragma mark - 事件处理
- (void)voiceSwitchAction:(UISwitch *)sender
{
    // 保存用户设置
    [kSaveData setObject:[NSNumber numberWithBool:sender.isOn] forKey:kMessgeVoiceKey];
    [kSaveData synchronize];
    
    if (sender.isOn) {
        
    }
    else {
        
    }
}

- (void)shakeSwitchAction:(UISwitch *)sender
{
    // 保存用户设置
    [kSaveData setObject:[NSNumber numberWithBool:sender.isOn] forKey:kMessgeShakeKey];
    [kSaveData synchronize];
    
    if (sender.isOn) {
        
    }
    else {
        
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        default:
            break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        NSString *reusedIdentifier = @"NotificationVoiceID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kCellHeight);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];

        [self setupViewSubsCellVoice:cell.contentView inSize:&contentViewSize initText:@"声音"];
        
        return cell;
    }
    else
    {
        NSString *reusedIdentifier = @"NotificationShakeID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedIdentifier];
            cell.backgroundColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

        }
        CGSize contentViewSize = CGSizeMake(tableView.width, kCellHeight);
        [cell.contentView setFrame:CGRectMake(0, 0, contentViewSize.width, contentViewSize.height)];

        [self setupViewSubsCellShake:cell.contentView inSize:&contentViewSize initText:@"震动"];
      
        return cell;

    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, tableView.width, 20);
    view.backgroundColor = [UIColor clearColor];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
//        UIView *view = [[UIView alloc] init];
//        view.frame = CGRectMake(0, 0, tableView.width, 80);
//        view.backgroundColor = [UIColor clearColor];
//        
//        UIButton *logOutBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//        [logOutBtn setTitle:@"设置" forState:UIControlStateNormal];
//        [logOutBtn addTarget:self action:@selector(doSettingAction) forControlEvents:UIControlEventTouchUpInside ];
//        logOutBtn.titleLabel.font=kSmallTitleFont;
//        logOutBtn.frame = CGRectMake(40, 40, tableView.width - 40*2, 40) ;
//        logOutBtn.tintColor = [UIColor whiteColor];
//        logOutBtn.backgroundColor = kBackgroundGreenColor;
//        logOutBtn.layer.cornerRadius = 20;
//        [view addSubview:logOutBtn];
//        
//        return view;
        
    }
    
    return nil;
}

@end
