//
//  BKImageAlbumListTableViewCell.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImageAlbumListTableViewCell.h"
#import "BKImagePickerMacro.h"

@implementation BKImageAlbumListTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _exampleImageView = [[UIImageView alloc]init];
        _exampleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _exampleImageView.clipsToBounds = YES;
        [self addSubview:_exampleImageView];
        
        _titleLab = [[UILabel alloc]init];
        _titleLab.textColor = BKAlbumListAlbumTitleColor;
        [self addSubview:_titleLab];
        
        _countLab = [[UILabel alloc]init];
        _countLab.textColor = BKAlbumListNumTitleColor;
        [self addSubview:_countLab];
    }
    return self;
}

@end
