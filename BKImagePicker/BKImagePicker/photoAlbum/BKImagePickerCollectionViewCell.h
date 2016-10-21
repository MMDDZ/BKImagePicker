//
//  BKImagePickerCollectionViewCell.h
//  BKImagePicker
//
//  Created by iMac on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectButton.h"

@interface BKImagePickerCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView * photoImageView;

@property (nonatomic,strong) SelectButton * selectButton;

@property (nonatomic,strong) CAGradientLayer * videoBgLayer;

@property (nonatomic,strong) UIImageView * videoImageView;

@property (nonatomic,strong) UILabel * videoTimeLab;

@end
