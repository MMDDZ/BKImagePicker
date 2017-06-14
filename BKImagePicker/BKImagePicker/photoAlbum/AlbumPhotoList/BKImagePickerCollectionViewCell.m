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
#import "BKImageModel.h"

@implementation BKImagePickerCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _photoImageView = [[FLAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _photoImageView.runLoopMode = NSDefaultRunLoopMode;
        _photoImageView.clipsToBounds = YES;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_photoImageView];
        
        _instanceView = [[UIView alloc]initWithFrame:_photoImageView.bounds];
        _instanceView.backgroundColor = [UIColor clearColor];
        [self addSubview:_instanceView];

    }
    return self;
}

-(void)revaluateIndexPath:(NSIndexPath *)indexPath listArr:(NSArray *)listArr selectImageArr:(NSArray *)selectImageArr
{
    [[self.instanceView subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    BKImageModel * model = listArr[indexPath.item];
    self.photoImageView.image = model.thumbImage;
    
    if (model.asset.mediaType == PHAssetMediaTypeImage) {
        
        if (model.photoType == BKSelectPhotoTypeGIF) {
            
            BKGIFAlbumItemView * gifAlbumItemView = [[BKGIFAlbumItemView alloc]initWithFrame:self.instanceView.bounds];
            [self.instanceView addSubview:gifAlbumItemView];
            
            if (model.thumbImageData) {
                FLAnimatedImage * gifImage = [FLAnimatedImage animatedImageWithGIFData:model.thumbImageData];
                if (gifImage) {
                    self.photoImageView.animatedImage = gifImage;
                }
            }
            
        }
            
        if (self.max_select != 1) {
            
            BKImageAlbumItemSelectButton * selectButton = [[BKImageAlbumItemSelectButton alloc]initWithFrame:CGRectMake(self.bk_width - 30, 0, 30, 30)];
            __weak BKImagePickerCollectionViewCell * mySelf = self;
            [selectButton setSelectButtonClick:^(BKImageAlbumItemSelectButton * button) {
                [mySelf selectButton:button];
            }];
            [self.instanceView addSubview:selectButton];
            
            __block BOOL isHaveFlag = NO;
            __block NSInteger item = 0;
            [selectImageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BKImageModel * listModel = obj;
                if ([listModel.fileName isEqualToString: model.fileName]) {
                    item = idx;
                    isHaveFlag = YES;
                    *stop = YES;
                }
            }];
            
            if (isHaveFlag) {
                selectButton.title = [NSString stringWithFormat:@"%ld",item+1];
            }else{
                selectButton.title = @"";
            }
            
            selectButton.tag = indexPath.item;
        }
        
    }else{
        
        NSInteger allSecond = [[model.asset valueForKey:@"duration"] integerValue];
        
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
