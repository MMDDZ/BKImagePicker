//
//  BKEditImageBottomView.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BKEditImageSelectEditType) {
    BKEditImageSelectEditTypeDrawLine = 0,
    BKEditImageSelectEditTypeDrawRoundedRectangle,
    BKEditImageSelectEditTypeDrawCircle,
    BKEditImageSelectEditTypeDrawArrow,
    BKEditImageSelectEditTypeWrite,
    BKEditImageSelectEditTypeRotation,
    BKEditImageSelectEditTypeClip
};

typedef NS_ENUM(NSUInteger, BKEditImageSelectPaintingType) {
    BKEditImageSelectPaintingTypeColor = 0,
    BKEditImageSelectPaintingTypeMosaic
};

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
 完成按钮
 */
@property (nonatomic,copy) void (^sendBtnAction)(void);

@end
