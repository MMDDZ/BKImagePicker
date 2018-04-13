//
//  BKEditImageBgView.h
//  BKImagePicker
//
//  Created by BIKE on 2018/3/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKEditImageBgView : UIScrollView

@property (nonatomic,strong) UIView * contentView;

@property (nonatomic,copy) void (^slideBgScrollViewAction)(void);
@property (nonatomic,copy) void (^willChangeZoomScaleAction)(void);
@property (nonatomic,copy) void (^changeZoomScaleAction)(void);
@property (nonatomic,copy) void (^endChangeZoomScaleAction)(void);

@end
