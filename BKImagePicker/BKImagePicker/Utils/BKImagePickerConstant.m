//
//  BKImagePickerConstant.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * const BKFinishTakePhotoNotification = @"BKFinishTakePhotoNotification";//拍照完成通知
NSString * const BKFinishRecordVideoNotification = @"BKFinishRecordVideoNotification";//拍视频完成通知
NSString * const BKFinishSelectImageNotification = @"BKFinishSelectImageNotification";//选择完成通知

NSString * const BKCanNotSelectBothTheImageAndVideoRemind = @"不能同时选择照片和视频";
NSString * const BKPleaseSelectImageRemind = @"请选择图片";
NSString * const BKOriginalImageDownloadFailedRemind = @"原图下载失败";
NSString * const BKSelectImageDownloadingRemind = @"选中的图片正在加载中,请稍后再试";
NSString * const BKImageSavedSuccessRemind = @"图片保存成功";
NSString * const BKImageSaveFailedRemind = @"图片保存失败";

NSString * const BKSelectVideoDownloadingRemind = @"视频正在加载中,请稍后再试";
NSString * const BKVideoDownloadFailedRemind = @"视频下载失败";
NSString * const BKVideoCoverDownloadFailedRemind = @"封面下载失败";

NSString * const BKRecordVideoFailedRemind = @"录制失败";
NSString * const BKSettingDevicePropertiesFailedRemind = @"设置设备属性过程发生错误,请重试";
NSString * const BKSwitchCaptureDeviceFailedRemind = @"镜头转换失败";
NSString * const BKModifyFlashModeFailedRemind = @"闪光灯转换失败";
NSString * const BKGetImageFailedRemind = @"图片获取失败";
NSString * const BKRemoveVideolipFailedRemind = @"删除失败";
NSString * const BKRecordingTimeIsUpRemind = @"录制时间已达上限";
NSString * const BKRecordedVideoWasNotFoundRemind = @"没有查到录制视频";
NSString * const BKVideoSynthesisFailedRemind = @"视频合成失败,请重试";
NSString * const BKConfirmSelectVideoFailedRemind = @"视频发送失败";

float const BKAlbumImagesSpacing = 1;//相簿图片间距
float const BKExampleImagesSpacing = 10;//查看的大图图片间距
float const BKCheckExampleImageAnimateTime = 0.5;//查看大图图片过场动画时间
float const BKCheckExampleGifAndVideoAnimateTime = 0.3;//查看Gif、Video过场动画时间
float const BKThumbImageCompressSizeMultiplier = 0.5;//图片长宽压缩比例 (小于1会把图片的长宽缩小)
float const BKRecordVideoMaxTime = 10;//录制视频最大时长
