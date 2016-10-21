//
//  BKImagePickerCollectionViewCell.m
//  BKImagePicker
//
//  Created by iMac on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePickerCollectionViewCell.h"

@implementation BKImagePickerCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _photoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _photoImageView.clipsToBounds = YES;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_photoImageView];
        
        _selectButton = [[SelectButton alloc]initSelectButtonWithFrame:CGRectMake(frame.size.width - 30, 0, 30, 30)];
        [self addSubview:_selectButton];
        
        _videoBgLayer = [[CAGradientLayer alloc] init];
        _videoBgLayer.colors = @[(__bridge id)[UIColor colorWithWhite:1 alpha:0].CGColor,(__bridge id)[UIColor colorWithWhite:0 alpha:0.8].CGColor];
        _videoBgLayer.startPoint = CGPointMake(0.5, 0);
        _videoBgLayer.endPoint = CGPointMake(0.5, 1);
        _videoBgLayer.frame = CGRectMake(0, frame.size.height/6*5-4, frame.size.width, frame.size.height/6+4);
        [self.layer addSublayer:_videoBgLayer];
        
        _videoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, frame.size.height - frame.size.width/6 - 2, frame.size.width/6, frame.size.width/6)];
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        UIImage * videoImage = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/video.png"]];
        _videoImageView.image = videoImage;
        _videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        _videoImageView.clipsToBounds = YES;
        [self addSubview:_videoImageView];
        
        _videoTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(25, frame.size.height - frame.size.width/6 - 2, frame.size.width - 28, frame.size.width/6)];
        _videoTimeLab.font = [UIFont systemFontOfSize:10];
        _videoTimeLab.textAlignment = NSTextAlignmentRight;
        _videoTimeLab.textColor = [UIColor colorWithWhite:1 alpha:1];
        [self addSubview:_videoTimeLab];
    }
    return self;
}

@end
