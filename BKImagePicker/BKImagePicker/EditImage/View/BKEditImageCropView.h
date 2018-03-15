//
//  BKEditImageCropView.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKEditImageBgView.h"

@interface BKEditImageCropView : UIView

@property (nonatomic,weak) BKEditImageBgView * editImageBgView;

@property (nonatomic,copy) void (^backAction)(void);
@property (nonatomic,copy) void (^finishAction)(void);

-(void)showCropView;//显示方法
-(void)changeBgScrollViewZoomScale;//改变背景ScrollView的ZoomScale

@end
