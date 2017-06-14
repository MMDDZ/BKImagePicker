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
#import "BKImageModel.h"

@interface BKShowExampleImageView : UIView

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIView * bottomView;

/**
 更新观看位置
 */
@property (nonatomic,copy) void (^refreshLookLocationOption)(BKImageModel * model);

/**
 返回调用方法
 */
@property (nonatomic,copy) void (^backOption)(BKImageModel * model, UIImageView * imageView);

/**
 更新选取相册数组
 */
@property (nonatomic,copy) void (^refreshAlbumViewOption)(NSArray * selectImageArray,BOOL isOriginal);

-(instancetype)initWithLocationVC:(UIViewController*)locationVC imageListArray:(NSArray*)imageListArray selectImageArray:(NSArray*)selectImageArray tapModel:(BKImageModel*)tapModel maxSelect:(NSInteger)maxSelect isOriginal:(BOOL)isOriginal;

-(void)showImageAnimate:(UIImageView*)tapImageView beginAnimateOption:(void (^)())beginOption endAnimateOption:(void (^)())endOption;

@end
