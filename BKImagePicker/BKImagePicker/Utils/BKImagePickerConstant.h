//
//  BKImagePickerConstant.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString * const BKFinishTakePhotoNotification;//拍照完成通知
UIKIT_EXTERN NSString * const BKFinishRecordVideoNotification;//拍视频完成通知
UIKIT_EXTERN NSString * const BKFinishSelectImageNotification;//选择完成通知

UIKIT_EXTERN NSString * const BKCanNotSelectBothTheImageAndVideoRemind;//不能同时选择照片和视频
UIKIT_EXTERN NSString * const BKPleaseSelectImageRemind;//请选择图片
UIKIT_EXTERN NSString * const BKOriginalImageDownloadFailedRemind;//原图下载失败
UIKIT_EXTERN NSString * const BKSelectImageDownloadingRemind;//选中的图片正在加载中,请稍后再试
UIKIT_EXTERN NSString * const BKImageSavedSuccessRemind;//图片保存成功
UIKIT_EXTERN NSString * const BKImageSaveFailedRemind;//图片保存失败

UIKIT_EXTERN NSString * const BKSelectVideoDownloadingRemind;//视频正在加载中,请稍后再试
UIKIT_EXTERN NSString * const BKVideoDownloadFailedRemind;//视频下载失败
UIKIT_EXTERN NSString * const BKVideoCoverDownloadFailedRemind;//封面下载失败

UIKIT_EXTERN NSString * const BKRecordVideoFailedRemind;//录制失败
UIKIT_EXTERN NSString * const BKSettingDevicePropertiesFailedRemind;//设置设备属性过程发生错误,请重试
UIKIT_EXTERN NSString * const BKSwitchCaptureDeviceFailedRemind;//镜头转换失败
UIKIT_EXTERN NSString * const BKModifyFlashModeFailedRemind;//闪光灯转换失败
UIKIT_EXTERN NSString * const BKGetImageFailedRemind;//图片获取失败
UIKIT_EXTERN NSString * const BKRemoveVideolipFailedRemind;//删除失败
UIKIT_EXTERN NSString * const BKRecordingTimeIsUpRemind;//录制时间已达上限
UIKIT_EXTERN NSString * const BKRecordedVideoWasNotFoundRemind;//没有查到录制视频
UIKIT_EXTERN NSString * const BKVideoSynthesisFailedRemind;//视频合成失败,请重试
UIKIT_EXTERN NSString * const BKConfirmSelectVideoFailedRemind;//视频发送失败

UIKIT_EXTERN const float BKAlbumImagesSpacing;//相簿图片间距
UIKIT_EXTERN const float BKExampleImagesSpacing;//查看的大图图片间距
UIKIT_EXTERN const float BKCheckExampleImageAnimateTime;//查看大图图片过场动画时间
UIKIT_EXTERN const float BKCheckExampleGifAndVideoAnimateTime;//查看Gif、Video过场动画时间
UIKIT_EXTERN const float BKThumbImageCompressSizeMultiplier;//图片长宽压缩比例 (小于1会把图片的长宽缩小)
UIKIT_EXTERN const float BKRecordVideoMaxTime;//录制视频最大时长

