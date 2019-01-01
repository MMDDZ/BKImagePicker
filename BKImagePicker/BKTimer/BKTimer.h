//
//  BKTimer.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKTimerModel.h"

//坑点 最初使用FLT_MIN为永远执行时间判断 后来发现bug 即FLT_MIN==0而不是float的最小值
UIKIT_EXTERN const CGFloat kRepeatsTime;//永远执行时间

@interface BKTimer : NSObject

#pragma mark - 单例方法

+(instancetype)sharedManager;

#pragma mark - 创建定时器方法

/**
 初始化定时器

 @param timeInterval 时间间隔 (最多6位小数 即0.000001)
 @param totalTime 执行总时间 当 totalTime==kRepeatsTime 时无限执行
 @param handler 回调
 @return 定时器
 */
-(dispatch_source_t)bk_setupTimerWithTimeInterval:(CGFloat)timeInterval totalTime:(CGFloat)totalTime handler:(void (^)(BKTimerModel * timerModel))handler;

#pragma mark - 销毁定时器方法

/**
 删除定时器
 */
-(void)bk_removeTimer:(dispatch_source_t)timer;

@end
