//
//  BKEditImagePreviewCollectionViewCell.m
//  zhaolin
//
//  Created by BIKE on 2018/4/3.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImagePreviewCollectionViewCell.h"
#import "BKTool.h"

@implementation BKEditImagePreviewCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)initUI
{
    _showImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    _showImageView.clipsToBounds = YES;
    _showImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_showImageView];
    
    _selectColorView = [[UIImageView alloc] initWithFrame:_showImageView.frame];
    _selectColorView.hidden = YES;
    [self addSubview:_selectColorView];
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:CGRectMake(1.5, 1.5, _selectColorView.bk_width - 3, _selectColorView.bk_height - 3)];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    maskLayer.frame = _selectColorView.bounds;
    maskLayer.lineWidth = 3;
    maskLayer.strokeColor = BKHighlightColor.CGColor;
    maskLayer.fillColor = [UIColor clearColor].CGColor;
    [_selectColorView.layer addSublayer:maskLayer];
}

@end
