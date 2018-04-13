//
//  BKImagePickerFooterCollectionReusableView.m
//  BKImagePicker
//
//  Created by BIKE on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePickerFooterCollectionReusableView.h"

@implementation BKImagePickerFooterCollectionReusableView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
        _titleLab.font = [UIFont systemFontOfSize:15];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        [self addSubview:_titleLab];
        
    }
    return self;
}

@end
