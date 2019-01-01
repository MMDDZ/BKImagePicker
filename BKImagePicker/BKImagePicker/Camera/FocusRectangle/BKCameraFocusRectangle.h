//
//  BKCameraFocusRectangle.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKCameraFocusRectangle : UIView

/**
 太阳级别 -1~1 默认0
 */
@property (nonatomic,assign) CGFloat sunLevel;

/**
 是否显示太阳
 */
@property (nonatomic,assign,readonly) BOOL isDisplaySun;

/**
 创建方法

 @param point 手指点的位置
 @return 聚焦框
 */
-(instancetype)initWithPoint:(CGPoint)point;

/**
 创建方法

 @param point 手指点的位置
 @param sunLevel 太阳级别 -1~1
 @return 聚焦框+太阳
 */
-(instancetype)initWithPoint:(CGPoint)point sunLevel:(CGFloat)sunLevel;

@end
