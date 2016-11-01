//
//  UINavigationItem+margin.m
//  BKImagePicker
//
//  Created by iMac on 16/11/1.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "UINavigationItem+margin.h"

@implementation UINavigationItem (margin)

- (void)setRightBarButtonItem:(UIBarButtonItem *)_rightBarButtonItem
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeperator.width = -12;
        
        if (_rightBarButtonItem) {
            [self setRightBarButtonItems:@[negativeSeperator, _rightBarButtonItem]];
        }else {
            [self setRightBarButtonItems:@[negativeSeperator]];
        }
        
    }else {
        [self setRightBarButtonItem:_rightBarButtonItem animated:NO];
    }
}

@end
