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

@protocol BKDrawViewDelegate <NSObject>

@optional

/**
 马赛克处理

 @param pointArr 点数组
 */
-(void)processingMosaicImageWithPathArr:(NSArray*)pointArr;

/**
 滑动中
 */
-(void)movedOption;

/**
 滑动结束
 */
-(void)moveEndOption;

@end

@interface BKDrawView : UIView

@property (nonatomic,assign) id<BKDrawViewDelegate> delegate;

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
