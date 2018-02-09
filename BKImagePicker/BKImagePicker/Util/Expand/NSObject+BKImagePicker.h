//
//  NSObject+BKImagePicker.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/2.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (BKExpand)

/**
 字典Tag
 */
@property (nonatomic,strong) NSDictionary * dicTag;

/**
 字符串Tag
 */
@property (nonatomic,strong) NSString * strTag;

@end
