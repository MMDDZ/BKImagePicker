//
//  UINavigationController+DSNavExtension.m
//  
//
//  Created by BIKE on 2018/7/12.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "UINavigationController+DSNavExtension.h"
#import "BKNavigationController.h"
#import <objc/message.h>

@implementation UINavigationController (DSNavExtension)

#pragma mark - direction

-(void)setDirection:(DSTransitionAnimaterDirection)direction
{
    if ([self isKindOfClass:[BKNavigationController class]]) {
        [self changeValue:@(direction) forProperty:@"_private_direction"];
    }
}

-(DSTransitionAnimaterDirection)direction
{
    if ([self isKindOfClass:[BKNavigationController class]]) {
        return [[self getValueForProperty:@"_private_direction"] intValue];
    }else{
        return 0;
    }
}

#pragma mark - popGestureRecognizerEnable

-(void)setPopGestureRecognizerEnable:(BOOL)popGestureRecognizerEnable
{
    if ([self isKindOfClass:[BKNavigationController class]]) {
        [self changeValue:@(popGestureRecognizerEnable) forProperty:@"_private_popGestureRecognizerEnable"];
    }
}

-(BOOL)popGestureRecognizerEnable
{
    if ([self isKindOfClass:[BKNavigationController class]]) {
        return [[self getValueForProperty:@"_private_popGestureRecognizerEnable"] boolValue];
    }else{
        return NO;
    }
}

#pragma mark - popVC

-(void)setPopVC:(UIViewController*)popVC
{
    if ([self isKindOfClass:[BKNavigationController class]]) {
        [self changeValue:popVC forProperty:@"_private_popVC"];
    }
}

-(UIViewController*)popVC
{
    if ([self isKindOfClass:[BKNavigationController class]]) {
        return [self getValueForProperty:@"_private_popVC"];
    }else{
        return nil;
    }
}

#pragma mark - 属性操作

/**
 改变对象属性的值
 
 @param value 值
 @param property 对象属性
 */
-(void)changeValue:(id)value forProperty:(NSString*)property
{
    u_int count = 0;
    Ivar * ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char * propertyName = ivar_getName(ivar);
        NSString * propertyString = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        if ([propertyString isEqualToString:property]) {
            //setValue:forKey: 若forKey传入的属性名前加下划线不会执行setter方法
            if ([[property substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"_"]) {//为了能执行setter方法
                [self setValue:value forKey:[property substringWithRange:NSMakeRange(1, [property length] - 1)]];
            }else{
                [self setValue:value forKey:property];
            }
            //            运行时赋值 不执行setter方法
            //            object_setIvar(self, ivar, value);
            break;
        }
    }
}

/**
 取出对象属性的值
 
 @param property 对象属性
 @return 值
 */
-(id)getValueForProperty:(NSString*)property
{
    u_int count = 0;
    Ivar * ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char * propertyName = ivar_getName(ivar);
        NSString * propertyString = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        if ([propertyString isEqualToString:property]) {
            return [self valueForKey:property];
            //            运行时取值 下面方法有时候会崩溃
            //            return object_getIvar(self, ivar);
        }
    }
    return nil;
}


@end
