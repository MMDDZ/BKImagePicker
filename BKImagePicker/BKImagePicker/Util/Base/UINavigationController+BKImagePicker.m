//
//  UINavigationController+BKImagePicker.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/7/3.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "UINavigationController+BKImagePicker.h"
#import "BKImageNavViewController.h"

@implementation UINavigationController (BKImagePicker)

#pragma mark - direction

-(void)setBk_direction:(BKImageTransitionAnimaterDirection)bk_direction
{
    if ([self isKindOfClass:[BKImageNavViewController class]]) {
        BKImageNavViewController * cs_navigation = (BKImageNavViewController*)self;
        cs_navigation.direction = bk_direction;
    }
}

-(BKImageTransitionAnimaterDirection)bk_direction
{
    if ([self isKindOfClass:[BKImageNavViewController class]]) {
        BKImageNavViewController * cs_navigation = (BKImageNavViewController*)self;
        return cs_navigation.direction;
    }else{
        return NO;
    }
}

#pragma mark - popGestureRecognizerEnable

-(void)setBk_popGestureRecognizerEnable:(BOOL)bk_popGestureRecognizerEnable
{
    if ([self isKindOfClass:[BKImageNavViewController class]]) {
        BKImageNavViewController * cs_navigation = (BKImageNavViewController*)self;
        cs_navigation.popGestureRecognizerEnable = bk_popGestureRecognizerEnable;
    }
}

-(BOOL)bk_popGestureRecognizerEnable
{
    if ([self isKindOfClass:[BKImageNavViewController class]]) {
        BKImageNavViewController * cs_navigation = (BKImageNavViewController*)self;
        return cs_navigation.popGestureRecognizerEnable;
    }else{
        return NO;
    }
}

#pragma mark - popVC

-(void)setBk_popVC:(UIViewController*)bk_popVC
{
    if ([self isKindOfClass:[BKImageNavViewController class]]) {
        BKImageNavViewController * cs_navigation = (BKImageNavViewController*)self;
        cs_navigation.popVC = bk_popVC;
    }
}

-(UIViewController*)bk_popVC
{
    if ([self isKindOfClass:[BKImageNavViewController class]]) {
        BKImageNavViewController * cs_navigation = (BKImageNavViewController*)self;
        return cs_navigation.popVC;
    }else{
        return nil;
    }
}

@end
