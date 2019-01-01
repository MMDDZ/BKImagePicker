//
//  BKTimerModel.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BKTimerModel : NSObject

/**
 定时器
 */
@property (nonatomic,strong) dispatch_source_t timer;

/**
 定时器剩余时间
 */
@property (nonatomic,assign) CGFloat lastTime;

@end
