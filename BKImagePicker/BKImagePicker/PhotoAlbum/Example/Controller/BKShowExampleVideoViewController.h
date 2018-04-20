//
//  BKShowExampleVideoViewController.h
//  BKImagePicker
//
//  Created by BIKE on 2018/2/6.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImageBaseViewController.h"
#import <Photos/Photos.h>
#import "BKImagePicker.h"
#import "BKImageModel.h"

@interface BKShowExampleVideoViewController : BKImageBaseViewController

/**
 选取的Video model
 */
@property (nonatomic,strong) BKImageModel * tapVideoModel;

@end
