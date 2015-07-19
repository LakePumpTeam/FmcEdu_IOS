//
//  CALayer+Utility.m
//  ParentChildEducation
//
//  Created by zlan.zhang on 15/5/7.
//  Copyright (c) 2015年 lakeTechnology.com. All rights reserved.
//

#import "CALayer+Utility.h"

@implementation CALayer (Utility)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}
-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
