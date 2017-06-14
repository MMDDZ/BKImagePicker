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
 选取的数组
 */
@property (nonatomic,strong) NSArray * selectImageArray;

/**
 是否选择原图
 */
@property (nonatomic,assign) BOOL isOriginal;

/**
 相册显示类型
 */
@property (nonatomic,assign) BKPhotoType photoType;

@end
