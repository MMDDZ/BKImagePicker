//
//  BKCameraGradientShadow.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/20.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BKCameraGradientDirection) {
    BKCameraGradientDirectionLeft = 0,
    BKCameraGradientDirectionRight,
    BKCameraGradientDirectionTop,
    BKCameraGradientDirectionBottom
};

@interface BKCameraGradientShadow : UIView

/**
 阴影渐变方向
 */
@property (nonatomic,assign) BKCameraGradientDirection direction;

@end
