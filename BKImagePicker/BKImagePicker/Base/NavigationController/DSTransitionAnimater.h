//
//  DSTransitionAnimater.h
//  
//
//  Created by BIKE on 2018/7/12.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DSTransitionAnimaterDirection) {//进入时过场动画的方向
    DSTransitionAnimaterDirectionRight = 0,
    DSTransitionAnimaterDirectionLeft
};

typedef NS_ENUM(NSUInteger, DSTransitionAnimaterType) {
    DSTransitionAnimaterTypePush = 0,
    DSTransitionAnimaterTypePop
};

@interface DSTransitionAnimater : NSObject<UIViewControllerAnimatedTransitioning>

/**
 返回成功回调
 */
@property (nonatomic,copy) void (^backFinishAction)(void);

/**
 是否是手势返回
 */
@property (nonatomic, assign) BOOL interation;

/**
 创建方法
 
 @param type 过场动画的方法
 @param direction 过场动画的方向
 @return DSTransitionAnimater
 */
- (instancetype)initWithTransitionType:(DSTransitionAnimaterType)type transitionAnimaterDirection:(DSTransitionAnimaterDirection)direction;

@end
