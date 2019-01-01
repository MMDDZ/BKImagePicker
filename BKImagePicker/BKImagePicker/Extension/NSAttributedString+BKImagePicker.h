//
//  NSAttributedString+BKImagePicker.h
//  BKImagePicker
//
//  Created by 毕珂 on 2019/1/1.
//  Copyright © 2019年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSAttributedString (BKImagePicker)

#pragma mark - 计算文本大小

/**
 计算文本高度(固定宽)
 
 @param width 固定宽度
 @return 文本大小
 */
-(CGFloat)calculateHeightWithUIWidth:(CGFloat)width;

/**
 计算文本宽度(固定高)
 
 @param height 固定高度
 @return 文本大小
 */
-(CGFloat)calculateWidthWithUIHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
