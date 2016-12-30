//
//  BKShowExampleImageView.h
//  BKImagePicker
//
//  Created by 毕珂 on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "BKImagePicker.h"

@interface BKShowExampleImageView : UIView

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIView * bottomView;

/**
 点击的那张图片
 */
@property (nonatomic,strong) UIImageView * tapImageView;

/**
 更新观看位置
 */
@property (nonatomic,copy) void (^refreshLookAsset)(PHAsset * asset);

/**
 返回调用方法
 */
@property (nonatomic,copy) void (^backOption)(PHAsset * asset,UIImageView * imageView);

/**
 更新选取相册数组
 */
@property (nonatomic,copy) void (^refreshAlbumViewOption)(NSMutableArray * select_imageArray);

/**
 完成选择
 */
@property (nonatomic,copy) void (^finishSelectOption)(NSArray * imageArr,BKSelectPhotoType selectPhotoType);

-(instancetype)initWithLocationVC:(UIViewController*)locationVC imageAssetsArray:(NSArray*)imageAssetsArray selectImageArray:(NSArray*)selectImageArray tapAsset:(PHAsset*)tapAsset maxSelect:(NSInteger)maxSelect;

-(void)showAndBeginAnimateOption:(void (^)())beginOption endAnimateOption:(void (^)())endOption;

@end
