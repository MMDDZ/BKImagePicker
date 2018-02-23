//
//  BKEditImageViewController.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImageBaseViewController.h"

typedef NS_ENUM(NSUInteger, BKEditImageSelectEditType) {
    BKEditImageSelectEditTypeDrawLine = 0,
    BKEditImageSelectEditTypeDrawCircle,
    BKEditImageSelectEditTypeDrawRoundedRectangle,
    BKEditImageSelectEditTypeDrawArrow,
    BKEditImageSelectEditTypeWrite,
    BKEditImageSelectEditTypeRotation,
    BKEditImageSelectEditTypeClip
};

typedef NS_ENUM(NSUInteger, BKEditImageSelectPaintingType) {
    BKEditImageSelectPaintingTypeColor = 0,
    BKEditImageSelectPaintingTypeMosaic
};

@interface BKEditImageViewController : BKImageBaseViewController

/**
 要修改的图片
 */
@property (nonatomic,strong) UIImage * editImage;

@end
