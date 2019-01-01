//
//  BKVideoPreviewViewController.h
//  BKImagePicker
//
//  Created by BIKE on 2018/2/6.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImagePickerBaseViewController.h"
#import <Photos/Photos.h>
#import "BKImagePicker.h"
#import "BKImageModel.h"

@interface BKVideoPreviewViewController : BKImagePickerBaseViewController

/**
 选取的Video model
 */
@property (nonatomic,strong) BKImageModel * tapVideoModel;

@end
