//
//  BKImagePickerMacro.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#ifndef BKImagePickerMacro_h
#define BKImagePickerMacro_h

#import "BKImagePickerInline.h"

/********************************** 通用颜色 **********************************/
//提示框背景颜色
#define BKRemindBackgroundColor [UIColor colorWithWhite:0 alpha:0.8]
//提示文字颜色
#define BKRemindTitleColor [UIColor whiteColor]
//loading框背景颜色
#define BKLoadingBackgroundColor [UIColor colorWithWhite:0 alpha:0.75]
//loading中旋转圆圈颜色
#define BKLoadingCircleBackgroundColor [UIColor whiteColor]
//loading中文字的颜色
#define BKLoadingTitleColor [UIColor colorWithWhite:0.5 alpha:1]
//导航背景颜色
#define BKNavBackgroundColor [UIColor colorWithWhite:1 alpha:0.8]
//导航标题颜色
#define BKNavTitleColor [UIColor blackColor]
//导航按钮标题颜色
#define BKNavBtnTitleColor BK_HEX_RGB(0x2D96FA)
//所有线的颜色
#define BKLineColor [UIColor colorWithWhite:0.85 alpha:1]

//透明颜色
#define BKClearColor [UIColor clearColor]
//红颜色
#define BKRedColor [UIColor redColor]
//橘黄颜色
#define BKOrangeColor [UIColor orangeColor]
//黄颜色
#define BKYellowColor [UIColor yellowColor]
//绿颜色
#define BKGreenColor [UIColor greenColor]
//蓝颜色
#define BKBlueColor [UIColor blueColor]
//紫颜色
#define BKPurpleColor [UIColor purpleColor]
//黑颜色
#define BKBlackColor [UIColor blackColor]
//白颜色
#define BKWhiteColor [UIColor whiteColor]
//亮灰颜色
#define BKLightGrayColor [UIColor lightGrayColor]

/********************************** 相簿界面、修改图片界面 **********************************/

//相册列表 相册名称颜色
#define BKAlbumListAlbumTitleColor [UIColor blackColor]
//相册列表 相片数量颜色
#define BKAlbumListNumTitleColor [UIColor colorWithWhite:0.5 alpha:1]
//相片列表 (未选中)发送图片按钮标题颜色
#define BKImagePickerSendTitleNormalColor [UIColor colorWithWhite:0.5 alpha:1]
//相片列表 (有选中)发送图片按钮标题颜色
#define BKImagePickerSendTitleHighlightedColor [UIColor whiteColor]
//相片列表 (未选中)发送图片按钮背景颜色
#define BKImagePickerSendNormalBackgroundColor [UIColor colorWithWhite:0.8 alpha:1]
//相片列表 (有选中)发送图片按钮背景颜色
#define BKImagePickerSendHighlightedBackgroundColor BK_HEX_RGB(0x2D96FA)
//相片列表 列表底部图片数量标注颜色
#define BKImagePickerImageNumberTitleColor [UIColor colorWithWhite:0.5 alpha:1]
//相片列表 视频时长颜色
#define BKImagePickerVideoTimeTitleColor [UIColor whiteColor]
//相片列表 GIF、视频标注阴影颜色
#define BKImagePickerVideoShadowColor [UIColor blackColor]
//相片列表 GIF、视频标注颜色
#define BKImagePickerVideoMarkColor [UIColor whiteColor]
//相片列表 (未选中)选中图片按钮背景颜色
#define BKImagePickerSelectImageNumberNormalBackgroundColor [UIColor colorWithWhite:0.2 alpha:0.5]
//相片列表 (选中)选中图片按钮背景颜色
#define BKImagePickerSelectImageNumberHighlightedBackgroundColor BK_HEX_RGB(0x2D96FA)
//相片列表 选中图片按钮边框线颜色
#define BKImagePickerSelectImageNumberBorderColor [UIColor whiteColor]
//相片列表 选中图片数量颜色
#define BKImagePickerSelectImageNumberTitleColor [UIColor whiteColor]
//相片列表 底部原图对勾颜色
#define BKImagePickerOriginalImageHookColor [UIColor whiteColor]
//视频预览 背景颜色
#define BKVideoPreviewBackgroundColor [UIColor blackColor]
//视频预览 底部导航背景颜色
#define BKVideoPreviewBottomNavBackgroundColor [UIColor colorWithWhite:0.2 alpha:0.5]
//视频预览 底部文字颜色(取消、选取)
#define BKVideoPreviewBottomNavTitleColor [UIColor whiteColor]
//编辑图片 背景颜色
#define BKEditImageBackgroundColor [UIColor blackColor]
//编辑图片 多张图编辑时选中框的颜色
#define BKEditImageSelectImageFrameColor BK_HEX_RGB(0x2D96FA)
//编辑图片 底部按钮的颜色(取消,确认)
#define BKEditImageBottomBtnBackgroundColor BK_HEX_RGB(0x2D96FA)
//编辑图片 编辑栏中字的颜色
#define BKEditImageBottomTitleColor [UIColor whiteColor]
//编辑图片 编辑文字输入框背景颜色
#define BKEditImageTextViewBackgroundColor BKNavBackgroundColor
//编辑图片 (文字未拖入)删除输入文字按钮背景颜色
#define BKEditImageDeleteWriteNormalBackgroundColor BK_HEX_RGB(0x2D96FA)
//编辑图片 (文字已拖入)删除输入文字按钮背景颜色
#define BKEditImageDeleteWriteHighlightedBackgroundColor BK_HEX_RGB(0xff725c)
//编辑图片 拖动输入文字四周的框
#define BKEditImageTextFrameColor BK_HEX_RGB(0x2D96FA)
//编辑图片 裁剪四周阴影的颜色
#define BKEditImageClipShadowBackgroundColor [UIColor colorWithWhite:0 alpha:0.6]
//编辑图片 裁剪框的颜色
#define BKEditImageClipFrameColor [UIColor whiteColor]

/********************************** 相机界面 **********************************/

//相机界面 背景颜色
#define BKCameraBackgroundColor [UIColor blackColor]
//相机界面 渐变开始颜色 必须使用rgba形式
#define BKCameraGradientShadowStartColor BK_RGBA(0, 0, 0, 0.3)
//相机界面 渐变结束颜色 必须使用rgba形式
#define BKCameraGradientShadowEndColor BK_RGBA(0, 0, 0, 0)
//相机界面 底部文字颜色(预览、删除、完成)
#define BKCameraBottomTitleColor [UIColor whiteColor]
//相机界面 底部快门颜色
#define BKCameraBottomShutterColor [UIColor whiteColor]

//录制视频进度条颜色
#define BKCameraRecordVideoProgressColor BK_HEX_RGB(0x2D96FA)
//暂停录制视频进度条颜色
#define BKCameraPauseRecordVideoProgressColor [UIColor whiteColor]
//相机界面 滤镜选择界面的底色
#define BKCameraFilterBackgroundColor [UIColor colorWithWhite:0 alpha:0.4]
//相机界面 (未选中)滤镜选择界面文字的颜色
#define BKCameraFilterTitleNormalColor [UIColor whiteColor]
//相机界面 (选中)滤镜选择界面文字的颜色
#define BKCameraFilterTitleSelectColor BK_HEX_RGB(0x2D96FA)
//相机界面 滤镜选择界面等级按钮的颜色
#define BKCameraFilterLevelBtnBackgroundColor [UIColor blackColor]
//聚焦框颜色
#define BKCameraFocusBackgroundColor BK_HEX_RGB(0xF3D33D)

/********************************** 常用宏定义 **********************************/

#define BK_RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#define BK_HEX_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define BK_SCREENW [UIScreen mainScreen].bounds.size.width
#define BK_SCREENH [UIScreen mainScreen].bounds.size.height

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

#define BK_WEAK_SELF(obj) __weak typeof(obj) weakSelf = obj;
#define BK_STRONG_SELF(obj) __strong typeof(obj) strongSelf = weakSelf;

#endif /* BKImagePickerMacro_h */
