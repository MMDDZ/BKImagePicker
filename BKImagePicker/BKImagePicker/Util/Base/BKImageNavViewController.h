//
//  BKImageNavViewController.h
//  zhaolin
//
//  Created by zhaolin on 2018/2/2.
//  Copyright © 2018年 zhaolin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKImageTransitionAnimater.h"
#import "BKImagePercentDrivenInteractiveTransition.h"

@interface BKImageNavViewController : UINavigationController

#pragma mark - 自定义过场动画

/**
 是否是其他自定义push动画
 如果采用其他自定义push动画 在pushViewController前赋值YES
 */
@property (nonatomic,assign) BOOL isCustomTransition;

/**
 过场动画方向
 */
@property (nonatomic,assign) BKImageTransitionAnimaterDirection direction;

/**
 交互方法
 */
@property (nonatomic,strong) BKImagePercentDrivenInteractiveTransition * customTransition;

/**
 过场动画返回指定VC
 */
@property (nonatomic,strong) UIViewController * popVC;

@end
