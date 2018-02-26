//
//  BKEditImageWriteView.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/23.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKEditImageWriteView : UIView

/**
 输入的内容
 */
@property (nonatomic,copy) NSString * writeString;
/**
 输入文字内容的大小
 */
@property (nonatomic,strong) UIFont * writeFont;
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
