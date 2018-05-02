//
//  BKShowExampleImageViewController.h
//  BKImagePicker
//
//  Created by BIKE on 2018/2/6.
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
 获取当前看的图片所在图片列表VC的位置
 
 @param model 目前观看image数据
 */
-(CGRect)getFrameOfCurrentImageInListVCWithImageModel:(BKImageModel*)model;

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
