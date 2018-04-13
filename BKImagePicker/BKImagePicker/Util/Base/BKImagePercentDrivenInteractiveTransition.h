//
//  BKImagePercentDrivenInteractiveTransition.h
//  zhaolin
//
//  Created by BIKE on 2018/2/2.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BKImagePercentDrivenInteractiveTransitionGestureDirection) {//手势的方向
    BKImagePercentDrivenInteractiveTransitionGestureDirectionRight = 0,
    BKImagePercentDrivenInteractiveTransitionGestureDirectionLeft
};

@interface BKImagePercentDrivenInteractiveTransition : UIPercentDrivenInteractiveTransition

/**
 返回手势是否可用
 */
@property (nonatomic,assign) BOOL enble;

/**
 是否是手势返回
 */
@property (nonatomic, assign) BOOL interation;

/**
 返回的VC
 */
@property (nonatomic,weak) UIViewController * backVC;

/**
 创建方法
 
 @param direction 手势的方向
 @return BKImagePercentDrivenInteractiveTransition
 */
- (instancetype)initWithTransitionGestureDirection:(BKImagePercentDrivenInteractiveTransitionGestureDirection)direction;

/**
 给传入的控制器添加手势
 
 @param viewController 控制器
 */
- (void)addPanGestureForViewController:(UIViewController *)viewController;

@end
