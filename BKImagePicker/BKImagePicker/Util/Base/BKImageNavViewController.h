//
//  BKImageNavViewController.h
//  zhaolin
//
//  Created by BIKE on 2018/2/2.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKImageTransitionAnimater.h"
#import "UINavigationController+BKImagePicker.h"

@interface BKImageNavViewController : UINavigationController

#pragma mark - 自定义过场动画

/**
 是否是其他自定义push动画
 如果采用其他自定义push动画 在push前设置delegate = 对应类 ; pop后或者push下一个vc不采用其他自定义push动画前设置导航delegate = nil
 */


/**
 过场动画方向
 */
@property (nonatomic,assign) BKImageTransitionAnimaterDirection direction;

/**
 返回手势是否可用 默认可用
 */
@property (nonatomic,assign) BOOL popGestureRecognizerEnable;

/**
 过场动画返回指定VC
 */
@property (nonatomic,strong) UIViewController * popVC;

@end
