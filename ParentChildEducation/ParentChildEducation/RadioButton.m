//
//  EIRadioButton.m
//  EInsure
//
//  Created by ivan on 13-7-9.
//  Copyright (c) 2013年 ivan. All rights reserved.
//

#import "RadioButton.h"

#define Q_RADIO_ICON_WH                     (16.0)
#define Q_ICON_TITLE_MARGIN                 (5.0)


static NSMutableDictionary *groupRadioDictionary = nil;

@implementation RadioButton

// 初始化方法
- (id)initWithFrame:(CGRect)initFrame initTitle:(NSString *)initTitle
{
    self = [super init];
    
    if (self)
    {
        // 默认设置
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:kMiddleFont];
        
        [self setTitle:initTitle forState:UIControlStateNormal];
        self.frame = initFrame;
    }
    
    return self;
}

- (id)initWithDelegate:(id)delegate groupId:(NSString*)groupId {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _groupId = [groupId copy];
        
        [self addToGroup];
        
        self.exclusiveTouch = YES;
        
        [self setImage:[UIImage imageNamed:@"radio_unchecked"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"radio_checked"] forState:UIControlStateSelected];
        [self addTarget:self action:@selector(radioBtnChecked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)addToGroup {
    if(!groupRadioDictionary){
        groupRadioDictionary = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableArray *_gRadios = [groupRadioDictionary objectForKey:_groupId];
    if (!_gRadios) {
        _gRadios = [NSMutableArray array];
    }
    [_gRadios addObject:self];
    [groupRadioDictionary setObject:_gRadios forKey:_groupId];
}

- (void)removeFromGroup {
    if (groupRadioDictionary) {
        NSMutableArray *_gRadios = [groupRadioDictionary objectForKey:_groupId];
        if (_gRadios) {
            [_gRadios removeObject:self];
            if (_gRadios.count == 0) {
                [groupRadioDictionary removeObjectForKey:_groupId];
            }
        }
    }
}

- (void)setOtherRadiosUnCheck {
    NSMutableArray *_gRadios = [groupRadioDictionary objectForKey:_groupId];
    if (_gRadios.count > 0) {
        for (RadioButton *_radio in _gRadios) {
            if (_radio.checked && ![_radio isEqual:self]) {
                _radio.checked = NO;
            }
        }
    }
}

- (void)setChecked:(BOOL)isChecked
{
    if (_checked == isChecked)
    {
        return;
    }
    else
    {
        _checked = isChecked;
    }
    
    self.selected = isChecked;
    
    if (self.selected)
    {
        [self setOtherRadiosUnCheck];
    }
    
    if (self.selected && _delegate && [_delegate respondsToSelector:@selector(didSelectedRadioButton:groupId:)]) {
        [_delegate didSelectedRadioButton:self groupId:_groupId];
    }
}

- (void)radioBtnChecked
{
    if (_checked) {
        return;
    }
    
    self.selected = !self.selected;
    _checked = self.selected;
    
    if (self.selected)
    {
        [self setOtherRadiosUnCheck];
    }
    
    if (self.selected && _delegate && [_delegate respondsToSelector:@selector(didSelectedRadioButton:groupId:)]) {
        [_delegate didSelectedRadioButton:self groupId:_groupId];
        
    }
}


- (void)dealloc {
    [self removeFromGroup];
    
}


@end
