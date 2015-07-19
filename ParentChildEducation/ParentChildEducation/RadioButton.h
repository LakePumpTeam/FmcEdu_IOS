//
//  EIRadioButton.h
//  EInsure
//
//  Created by ivan on 13-7-9.
//  Copyright (c) 2013年 ivan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RadioButton;

@protocol RadioButtonDelegate <NSObject>

@optional

- (void)didSelectedRadioButton:(RadioButton *)radio groupId:(NSString *)groupId;

@end

@interface RadioButton : UIButton

@property (nonatomic, weak) id<RadioButtonDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *radiosArray;

@property (nonatomic, copy, readonly) NSString            *groupId;
@property (nonatomic, assign) BOOL checked;

- (id)initWithDelegate:(id)delegate groupId:(NSString*)groupId;

@end


