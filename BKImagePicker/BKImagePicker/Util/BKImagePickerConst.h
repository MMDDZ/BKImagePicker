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
#import <Photos/Photos.h>
#import "BKImageNavViewController.h"
#import "BKTool.h"

#import "UIView+BKImagePicker.h"
#import "NSObject+BKImagePicker.h"
#import "UIImage+BKImagePicker.h"
#import "UIBezierPath+BKImagePicker.h"

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

#define BK_RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#define BK_HEX_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//工具栏背景颜色
#define BKNavBackgroundColor [UIColor colorWithWhite:1 alpha:0.8]
//所有线的颜色
#define BKLineColor [UIColor colorWithWhite:0.9 alpha:1]
//高亮颜色
#define BKHighlightColor BK_HEX_RGB(0x2D96FA)
//导航字体默认颜色
#define BKNavGrayTitleColor [UIColor colorWithWhite:0.5 alpha:1]
//发送按钮默认颜色
#define BKNavSendGrayBackgroundColor [UIColor colorWithWhite:0.8 alpha:1]
//选择照片时 选择按钮默认颜色
#define BKSelectImageCircleNormalColor [UIColor colorWithWhite:0.2 alpha:0.5]

#define BK_SCREENW [UIScreen mainScreen].bounds.size.width
#define BK_SCREENH [UIScreen mainScreen].bounds.size.height

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

#define BK_WEAK_SELF(obj) __weak typeof(obj) weakSelf = obj;
#define BK_STRONG_SELF(obj) __strong typeof(obj) strongSelf = weakSelf;

#define BK_IPONEX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define BK_SYSTEM_STATUSBAR_HEIGHT (BK_IPONEX ? 44.f : 20.f)
#define BK_SYSTEM_NAV_HEIGHT BK_SYSTEM_STATUSBAR_HEIGHT + 44.f
#define BK_SYSTEM_NAV_UI_HEIGHT 44.f
#define BK_SYSTEM_TABBAR_HEIGHT (BK_IPONEX ? 83.f : 49.f)
#define BK_SYSTEM_TABBAR_UI_HEIGHT 49.f

UIKIT_EXTERN NSString * const BKFinishSelectImageNotification;

UIKIT_EXTERN const float BKAlbumImagesSpacing;
UIKIT_EXTERN const float BKExampleImagesSpacing;
UIKIT_EXTERN const float BKCheckExampleImageAnimateTime;
UIKIT_EXTERN const float BKCheckExampleGifAndVideoAnimateTime;
UIKIT_EXTERN const float BKThumbImageCompressSizeMultiplier;

#endif /* BKImagePickerConst_h */
