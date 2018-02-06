//
//  BKShowExampleImageCollectionViewCell.h
//  BKImagePicker
//
//  Created by 毕珂 on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"

@interface BKShowExampleImageCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) FLAnimatedImageView * showImageView;

@property (nonatomic,strong) UIScrollView * imageScrollView;

@end
