//
//  BKEditImageViewController.h
//  BKImagePicker
//
//  Created by BIKE on 2018/2/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImageBaseViewController.h"

typedef NS_ENUM(NSUInteger, BKEditImageSelectEditType) {
    BKEditImageSelectEditTypeNone = 0,
    BKEditImageSelectEditTypeDrawLine,
    BKEditImageSelectEditTypeDrawCircle,
    BKEditImageSelectEditTypeDrawRoundedRectangle,
    BKEditImageSelectEditTypeDrawArrow,
    BKEditImageSelectEditTypeWrite,
    BKEditImageSelectEditTypeClip
};

typedef NS_ENUM(NSUInteger, BKEditImageSelectPaintingType) {
    BKEditImageSelectPaintingTypeNone = 0,
    BKEditImageSelectPaintingTypeColor,
    BKEditImageSelectPaintingTypeMosaic
};

typedef NS_ENUM(NSUInteger, BKEditImageFromModule) {
    BKEditImageFromModulePhotoAlbum = 0,
    BKEditImageFromModuleTakePhoto
};

@interface BKEditImageViewController : BKImageBaseViewController

/**
 要修改的图片
 */
@property (nonatomic,strong) NSArray<UIImage*> * editImageArr;

/**
 来自哪个模块
 */
@property (nonatomic,assign) BKEditImageFromModule fromModule;

@end
