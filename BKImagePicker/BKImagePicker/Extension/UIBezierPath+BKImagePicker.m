//
//  UIBezierPath+BKImagePicker.m
//  BKImagePicker
//
//  Created by BIKE on 2017/6/21.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "UIBezierPath+BKImagePicker.h"

#define VALUE(_INDEX_) [NSValue valueWithCGPoint:points[_INDEX_]]

@implementation UIBezierPath (BKImagePicker)

void getPointsFromBezier(void *info, const CGPathElement *element)
{
    NSMutableArray *bezierPoints = (__bridge NSMutableArray *)info;
    CGPathElementType type = element->type;
    CGPoint *points = element->points;
    
    if (type != kCGPathElementCloseSubpath) {
        [bezierPoints addObject:VALUE(0)];
        if ((type != kCGPathElementAddLineToPoint) && (type != kCGPathElementMoveToPoint)) {
            [bezierPoints addObject:VALUE(1)];
        }
    }
    
    if (type == kCGPathElementAddCurveToPoint) {
        [bezierPoints addObject:VALUE(2)];
    }
}

- (NSArray *)bk_points
{
    NSMutableArray *points = [NSMutableArray array];
    CGPathApply(self.CGPath, (__bridge void *)points, getPointsFromBezier);
    return [points copy];
}

@end
