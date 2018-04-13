//
//  BKEditImageClipView.h
//  BKImagePicker
//
//  Created by BIKE on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKEditImageBgView.h"

typedef NS_ENUM(NSUInteger, BKEditImageRotation) {
    BKEditImageRotationPortrait = 0, //初始
    BKEditImageRotationLandscapeLeft, //左倒
    BKEditImageRotationUpsideDown, //颠倒
    BKEditImageRotationLandscapeRight, //右倒
};

@interface BKEditImageClipView : UIView

@property (nonatomic,weak) BKEditImageBgView * editImageBgView;

@property (nonatomic,copy) void (^backAction)(void);
@property (nonatomic,copy) void (^finishAction)(CGRect clipFrame,BKEditImageRotation rotation);

-(void)showClipView;//显示方法
-(void)willChangeBgScrollViewZoomScale;
-(void)changeBgScrollViewZoomScale;//改变背景ScrollView的ZoomScale
-(void)endChangeBgScrollViewZoomScale;
-(void)slideBgScrollView;//滑动背景scrollview

#pragma mark - 辅助UI

-(void)hiddenSelfAuxiliaryUI;
-(void)showSelfAuxiliaryUI;
-(void)removeSelfAuxiliaryUI;

@end
