//
//  BKImageModel.h
//  BKImagePicker
//
//  Created by 兆林 on 2017/6/5.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKImagePickerConst.h"
#import <Photos/Photos.h>

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
 原图大小
 */
@property (nonatomic,assign) double originalImageSize;
/**
 URL
 */
@property (nonatomic,strong) NSURL * url;


@end
