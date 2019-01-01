//
//  BKImagePicker.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "BKImageManageModel.h"

@interface BKImagePicker : NSObject

/**
 图库管理model
 */
@property (nonatomic,strong) BKImageManageModel * imageManageModel;

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

/**
 录制视频 最大时间设置在常量文件里

 @param complete 录制完成
 */
-(void)recordVideoComplete:(void (^)(UIImage * image, NSData * data, NSURL * url))complete;

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

/**
 保存视频
 
 @param videoPath 本地视频路径
 @param complete 保存完成方法
 */
-(void)saveVideo:(NSString*)videoPath complete:(void (^)(PHAsset * asset,BOOL success))complete;

#pragma mark - 获取图片

/**
 获取对应缩略图
 
 @param asset 相片
 @param complete 完成方法
 */
-(void)getThumbImageWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * thumbImage))complete;

/**
 获取对应原图
 
 @param asset 相片
 @param complete 完成方法
 */
-(void)getOriginalImageWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * originalImage))complete;

/**
 获取对应原图data
 
 @param asset 相片
 @param progressHandler 下载进度返回
 @param complete 完成方法
 */
-(void)getOriginalImageDataWithAsset:(PHAsset*)asset progressHandler:(void (^)(double progress, NSError * error, PHImageRequestID imageRequestID))progressHandler complete:(void (^)(NSData * originalImageData, NSURL * url, PHImageRequestID imageRequestID))complete;

/**
 获取视频
 
 @param asset 相片
 @param progressHandler 下载进度返回
 @param complete 完成方法
 */
-(void)getVideoDataWithAsset:(PHAsset*)asset progressHandler:(void (^)(double progress, NSError * error, PHImageRequestID imageRequestID))progressHandler complete:(void (^)(AVPlayerItem * playerItem, PHImageRequestID imageRequestID))complete;

#pragma mark - 压缩图片

/**
 压缩图片
 
 @param imageData 原图data
 @return 缩略图data
 */
-(NSData *)compressImageData:(NSData *)imageData;

#pragma mark - 查看图片是否含有alpha

/**
 查看图片是否含有alpha
 
 @param imageRef imageRef
 @return 结果
 */
-(BOOL)checkHaveAlphaWithImageRef:(CGImageRef)imageRef;

#pragma mark - 弹框提示

/**
 弹框
 
 @param title 标题
 @param message 内容
 @param actionTitleArr 按钮标题数组
 @param actionMethod 按钮标题数组对应点击事件
 */
-(void)bk_presentAlert:(NSString*)title message:(NSString*)message actionTitleArr:(NSArray*)actionTitleArr actionMethod:(void (^)(NSInteger index))actionMethod;

@end
