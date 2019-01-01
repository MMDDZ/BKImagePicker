//
//  BKCameraViewController.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImagePickerBaseViewController.h"
#import "BKCameraManager.h"

@interface BKCameraViewController : BKImagePickerBaseViewController

/**
 开启类型
 */
@property (nonatomic,assign) BKCameraType cameraType;

@end
