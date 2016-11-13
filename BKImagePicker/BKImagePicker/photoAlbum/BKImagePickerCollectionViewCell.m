//
//  BKImagePickerCollectionViewCell.m
//  BKImagePicker
//
//  Created by iMac on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePickerCollectionViewCell.h"
#import "BKVideoAlbumItemView.h"
#import "BKGIFAlbumItemView.h"

@implementation BKImagePickerCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _photoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _photoImageView.clipsToBounds = YES;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_photoImageView];
        
        _instanceView = [[UIView alloc]initWithFrame:_photoImageView.bounds];
        _instanceView.backgroundColor = [UIColor clearColor];
        [self addSubview:_instanceView];
        
//        _selectButton = [[SelectButton alloc]initSelectButtonWithFrame:CGRectMake(frame.size.width - 30, 0, 30, 30)];
//        [self addSubview:_selectButton];
//
//        _gradientBgLayer = [[CAGradientLayer alloc] init];
//        _gradientBgLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0.4 alpha:0].CGColor,(__bridge id)[UIColor colorWithWhite:0 alpha:0.8].CGColor];
//        _gradientBgLayer.startPoint = CGPointMake(0.5, 0);
//        _gradientBgLayer.endPoint = CGPointMake(0.5, 1);
//        _gradientBgLayer.frame = CGRectMake(0, frame.size.height/6*5-4, frame.size.width, frame.size.height/6+4);
//        [self.layer addSublayer:_gradientBgLayer];
//        
//        _videoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(3, frame.size.height - frame.size.width/6 - 2, frame.size.width/6, frame.size.width/6)];
//        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
//        UIImage * videoImage = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/video.png"]];
//        _videoImageView.image = videoImage;
//        _videoImageView.contentMode = UIViewContentModeScaleAspectFit;
//        _videoImageView.clipsToBounds = YES;
//        [self addSubview:_videoImageView];
//        
//        _videoTimeLab = [[UILabel alloc]initWithFrame:CGRectMake(25, frame.size.height - frame.size.width/6, frame.size.width - 28, frame.size.width/6)];
//        _videoTimeLab.font = [UIFont systemFontOfSize:10];
//        _videoTimeLab.textAlignment = NSTextAlignmentRight;
//        _videoTimeLab.textColor = [UIColor colorWithWhite:1 alpha:1];
//        [self addSubview:_videoTimeLab];
//        
//        _GIF_identifier_lab = [[UILabel alloc]initWithFrame:CGRectMake(3, frame.size.height - frame.size.width/6, frame.size.width - 6, frame.size.width/6)];
//        _GIF_identifier_lab.font = [UIFont systemFontOfSize:10];
//        _GIF_identifier_lab.textAlignment = NSTextAlignmentLeft;
//        _GIF_identifier_lab.textColor = [UIColor colorWithWhite:1 alpha:1];
//        _GIF_identifier_lab.text = @"GIF";
//        [self addSubview:_GIF_identifier_lab];
    }
    return self;
}

-(void)revaluateIndexPath:(NSIndexPath *)indexPath exampleAssetArr:(NSArray *)exampleAssetArr selectImageArr:(NSArray *)selectImageArr photoImage:(UIImage *)photoImage
{
    self.photoImageView.image = photoImage;
    
    [[self.instanceView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    PHAsset * asset = (PHAsset*)exampleAssetArr[indexPath.item];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        
        NSString * fileName = [asset valueForKey:@"filename"];
        if ([fileName rangeOfString:@"gif"].location != NSNotFound || [fileName rangeOfString:@"GIF"].location != NSNotFound) {
            
            BKGIFAlbumItemView * gifAlbumItemView = [[BKGIFAlbumItemView alloc]initWithFrame:self.instanceView.bounds];
            [self.instanceView addSubview:gifAlbumItemView];
            
        }else{
            
            BKImageAlbumItemSelectButton * selectButton = [[BKImageAlbumItemSelectButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 30, 0, 30, 30)];
            __weak BKImagePickerCollectionViewCell * mySelf = self;
            [selectButton setSelectButtonClick:^(BKImageAlbumItemSelectButton * button) {
                [mySelf selectButton:button];
            }];
            [self.instanceView addSubview:selectButton];
            
            if ([selectImageArr containsObject:asset]) {
                NSInteger select_num = [selectImageArr indexOfObject:asset]+1;
                selectButton.title = [NSString stringWithFormat:@"%ld",select_num];
            }else{
                selectButton.title = @"";
            }
            
            selectButton.tag = indexPath.item;
        }
        
    }else{
        
        NSInteger allSecond = [[asset valueForKey:@"duration"] integerValue];
        
        BKVideoAlbumItemView * videoAlbumItemView = [[BKVideoAlbumItemView alloc]initWithFrame:self.instanceView.bounds allSecond:allSecond];
        [self.instanceView addSubview:videoAlbumItemView];
        
    }
}

-(void)selectButton:(BKImageAlbumItemSelectButton*)button
{
    if ([self.delegate respondsToSelector:@selector(selectImageBtnClick:)]) {
        [self.delegate selectImageBtnClick:button];
    }
}

@end
