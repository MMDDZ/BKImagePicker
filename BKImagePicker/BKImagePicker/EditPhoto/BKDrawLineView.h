//
//  BKDrawLineView.h
//  BKImagePicker
//
//  Created by 毕珂 on 2017/5/1.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKDrawLineView : UIView

@property (nonatomic,copy) void (^movedOption)();
@property (nonatomic,copy) void (^moveEndOption)();


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
