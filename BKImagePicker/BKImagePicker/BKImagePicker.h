//
//  BKImagePicker.h
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKImagePickerConst.h"

@interface BKImagePicker : NSObject

-(void)takePhoto;

/**
 相册
 
 @param photoType 相册类型
 @param maxSelect 最大选择数 (最大999)
 @param complete  选择图片/GIF/视频
 */
+(void)showPhotoAlbumWithTypePhoto:(BKPhotoType)photoType maxSelect:(NSInteger)maxSelect complete:(void (^)(id result , BKSelectPhotoType selectPhotoType))complete;

/**
 检测是否允许调用相册
 
 @param handler 检测结果
 */
+(void)checkAllowVisitPhotoAlbumHandler:(void (^)(BOOL handleFlag))handler;

/**
 保存图片

 @param image 图片
 */
+(void)saveImage:(UIImage*)image;

@end
