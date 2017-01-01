//
//  BKImagePickerViewController.h
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "BKImagePicker.h"

@interface BKImagePickerViewController : UIViewController

/**
 最大选取量
 */
@property (nonatomic,assign) NSInteger max_select;

/**
 选取的PHAsset数组
 */
@property (nonatomic,strong) NSMutableArray * select_imageArray;

/**
 原图大小数组
 */
@property (nonatomic,strong) NSMutableArray * imageSizeArray;

/**
 选取的缩略图+原图数组 (每项包含1个字典 字典包含 thumb和original)
 */
@property (nonatomic,strong) NSMutableArray * selectResultImageArray;

/**
 是否选择原图
 */
@property (nonatomic,assign) BOOL isOriginal;

/**
 相册显示类型
 */
@property (nonatomic,assign) BKPhotoType photoType;

/**
 完成选择
 */
@property (nonatomic,copy) void (^finishSelectOption)(NSArray * imageArr,BKSelectPhotoType selectPhotoType);

@end
