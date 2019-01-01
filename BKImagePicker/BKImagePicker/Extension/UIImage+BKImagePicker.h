//
//  UIImage+BKImagePicker.h
//  BKImagePicker
//
//  Created by BIKE on 2017/6/23.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BKImagePicker)

#pragma mark - 调整图片方向

/**
 修改图片方向为正方向

 @return 图片
 */
-(UIImage*)bk_editImageOrientation;

/**
 修改图片方向

 @param orientation 修改方向
 @return 图片
 */
-(UIImage*)bk_editImageOrientation:(UIImageOrientation)orientation;

#pragma mark - 图片资源

/**
 基础模块图片
 
 @param imageName 图片名称
 @return 图片
 */
+(UIImage*)bk_imageWithImageName:(NSString*)imageName;

/**
 编辑模块图片
 
 @param imageName 图片名称
 @return 图片
 */
+(UIImage*)bk_editImageWithImageName:(NSString*)imageName;

/**
 拍照模块图片
 
 @param imageName 图片名称
 @return 图片
 */
+(UIImage*)bk_takePhotoImageWithImageName:(NSString*)imageName;

/**
 滤镜模块图片
 
 @param imageName 图片名称
 @return 图片
 */
+(UIImage*)bk_filterImageWithImageName:(NSString*)imageName;


@end
