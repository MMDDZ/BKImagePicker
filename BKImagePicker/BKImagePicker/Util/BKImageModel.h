//
//  BKImageModel.h
//  BKImagePicker
//
//  Created by BIKE on 2017/6/5.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "BKTool.h"

@interface BKImageModel : NSObject

/**
 PHAsset
 */
@property (nonatomic,strong) PHAsset * asset;
/**
 图片名称
 */
@property (nonatomic,copy) NSString * fileName;
/**
 图片类型
 */
@property (nonatomic,assign) BKSelectPhotoType photoType;
/**
 缩略图
 */
@property (nonatomic,strong) UIImage * thumbImage;
/**
 缩略图data
 */
@property (nonatomic,strong) NSData * thumbImageData;
/**
 原图data (当photoType == BKSelectPhotoTypeVideo时 为封面图data)
 */
@property (nonatomic,strong) NSData * originalImageData;
/**
 加载的进度0~1 0代表未加载或者加载失败 1代表加载完成 其余代表加载中
 */
@property (nonatomic,assign) CGFloat loadingProgress;
/**
 原图大小
 */
@property (nonatomic,assign) double originalImageSize;
/**
 URL
 */
@property (nonatomic,strong) NSURL * url;


@end
