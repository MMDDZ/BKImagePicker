//
//  BKImagePickerCollectionViewCell.h
//  BKImagePicker
//
//  Created by iMac on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "BKImageAlbumItemSelectButton.h"

@protocol BKImagePickerCollectionViewCellDelegate <NSObject>

-(void)selectImageBtnClick:(BKImageAlbumItemSelectButton*)button;

@end

@interface BKImagePickerCollectionViewCell : UICollectionViewCell

@property (nonatomic,assign) id<BKImagePickerCollectionViewCellDelegate> delegate;

@property (nonatomic,strong) UIImageView * photoImageView;

@property (nonatomic,strong) UIView * instanceView;

@property (nonatomic,assign) NSInteger max_select;

-(void)revaluateIndexPath:(NSIndexPath *)indexPath exampleAssetArr:(NSArray *)exampleAssetArr selectImageArr:(NSArray *)selectImageArr photoImage:(UIImage *)photoImage;

@end
