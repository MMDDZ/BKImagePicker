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
#define BKNavTitleColor Color(21,126,251,1)
#define BKLineColor [UIColor colorWithWhite:0.75 alpha:1]

#define UISCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define UISCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define String(string) [BKTool adaptLanguage:string]

UIKIT_EXTERN const float BKLineHeight;
//extern const NSString * BKPreviewImageTitle;
//extern const NSString * BKEditImageTitle;
//extern const NSString * BKConfirmTitle;

#endif /* BKImagePickerConst_h */
