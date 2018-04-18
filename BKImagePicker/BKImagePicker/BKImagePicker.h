//
//  BKImagePicker.h
//  BKImagePicker
//
//  Created by BIKE on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKTool.h"

@interface BKImagePicker : NSObject

/**
 单例

 @return BKImagePicker
 */
+(instancetype)sharedManager;

#pragma mark - 相机

/**
 检测是否允许调用相机
 
 @param handler 检测结果
 */
- (void)checkAllowVisitCameraHandler:(void (^)(BOOL handleFlag))handler;

/**
 拍照

 @param complete 图片
 */
-(void)takePhotoWithComplete:(void (^)(UIImage * image, NSData * data))complete;

/**
 拍照 + 裁剪
 
 @param ratio 预定裁剪大小宽高比
 @param complete 图片
 */
-(void)takePhotoWithImageClipSizeWidthToHeightRatio:(CGFloat)ratio complete:(void (^)(UIImage * image, NSData * data))complete;

#pragma mark - 相册

/**
 相册
 
 @param photoType 相册类型
 @param maxSelect 最大选择数 (最大999)
 @param isHaveOriginal 是否有原图选项
 @param complete  选择图片/GIF/视频
 */
-(void)showPhotoAlbumWithTypePhoto:(BKPhotoType)photoType maxSelect:(NSInteger)maxSelect isHaveOriginal:(BOOL)isHaveOriginal complete:(void (^)(UIImage * image, NSData * data, NSURL * url, BKSelectPhotoType selectPhotoType))complete;

/**
 相册 + 裁剪
 最大选择数:1 没有原图选项 只有图片选择（没有gif）
 
 @param ratio 预定裁剪大小宽高比
 @param complete 图片
 */
-(void)showPhotoAlbumWithImageClipSizeWidthToHeightRatio:(CGFloat)ratio complete:(void (^)(UIImage * image, NSData * data))complete;

/**
 检测是否允许调用相册
 
 @param handler 检测结果
 */
-(void)checkAllowVisitPhotoAlbumHandler:(void (^)(BOOL handleFlag))handler;

/**
 保存图片
 
 @param image 图片
 @param complete 保存完成方法
 */
- (void)saveImage:(UIImage*)image complete:(void (^)(PHAsset * asset,BOOL success))complete;

@end
