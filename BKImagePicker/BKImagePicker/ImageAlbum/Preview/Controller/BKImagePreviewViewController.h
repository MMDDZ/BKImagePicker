//
//  BKImagePreviewViewController.h
//  BKImagePicker
//
//  Created by BIKE on 2018/2/6.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImagePickerBaseViewController.h"
#import <Photos/Photos.h>
#import "BKImagePicker.h"
#import "BKImageModel.h"

@protocol BKImagePreviewViewControllerDelegate <NSObject>

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

@interface BKImagePreviewViewController : BKImagePickerBaseViewController

@property (nonatomic,assign) id<BKImagePreviewViewControllerDelegate> delegate;

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
