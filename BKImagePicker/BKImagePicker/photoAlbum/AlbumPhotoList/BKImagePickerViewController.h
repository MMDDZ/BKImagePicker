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
#import "BKImageModel.h"

@interface BKImagePickerViewController : UIViewController

/**
 最大选取量
 */
@property (nonatomic,assign) NSInteger max_select;

/**
 选取的数组
 */
@property (nonatomic,strong) NSMutableArray * selectImageArray;

/**
 是否选择原图
 */
@property (nonatomic,assign) BOOL isOriginal;

/**
 相册显示类型
 */
@property (nonatomic,assign) BKPhotoType photoType;

@end
