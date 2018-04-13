//
//  BKEditImageDrawView.h
//  BKImagePicker
//
//  Created by BIKE on 2017/6/21.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKEditImageDrawModel.h"
#import "BKEditImageViewController.h"

@protocol BKEditImageDrawViewDelegate <NSObject>

@optional

/**
 马赛克处理

 @param pointArr 点数组
 */
-(void)processingMosaicImageWithPathArr:(NSArray*)pointArr;

@end

@interface BKEditImageDrawView : UIView

//这一次画的数组
@property (nonatomic,strong) NSMutableArray * pointArray;
//之前保存画的数组model
@property (nonatomic,strong) NSMutableArray<BKEditImageDrawModel*> * lineArray;
//开始点
@property (nonatomic,assign) CGPoint beginPoint;


@property (nonatomic,assign) id<BKEditImageDrawViewDelegate> delegate;


/**
 选取的颜色
 */
@property (nonatomic,strong) UIColor * selectColor;
/**
 选取画的类型（颜色或马赛克）
 */
@property (nonatomic,assign) BKEditImageSelectPaintingType selectPaintingType;
/**
 画的形状
 */
@property (nonatomic,assign) BKEditImageSelectEditType drawType;


/**
 画线

 @param point 点
 */
-(void)drawLineWithPoint:(CGPoint)point;
/**
 画圆角矩形

 @param point 点
 */
-(void)drawRoundedRectangleWithPoint:(CGPoint)point;
/**
 画圆

 @param beginPoint 起点
 @param endPoint 终点
 */
-(void)drawCircleWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint;
/**
 画箭头

 @param beginPoint 起点
 @param endPoint 终点
 */
-(void)drawArrowWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint;

/**
 清除所有
 */
-(void)cleanAllDrawBySelf;

/**
 清除最后一条
 */
-(void)cleanFinallyDraw;

@end
