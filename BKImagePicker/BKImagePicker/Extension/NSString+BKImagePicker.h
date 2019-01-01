//
//  NSString+BKImagePicker.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (BKImagePicker)

/**
 计算文本的高

 @param width 文本宽
 @param font 文本字体大小
 @return 文本大小
 */
-(CGSize)bk_calculateSizeWithUIWidth:(CGFloat)width font:(UIFont*)font;

/**
 计算文本的宽

 @param height 文本高
 @param font 文本字体大小
 @return 文本大小
 */
-(CGSize)bk_calculateSizeWithUIHeight:(CGFloat)height font:(UIFont*)font;

@end
