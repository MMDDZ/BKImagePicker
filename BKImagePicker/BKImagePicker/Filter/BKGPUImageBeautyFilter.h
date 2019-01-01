//
//  BKGPUImageBeautyFilter.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/27.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKImagePickerGPUImageBeautifyFilter.h"
#import "BKBeautifulSkinFilter.h"

typedef NS_ENUM(NSUInteger, BKBeautyLevel) {
    BKBeautyLevelZero = 0,      //美颜关
    BKBeautyLevelOne,           //美颜等级1
    BKBeautyLevelTwo,           //美颜等级2
    BKBeautyLevelThree,         //美颜等级3
    BKBeautyLevelFour,          //美颜等级4
    BKBeautyLevelFive,          //美颜等级5
};

@interface BKGPUImageBeautyFilter : GPUImageFilterGroup

/**
 美颜等级
 */
@property (nonatomic,assign) BKBeautyLevel beautyLevel;

/**
 亮度等级 -1~1 默认0
 */
@property (nonatomic,assign) CGFloat brightnessLevel;

/**
 修改皮肤色彩
 
 @param type 色彩滤镜格式
 @param level 级别 0~1
 */
-(void)switchLookupFilterType:(BKBeautifulSkinType)type level:(CGFloat)level;

@end
