//
//  UIViewController+BKExpand.m
//  BKImagePicker
//
//  Created by 毕珂 on 16/12/25.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "UIViewController+BKExpand.h"

@implementation UIViewController (BKExpand)

@end

@implementation UINavigationController (ShouldPopOnBackButton)

-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem*)item
{
    if([self.viewControllers count] < [navigationBar.items count]) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    UIViewController* vc = [self topViewController];
    if([vc respondsToSelector:@selector(navigationShouldPopOnBackItem)]) {
        shouldPop = [vc navigationShouldPopOnBackItem];
    }
    
    if(shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    } else {
        for(UIView *subview in [navigationBar subviews]) {
            if(subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
    }
    
    return NO;
}

@end
