//
//  AlertCell.m
//  ibilling
//
//  Created by 张兰 on 14-3-20.
//  Copyright (c) 2014年 Asiainfo-Linkage. All rights reserved.
//

#import "PopTableViewCell.h"

@implementation PopTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
//        UIImageView *fenGe = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height-1, self.bounds.size.width, 1) ] ;
//        fenGe.image = [UIImage imageNamed:@"virtualLine"] ;
//        [self.contentView addSubview:fenGe ] ;
    }
     return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.textLabel.textColor = [UIColor colorWithHex:0x666666 alpha:1.0];
        self.imageView.image= [UIImage imageNamed:@"select"];
    }else {
        self.textLabel.textColor = [UIColor colorWithHex:0x999999 alpha:1.0];
        self.imageView.image= [UIImage imageNamed:@"unselect"];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated] ;
    if (highlighted) {
        self.textLabel.textColor = [UIColor colorWithHex:0x666666 alpha:1.0];
        self.imageView.image= [UIImage imageNamed:@"select"];
     }else {
        self.textLabel.textColor = [UIColor colorWithHex:0x999999 alpha:1.0];
        self.imageView.image= [UIImage imageNamed:@"unselect"];
    }
}
@end
