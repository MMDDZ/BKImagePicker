//
//  UIView+BKImagePicker.h
//  BKImagePicker
//
//  Created by BIKE on 16/12/30.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (BKImagePicker)

#pragma mark - 附加属性

//X
@property (nonatomic,assign) CGFloat bk_x;
//Y
@property (nonatomic,assign) CGFloat bk_y;
//width
@property (nonatomic,assign) CGFloat bk_width;
//height
@property (nonatomic,assign) CGFloat bk_height;
//CenterX
@property (nonatomic,assign) CGFloat bk_centerX;
//CenterY
@property (nonatomic,assign) CGFloat bk_centerY;

#pragma mark - 提示

/**
 提示
 
 @param text 文本
 */
-(void)bk_showRemind:(NSString*)text;

#pragma mark - Loading

/**
 查找view中是否存在loadLayer
 
 @return loadLayer
 */
-(CALayer*)bk_findLoadLayer;

/**
 加载Loading
 
 @return loadLayer
 */
-(CALayer*)bk_showLoadLayer;

/**
 加载Loading 带下载进度
 
 @param progress 进度
 */
-(void)bk_showLoadLayerWithDownLoadProgress:(CGFloat)progress;

/**
 隐藏Loading
 */
-(void)bk_hideLoadLayer;

@end
