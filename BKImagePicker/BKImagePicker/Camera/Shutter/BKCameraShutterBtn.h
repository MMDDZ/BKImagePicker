//
//  BKCameraShutterBtn.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/23.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKCameraViewController.h"

typedef NS_ENUM(NSUInteger, BKRecordState) {
    BKRecordStatePrepare = 0,         //准备录制
    BKRecordStateRecording,           //录制中
    BKRecordStatePause,               //录制暂停
    BKRecordStateEnd,                 //录制结束
    BKRecordStateRecordingFailure     //录制失败
};

@interface BKCameraShutterBtn : UIView

/**
 开启类型
 */
@property (nonatomic,assign) BKCameraType cameraType;
/**
 拍照快门回调
 */
@property (nonatomic,copy) void (^takePictureAction)(void);
/**
 录像快门回调
 */
@property (nonatomic,copy) void (^recordVideoAction)(BKRecordState state);
/**
 录像时间回调
 */
@property (nonatomic,copy) void (^changeRecordTimeAction)(CGFloat currentTime);
/**
 修改焦距比例回调
 */
@property (nonatomic,copy) void (^changeCaptureDeviceFactorPAction)(CGFloat factorP);

/**
 录制失败调用 停止动画
 */
-(void)recordingFailure;

/**
 修改录制时间(当调用删除一段视频方法等等)

 @param time 时间
 */
-(void)modifyRecordTime:(CGFloat)time;

@end
