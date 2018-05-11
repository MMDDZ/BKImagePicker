//
//  UIView+BKImagePicker.m
//  BKImagePicker
//
//  Created by BIKE on 16/12/30.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "UIView+BKImagePicker.h"

@implementation UIView (BKImagePicker)

-(void)setBk_x:(CGFloat)bk_x
{
    self.frame = CGRectMake(bk_x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

-(CGFloat)bk_x
{
    return self.frame.origin.x;
}

-(void)setBk_y:(CGFloat)bk_y
{
    self.frame = CGRectMake(self.frame.origin.x, bk_y, self.frame.size.width, self.frame.size.height);
}


-(CGFloat)bk_y
{
    return self.frame.origin.y;
}

-(void)setBk_width:(CGFloat)bk_width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, bk_width, self.frame.size.height);
}

-(CGFloat)bk_width
{
    return self.frame.size.width;
}

-(void)setBk_height:(CGFloat)bk_height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, bk_height);
}

-(CGFloat)bk_height
{
    return self.frame.size.height;
}

-(void)setBk_centerX:(CGFloat)bk_centerX
{
    CGPoint point = self.center;
    point.x = bk_centerX;
    self.center = point;
}

-(CGFloat)bk_centerX
{
    return self.center.x;
}

-(void)setBk_centerY:(CGFloat)bk_centerY
{
    CGPoint point = self.center;
    point.y = bk_centerY;
    self.center = point;
}

-(CGFloat)bk_centerY
{
    return self.center.y;
}

@end
