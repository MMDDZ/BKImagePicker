//
//  UINavigationController+BKImagePicker.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/7/3.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKImageTransitionAnimater.h"

@interface UINavigationController (BKImagePicker)

/**
 过场动画方向
 */
@property (nonatomic,assign) BKImageTransitionAnimaterDirection bk_direction;

/**
 返回手势是否可用
 */
@property (nonatomic,assign) BOOL bk_popGestureRecognizerEnable;

/**
 当前VC返回过场动画指定VC
 */
@property (nonatomic,strong) UIViewController * bk_popVC;

@end
