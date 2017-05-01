//
//  BKEditGradientView.m
//  BKImagePicker
//
//  Created by 毕珂 on 2017/5/1.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKEditGradientView.h"

@implementation BKEditGradientView

-(instancetype)initWithFrame:(CGRect)frame topColor:(UIColor*)topColor bottomColor:(UIColor*)bottomColor
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)topColor.CGColor, (__bridge id)bottomColor.CGColor];
        gradientLayer.locations = @[@0.0, @1.0];
        gradientLayer.startPoint = CGPointMake(0.5, 0);
        gradientLayer.endPoint = CGPointMake(0.5, 1);
        gradientLayer.frame = self.bounds;
        [self.layer addSublayer:gradientLayer];
        
    }
    return self;
}

@end
