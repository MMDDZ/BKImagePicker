//
//  BKShowExampleImageViewController.h
//  BKImagePicker
//
//  Created by 毕珂 on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface BKShowExampleImageViewController : UIViewController

@property (nonatomic,strong) NSArray * imageAssetsArray;

@property (nonatomic,strong) PHAsset * tap_asset;

/**
 最大选取量
 */
@property (nonatomic,assign) NSInteger max_select;

/**
 选取的PHAsset数组
 */
@property (nonatomic,strong) NSMutableArray * select_imageArray;

/**
 更新选取相册数组
 */
@property (nonatomic,copy) void (^refreshAlbumViewOption)(NSMutableArray * select_imageArray);

@end
