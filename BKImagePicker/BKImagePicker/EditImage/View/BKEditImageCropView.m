//
//  BKEditImageCropView.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageCropView.h"

@interface BKEditImageCropView()

@end

@implementation BKEditImageCropView

-(void)setEditImageView:(UIImageView *)editImageView
{
    _editImageView = editImageView;
}

-(void)setDrawView:(BKEditImageDrawView *)drawView
{
    _drawView = drawView;
}

-(void)setWriteViewArr:(NSArray *)writeViewArr
{
    _writeViewArr = writeViewArr;
}

#pragma mark - init

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
