//
//  BirthdayVC.h
//  QunariPhone
//
//  Created by mt on 13-1-14.
//  Copyright (c) 2013年 Qunar.com. All rights reserved.
//

#import "BaseNameVC.h"

@protocol BirthdayVCDelegate <NSObject>

- (void)BirthdayVCBack:(NSDate *)birthdayDate withInfo:(id)delgtInfo;

@end

@interface BirthdayVC : BaseNameVC

@property (nonatomic, strong) NSDate *curValidDate;								// 当前日期
@property (nonatomic, strong) NSDate *minValidDate;								// 最小日期
@property (nonatomic, strong) NSDate *maxValidDate;								// 最大日期
@property (nonatomic, weak) id<BirthdayVCDelegate> delegate;					// 代理
@property (nonatomic, strong) id delgtInfo;										// 代理自定义数据

@end


