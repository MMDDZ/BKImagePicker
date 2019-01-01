//
//  BKTimer.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKTimer.h"

CGFloat const kRepeatsTime = -999999;
CGFloat const kMinTimeInterval = 0.000001;

@interface BKTimer()

/**
 单例中保存的定时器数组
 */
@property (nonatomic,strong) NSMutableArray<BKTimerModel*> * timers;

@end

@implementation BKTimer

#pragma mark - 单例方法

static BKTimer * timer = nil;

+(instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timer = [[self alloc] init];
    });
    return timer;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timer = [super allocWithZone:zone];
    });
    return timer;
}

#pragma mark - 创建定时器方法

-(dispatch_source_t)bk_setupTimerWithTimeInterval:(CGFloat)timeInterval totalTime:(CGFloat)totalTime handler:(void (^)(BKTimerModel * timerModel))handler
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    
    CGFloat temp_timeInterval = timeInterval;
    if (temp_timeInterval < kMinTimeInterval) {
        temp_timeInterval = kMinTimeInterval;
    }
    __block BKTimerModel * timerModel = [self appendTimer:timer lastTime:totalTime + temp_timeInterval];
    
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, temp_timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        
        if (totalTime != kRepeatsTime) {
            timerModel.lastTime = timerModel.lastTime - temp_timeInterval;
            
            //保留6位小数 取出整数和小数
            NSString * lastTimeStr = [NSString stringWithFormat:@"%.6f",timerModel.lastTime];
            NSArray * array = [lastTimeStr componentsSeparatedByString:@"."];
            //检测剩余时间是否为kMinTimeInterval 即0.000000
            BOOL flag = YES;
            NSString * integer = [array firstObject];
            if ([integer isEqualToString:@"0"]) {//判断整数是否为0
                NSString * decimal = [array lastObject];
                for (int i = 0; i < [decimal length]; i++) {
                    NSString * range_string = [decimal substringWithRange:NSMakeRange(i, 1)];
                    if (![range_string isEqualToString:@"0"]) {//判断小数所有位数是否为0
                        flag = NO;
                        break;
                    }
                }
            }else{
                flag = NO;
            }
            
            if (flag) {
                timerModel.lastTime = 0;
                [self bk_removeTimer:timerModel.timer];
            }else {
                if (timerModel.lastTime <= 0) {
                    timerModel.lastTime = 0;
                    [self bk_removeTimer:timerModel.timer];
                }
            }
        }
        
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(timerModel);
            });
        }
    });
    dispatch_resume(timer);
    
    return timer;
}

#pragma mark - 销毁定时器方法

-(void)bk_removeTimer:(dispatch_source_t)timer
{
    if (!timer) {
        return;
    }
    
    [self.timers enumerateObjectsUsingBlock:^(BKTimerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.timer == timer) {
            [self.timers removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    
    dispatch_source_cancel(timer);
    timer = nil;
}

#pragma mark - 模型

-(NSMutableArray *)timers
{
    if (!_timers) {
        _timers = [NSMutableArray array];
    }
    return _timers;
}

-(BKTimerModel*)appendTimer:(dispatch_source_t)timer lastTime:(CGFloat)lastTime
{
    BKTimerModel * timerModel = [[BKTimerModel alloc] init];
    timerModel.timer = timer;
    timerModel.lastTime = lastTime;
    [self.timers addObject:timerModel];
    
    return timerModel;
}

//-(BKTimerModel*)bk_updateTimer:(dispatch_source_t)timer lastTime:(CGFloat)lastTime
//{
//    __block NSInteger index = INT_MIN;
//    __block BKTimerModel * timerModel = nil;
//    [_timers enumerateObjectsUsingBlock:^(BKTimerModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (obj.timer == timer) {
//            timerModel = obj;
//            index = idx;
//            *stop = YES;
//        }
//    }];
//
//    if (!timerModel) {
//        [self bk_removeTimer:timer];
//        return nil;
//    }
//
//    timerModel.lastTime = lastTime;
//    [self.timers replaceObjectAtIndex:index withObject:timerModel];
//
//    return timerModel;
//}

@end
