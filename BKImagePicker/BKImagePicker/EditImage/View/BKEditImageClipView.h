//
//  BKEditImageClipView.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKEditImageBgView.h"

typedef NS_ENUM(NSUInteger, BKEditImageRotation) {
    BKEditImageRotationVertical = 0, //竖直
    BKEditImageRotationHorizontal, //水平
};

@interface BKEditImageClipView : UIView

@property (nonatomic,weak) BKEditImageBgView * editImageBgView;

@property (nonatomic,copy) void (^backAction)(void);
@property (nonatomic,copy) void (^finishAction)(void);

-(void)showClipView;//显示方法
-(void)changeBgScrollViewZoomScale;//改变背景ScrollView的ZoomScale
-(void)slideBgScrollView;//滑动背景scrollview

@end
