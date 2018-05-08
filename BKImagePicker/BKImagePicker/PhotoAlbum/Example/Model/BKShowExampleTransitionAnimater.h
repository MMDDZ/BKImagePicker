//
//  BKShowExampleTransitionAnimater.h
//  BKImagePicker
//
//  Created by BIKE on 2018/2/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BKShowExampleTransition) {
    BKShowExampleTransitionPush = 0,
    BKShowExampleTransitionPop,
};

@interface BKShowExampleTransitionAnimater : NSObject <UIViewControllerAnimatedTransitioning>

/**
 返回时背景透明百分比
 */
@property (nonatomic,assign) CGFloat alphaPercentage;
/**
 起始imageView
 */
@property (nonatomic,strong) UIImageView * startImageView;
/**
 结束点frame
 */
@property (nonatomic,assign) CGRect endRect;
/**
 转场动画完成回调
 */
@property (nonatomic,copy) void (^endTransitionAnimateAction)(void);

- (instancetype)initWithTransitionType:(BKShowExampleTransition)type;

@end
