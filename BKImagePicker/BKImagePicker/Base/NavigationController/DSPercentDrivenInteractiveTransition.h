//
//  DSPercentDrivenInteractiveTransition.h
//  
//
//  Created by BIKE on 2018/7/12.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DSPercentDrivenInteractiveTransitionGestureDirection) {//手势的方向
    DSPercentDrivenInteractiveTransitionGestureDirectionRight = 0,
    DSPercentDrivenInteractiveTransitionGestureDirectionLeft
};

@interface DSPercentDrivenInteractiveTransition : UIPercentDrivenInteractiveTransition

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
 @return DSPercentDrivenInteractiveTransition
 */
- (instancetype)initWithTransitionGestureDirection:(DSPercentDrivenInteractiveTransitionGestureDirection)direction;

/**
 给传入的控制器添加手势
 
 @param viewController 控制器
 */
- (void)addPanGestureForViewController:(UIViewController *)viewController;

@end
