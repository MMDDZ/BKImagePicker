//
//  NSString+BKImagePicker.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "NSString+BKImagePicker.h"

@implementation NSString (BKImagePicker)

-(CGSize)bk_calculateSizeWithUIWidth:(CGFloat)width font:(UIFont*)font
{
    if (!self || !font) {
        return CGSizeZero;
    }
    
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                       options: NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: font}
                                       context:nil];
    
    return rect.size;
}

-(CGSize)bk_calculateSizeWithUIHeight:(CGFloat)height font:(UIFont*)font
{
    if (!self || !font) {
        return CGSizeZero;
    }
    
    CGRect rect = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                       options: NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil];
    
    return rect.size;
}

@end
