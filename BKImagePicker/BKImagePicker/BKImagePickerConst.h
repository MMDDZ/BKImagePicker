//
//  BKImagePickerConst.h
//  BKImagePicker
//
//  Created by iMac on 16/12/30.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#ifndef BKImagePickerConst_h
#define BKImagePickerConst_h

#import <Foundation/Foundation.h>
#import "UIView+BKExpand.h"
#import "BKTool.h"

typedef NS_ENUM(NSInteger,BKPhotoType) {
    BKPhotoTypeDefault = 0,
    BKPhotoTypeImageAndGif,
    BKPhotoTypeImageAndVideo,
    BKPhotoTypeImage
};

typedef NS_ENUM(NSInteger,BKSelectPhotoType) {
    BKSelectPhotoTypeImage = 0,
    BKSelectPhotoTypeGIF,
    BKSelectPhotoTypeVideo,
};

#define Color(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
//导航字体高亮颜色
#define BKNavHighlightTitleColor Color(21,126,251,1)
//导航字体默认颜色
#define BKNavGrayTitleColor [UIColor colorWithWhite:0.5 alpha:1]
//发送按钮默认颜色
#define BKNavSendGrayBackgroundColor [UIColor colorWithWhite:0.8 alpha:1]
//工具栏背景颜色
#define BKNavBackgroundColor [UIColor colorWithWhite:1 alpha:0.8]
//所有线的颜色
#define BKLineColor [UIColor colorWithWhite:0.75 alpha:1]
//多张照片选择时 选择按钮默认颜色
#define BKSelectImageCircleNormalColor [UIColor colorWithWhite:0.2 alpha:0.5]
//多张照片选择时 选择按钮选中颜色
#define BKSelectImageCircleHighlightColor Color(45,150,250,1)

#define UISCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define UISCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

UIKIT_EXTERN const float BKLineHeight;
UIKIT_EXTERN const float BKAlbumImagesSpacing;
UIKIT_EXTERN const float BKExampleImagesSpacing;
UIKIT_EXTERN const float BKCheckExampleImageAnimateTime;
UIKIT_EXTERN const float BKCheckExampleGifAndVideoAnimateTime;
UIKIT_EXTERN const float BKThumbImageCompressSizeMultiplier;
UIKIT_EXTERN const bool  BKComfirmHaveOriginalOption;

#endif /* BKImagePickerConst_h */

