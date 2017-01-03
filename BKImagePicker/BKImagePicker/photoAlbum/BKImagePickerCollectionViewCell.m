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
#import "BKImagePickerConst.h"

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
            
        }
            
        if (self.max_select != 1) {
            
            BKImageAlbumItemSelectButton * selectButton = [[BKImageAlbumItemSelectButton alloc]initWithFrame:CGRectMake(self.bk_width - 30, 0, 30, 30)];
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
