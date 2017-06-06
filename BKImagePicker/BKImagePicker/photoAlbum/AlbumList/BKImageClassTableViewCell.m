//
//  BKImageClassTableViewCell.m
//  BKImagePicker
//
//  Created by iMac on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImageClassTableViewCell.h"

@implementation BKImageClassTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _exampleImageView = [[UIImageView alloc]init];
        _exampleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _exampleImageView.clipsToBounds = YES;
        [self addSubview:_exampleImageView];
        
        _titleLab = [[UILabel alloc]init];
        _titleLab.textColor = [UIColor blackColor];
        [self addSubview:_titleLab];
        
        _countLab = [[UILabel alloc]init];
        _countLab.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        [self addSubview:_countLab];
    }
    return self;
}

@end
