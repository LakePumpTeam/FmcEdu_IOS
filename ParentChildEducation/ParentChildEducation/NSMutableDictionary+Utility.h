//
//  NSMutableDictionary+Utility.h
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/9.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Utility)

- (void)setObjectSafe:(id)anObject forKey:(id < NSCopying >)aKey;

@end
