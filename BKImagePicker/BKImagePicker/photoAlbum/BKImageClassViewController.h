//
//  BKImageClassViewController.h
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKImagePicker.h"

@interface BKImageClassViewController : UIViewController

/**
 最大选取量
 */
@property (nonatomic,assign) NSInteger max_select;

/**
 选取的PHAsset数组
 */
@property (nonatomic,strong) NSArray * select_imageArray;

/**
 图片大小数组
 */
@property (nonatomic,strong) NSArray * imageSizeArray;

/**
 选取的原图data数组 包含@{@"original":@"",@"thumb":@"",@"type":@""}
 */
@property (nonatomic,strong) NSArray * selectResultImageDataArray;

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
