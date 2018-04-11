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
 */
-(void)refreshSelectPhoto;

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
 选取的Image model
 */
@property (nonatomic,strong) BKImageModel * tapImageModel;

/**
 显示方法
 */
-(void)showInNav:(UINavigationController*)nav;

@end
