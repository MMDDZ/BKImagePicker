//
//  BKCameraRecordVideoPreviewViewController.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImagePickerBaseViewController.h"

@interface BKCameraRecordVideoPreviewViewController : BKImagePickerBaseViewController

/**
 预览视频路径
 */
@property (nonatomic,copy) NSString * videoPath;

/**
 选中方法回调
 */
@property (nonatomic,copy) void (^sendAction)(void);

@end
