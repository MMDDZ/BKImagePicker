//
//  BKEditImageBottomView.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKEditImageViewController.h"

@interface BKEditImageBottomView : UIView

/**
 编辑方式
 */
@property (nonatomic,assign,readonly) BKEditImageSelectEditType selectEditType;
/**
 绘画方式
 */
@property (nonatomic,assign,readonly) BKEditImageSelectPaintingType selectPaintingType;
/**
 绘画颜色
 */
@property (nonatomic,assign,readonly) UIColor * selectPaintingColor;
/**
 选择编辑方式
 */
@property (nonatomic,copy) void (^selectTypeAction)(void);
/**
 完成编辑发送按钮
 */
@property (nonatomic,copy) void (^sendBtnAction)(void);
/**
 完成编辑文本
 */
@property (nonatomic,copy) void (^finishWriteAction)(void);
/**
 撤销
 */
@property (nonatomic,copy) void (^revocationAction)(void);

/**
 键盘即将显示

 @param notification NSNotification
 */
-(void)keyboardWillShow:(NSNotification*)notification;

/**
 键盘即将消失

 @param notification NSNotification
 */
-(void)keyboardWillHide:(NSNotification*)notification;

@end
