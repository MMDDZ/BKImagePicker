//
//  BKImageTransitionAnimater.h
//  zhaolin
//
//  Created by zhaolin on 2018/2/2.
//  Copyright © 2018年 zhaolin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BKImageTransitionAnimaterDirection) {//进入时过场动画的方向
    BKImageTransitionAnimaterDirectionRight = 0,
    BKImageTransitionAnimaterDirectionLeft
};

typedef NS_ENUM(NSUInteger, BKImageTransitionAnimaterType) {
    BKImageTransitionAnimaterTypePush = 0,
    BKImageTransitionAnimaterTypePop,
};

@interface BKImageTransitionAnimater : NSObject<UIViewControllerAnimatedTransitioning>

/**
 返回成功回调
 */
@property (nonatomic,copy) void (^backFinishAction)(void);

/**
 创建方法
 
 @param type 过场动画的方法
 @param direction 过场动画的方向
 @return BKTransitionAnimater
 */
- (instancetype)initWithTransitionType:(BKImageTransitionAnimaterType)type transitionAnimaterDirection:(BKImageTransitionAnimaterDirection)direction;

@end
