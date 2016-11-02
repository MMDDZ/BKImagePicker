//
//  BKImagePickerCollectionViewCell.h
//  BKImagePicker
//
//  Created by iMac on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKImageAlbumItemSelectButton.h"
#import <Photos/Photos.h>

@protocol BKImagePickerCollectionViewCellDelegate <NSObject>

-(void)selectImageBtnClick:(BKImageAlbumItemSelectButton*)button;

@end

@interface BKImagePickerCollectionViewCell : UICollectionViewCell

@property (nonatomic,assign) id<BKImagePickerCollectionViewCellDelegate> delegate;

@property (nonatomic,strong) UIImageView * photoImageView;

@property (nonatomic,strong) UIView * instanceView;

//@property (nonatomic,strong) SelectButton * selectButton;
//
//@property (nonatomic,strong) CAGradientLayer * gradientBgLayer;
//
//@property (nonatomic,strong) UIImageView * videoImageView;
//
//@property (nonatomic,strong) UILabel * videoTimeLab;
//
//@property (nonatomic,strong) UILabel * GIF_identifier_lab;

-(void)revaluateIndexPath:(NSIndexPath *)indexPath exampleAssetArr:(NSArray *)exampleAssetArr selectImageArr:(NSArray *)selectImageArr photoImage:(UIImage *)photoImage;

@end
