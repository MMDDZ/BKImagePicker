//
//  BKShowExampleInteractiveTransition.h
//  BKImagePicker
//
//  Created by BIKE on 2018/2/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKShowExampleImageViewController.h"
#import "FLAnimatedImage.h"

@interface BKShowExampleInteractiveTransition : UIPercentDrivenInteractiveTransition

/**
 导航是否隐藏
 */
@property (nonatomic,assign) BOOL isNavHidden;

/**
 是否是手势返回
 */
@property (nonatomic, assign) BOOL interation;

/**
 起始imageView
 */
@property (nonatomic,strong) FLAnimatedImageView * startImageView;

/**
 起始imageView父视图UIScrollView
 */
@property (nonatomic,strong) UIScrollView * supperScrollView;


@property (nonatomic,strong,readonly) FLAnimatedImageView * panImageView;//手势滑动imageVIew


- (void)addPanGestureForViewController:(BKShowExampleImageViewController *)viewController;

@end
