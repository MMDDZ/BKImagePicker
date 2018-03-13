//
//  BKEditImageCropView.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKEditImageDrawView.h"
#import "BKEditImageWriteView.h"

@interface BKEditImageCropView : UIView

@property (nonatomic,strong) UIImageView * editImageView;
@property (nonatomic,strong) BKEditImageDrawView * drawView;
@property (nonatomic,strong) NSArray * writeViewArr;

@end
