//
//  BKDrawView.h
//  BKImagePicker
//
//  Created by 兆林 on 2017/6/21.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKSelectColorMarkView.h"

typedef enum : NSUInteger {
    BKDrawTypeLine = 0,
    BKDrawTypeRoundedRectangle,
    BKDrawTypeCircle,
    BKDrawTypeArrow,
} BKDrawType;

@interface BKDrawView : UIView

@property (nonatomic,copy) void (^movedOption)();
@property (nonatomic,copy) void (^moveEndOption)();

@property (nonatomic,strong) UIColor * selectColor;
@property (nonatomic,assign) BKSelectType selectType;

@property (nonatomic,assign) BKDrawType drawType;

/**
 清除所有
 */
-(void)cleanAllDrawBySelf;

/**
 清除最后一条
 */
-(void)cleanFinallyDraw;

/**
 生成图片
 
 @return 图片
 */
-(UIImage*)checkEditImage;

@end
