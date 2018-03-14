//
//  BKEditImageWriteView.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/23.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BKEditImageWriteViewDelegate <NSObject>

@required

/**
 获取该视图的父视图
 */
-(UIView*)getWriteViewSupperView;

/**
 目前图片放大比例 (移动前必传)
 */
-(CGFloat)getNowImageZoomScale;

@end

@interface BKEditImageWriteView : UIView

@property (nonatomic,assign) id<BKEditImageWriteViewDelegate> delegate;

/**
 输入的内容
 */
@property (nonatomic,copy) NSString * writeString;
/**
 输入文字内容的颜色
 */
@property (nonatomic,strong) UIColor * writeColor;

/**
 重新编辑
 */
@property (nonatomic,copy) void (^reeditAction)(BKEditImageWriteView * writeView);
/**
 移动输入文字
 panGesture 移动手势
 */
@property (nonatomic,copy) void (^moveWriteAction)(BKEditImageWriteView * writeView, UIPanGestureRecognizer * panGesture);

@end
