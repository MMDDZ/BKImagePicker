//
//  NSObject+BKImagePicker.h
//  BKImagePicker
//
//  Created by BIKE on 2018/2/2.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (BKImagePicker)

/**
 字典Tag
 */
@property (nonatomic,strong) NSDictionary * bk_dicTag;

/**
 字符串Tag
 */
@property (nonatomic,strong) NSString * bk_strTag;

@end
