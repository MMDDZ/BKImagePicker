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
#define BKNavHighlightTitleColor Color(21,126,251,1)
#define BKNavGrayTitleColor [UIColor colorWithWhite:0.5 alpha:1]
#define BKNavSendGrayBackgroundColor [UIColor colorWithWhite:0.8 alpha:1]
#define BKNavBackgroundColor [UIColor colorWithWhite:1 alpha:0.8]
#define BKLineColor [UIColor colorWithWhite:0.75 alpha:1]
#define BKSelectImageCircleNormalColor [UIColor colorWithWhite:0.2 alpha:0.5]
#define BKSelectImageCircleHighlightColor Color(45,150,250,1)

#define UISCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define UISCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

UIKIT_EXTERN const float BKLineHeight;
UIKIT_EXTERN const float BKCheckExampleImageAnimateTime;
UIKIT_EXTERN const float BKCheckExampleGifAndVideoAnimateTime;
UIKIT_EXTERN const float BKThumbImageCompressSizeMultiplier;


#endif /* BKImagePickerConst_h */

