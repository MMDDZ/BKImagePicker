//
//  BKPhotoAlbumListViewController.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImageBaseViewController.h"
#import "BKImagePicker.h"

@interface BKPhotoAlbumListViewController : BKImageBaseViewController

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
