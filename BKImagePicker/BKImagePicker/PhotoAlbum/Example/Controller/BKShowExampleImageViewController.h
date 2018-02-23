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

/**
 刷新选中

 @param selectImageArr 选中数组
 @param isOriginal 是否是原图
 */
-(void)refreshSelectPhotoWithSelectImageArr:(NSArray*)selectImageArr isOriginal:(BOOL)isOriginal;

@end

@interface BKShowExampleImageViewController : BKImageBaseViewController

@property (nonatomic,assign) id<BKShowExampleImageViewControllerDelegate> delegate;

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
 显示方法
 */
-(void)showInNav:(UINavigationController*)nav;

@end
