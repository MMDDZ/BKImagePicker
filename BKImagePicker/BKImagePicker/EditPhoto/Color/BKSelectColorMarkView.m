//
//  BKSelectColorMarkView.m
//  BKImagePicker
//
//  Created by 毕珂 on 2017/5/12.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKSelectColorMarkView.h"

@implementation BKSelectColorMarkView

-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 40, 30)];
    if (self) {
        
        UIBezierPath * path = [UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointMake(15, 15) radius:15 startAngle:M_PI/4 endAngle:M_PI*2-M_PI/4 clockwise:YES];
        [path addLineToPoint:CGPointMake(37.5, 15)];
        [path closePath];
        
        CAShapeLayer * layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        layer.path = path.CGPath;
        self.layer.mask = layer;
    }
    return self;
}

-(void)setSelectColor:(UIColor *)selectColor
{
    self.image = nil;
    _selectColor = selectColor;
    
    self.backgroundColor = _selectColor;
}

-(void)setSelectType:(BKSelectType)selectType
{
    self.backgroundColor = nil;
    _selectType = selectType;
    
    switch (_selectType) {
        case BKSelectTypeMaSaiKe:
        {
            NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
            bundlePath = [bundlePath stringByAppendingString:@"/masaike_mark.png"];
            self.image = [UIImage imageWithContentsOfFile:bundlePath];
        }
            break;
            
        default:
            break;
    }
}

@end
