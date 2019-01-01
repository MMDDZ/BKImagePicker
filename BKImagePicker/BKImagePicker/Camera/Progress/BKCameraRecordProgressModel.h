//
//  BKCameraRecordProgressModel.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/7.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BKCameraRecordProgressModel : NSObject

/**
 当前进度时间
 */
@property (nonatomic,assign) CGFloat currentTime;
/**
 暂停的view
 */
@property (nonatomic,weak) UIView * currentPauseView;

@end
