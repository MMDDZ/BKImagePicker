//
//  BKShowExampleImageViewController.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/6.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImageBaseViewController.h"
#import <Photos/Photos.h>
#import "BKImagePicker.h"
#import "BKImageModel.h"

@protocol BKShowExampleImageViewControllerDelegate <NSObject>

@optional

/**
 更新浏览位置
 
 @param model 目前观看image数据
 */
-(void)refreshLookLocationActionWithImageModel:(BKImageModel*)model;

/**
 返回
 
 @param model 目前观看image数据
 */
-(UIImageView*)backActionWithImageModel:(BKImageModel*)model;

@end

@interface BKShowExampleImageViewController : BKImageBaseViewController

@property (nonatomic,assign) id<BKShowExampleImageViewControllerDelegate> delegate;

@property (nonatomic,weak) UIViewController * getCurrentVC;

/**
 点击的那张图片
 */
@property (nonatomic,strong) UIImageView * tapImageView;
/**
 展示数组
 */
@property (nonatomic,strong) NSArray * imageListArray;
/**
 选取数组
 */
@property (nonatomic,strong) NSMutableArray * selectImageArray;
/**
 选取的Image model
 */
@property (nonatomic,strong) BKImageModel * tapImageModel;
/**
 最大选取量
 */
@property (nonatomic,assign) NSInteger maxSelect;
/**
 是否选择原图
 */
@property (nonatomic,assign) BOOL isOriginal;

/**
 更新选取相册数组
 */
@property (nonatomic,copy) void (^refreshAlbumViewOption)(NSArray * selectImageArray,BOOL isOriginal);

/**
 显示方法
 */
-(void)showInNav:(UINavigationController*)nav;

@end
