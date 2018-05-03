//
//  BKEditImageDrawView.m
//  BKImagePicker
//
//  Created by BIKE on 2017/6/21.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKEditImageDrawView.h"
#import "BKTool.h"

@interface BKEditImageDrawView()

@end

@implementation BKEditImageDrawView

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setBackgroundColor:[UIColor clearColor]];
}

-(NSMutableArray*)pointArray
{
    if (!_pointArray) {
        _pointArray = [NSMutableArray array];
    }
    return _pointArray;
}

-(NSMutableArray*)lineArray
{
    if (!_lineArray) {
        _lineArray = [NSMutableArray array];
    }
    return _lineArray;
}

#pragma mark - 清除

-(void)cleanAllDrawBySelf
{
    if ([self.lineArray count] > 0) {
        [self.lineArray removeAllObjects];
        [self setNeedsDisplay];
    }
}

-(void)cleanFinallyDraw
{
    if ([self.lineArray count] > 0) {
        [self.lineArray removeLastObject];
        [self setNeedsDisplay];
    }
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, 5);
    
    NSMutableArray * mosaicPointArr = [NSMutableArray array];
    
    //之前画的线
    if ([self.lineArray count] > 0) {
        for (int i = 0; i < [self.lineArray count]; i++) {
            BKEditImageDrawModel * model = self.lineArray[i];
            if (model.selectPaintingType == BKEditImageSelectPaintingTypeColor) {
                if (model.drawType == BKEditImageSelectEditTypeDrawLine || model.drawType == BKEditImageSelectEditTypeDrawRoundedRectangle) {
                    [self drawLine:context pointArr:model.pointArray lineColor:model.selectColor.CGColor];
                }else if (model.drawType == BKEditImageSelectEditTypeDrawCircle) {
                    [self drawCircle:context pointArr:model.pointArray lineColor:model.selectColor.CGColor];
                }else if (model.drawType == BKEditImageSelectEditTypeDrawArrow) {
                    [self drawArrow:context pointArr:model.pointArray lineColor:model.selectColor.CGColor];
                }
            }else if (model.selectPaintingType == BKEditImageSelectPaintingTypeMosaic) {
                if ([model.pointArray count] > 0) {
                    [mosaicPointArr addObject:model.pointArray];
                }
            }
        }
    }
    
    //画当前的线
    if (self.selectPaintingType == BKEditImageSelectPaintingTypeColor) {
        if (self.drawType == BKEditImageSelectEditTypeDrawLine || self.drawType == BKEditImageSelectEditTypeDrawRoundedRectangle) {
            [self drawLine:context pointArr:[self.pointArray copy] lineColor:self.selectColor.CGColor];
        }else if (self.drawType == BKEditImageSelectEditTypeDrawCircle) {
            [self drawCircle:context pointArr:[self.pointArray copy] lineColor:self.selectColor.CGColor];
        }else if (self.drawType == BKEditImageSelectEditTypeDrawArrow) {
            [self drawArrow:context pointArr:[self.pointArray copy] lineColor:self.selectColor.CGColor];
        }
    }else if (self.selectPaintingType == BKEditImageSelectPaintingTypeMosaic) {
        if ([self.pointArray count] > 0) {
            [mosaicPointArr addObject:self.pointArray];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(processingMosaicImageWithPathArr:)]) {
        [self.delegate processingMosaicImageWithPathArr:[mosaicPointArr copy]];
    }
}

/**
 画线

 @param context CGContextRef
 @param pointArr 点的数组
 @param lineColor 线的颜色
 */
-(void)drawLine:(CGContextRef)context pointArr:(NSArray*)pointArr lineColor:(CGColorRef)lineColor
{
    if ([pointArr count] > 0) {
        
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, lineColor);
        CGPoint startPoint = CGPointFromString([NSString stringWithFormat:@"%@",pointArr[0]]);
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        
        for (int i = 0; i < [pointArr count]-1; i++) {
            CGPoint endPoint = CGPointFromString([NSString stringWithFormat:@"%@",pointArr[i+1]]);
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
        }
        
        CGContextStrokePath(context);
    }
}

/**
 画圆

 @param context CGContextRef
 @param pointArr 点的数组
 @param lineColor 线的颜色
 */
-(void)drawCircle:(CGContextRef)context pointArr:(NSArray*)pointArr lineColor:(CGColorRef)lineColor
{
    if ([pointArr count] >= 2) {
        
        CGPoint beginPoint = CGPointFromString([NSString stringWithFormat:@"%@",pointArr[0]]);
        CGPoint endPoint = CGPointFromString([NSString stringWithFormat:@"%@",pointArr[1]]);
        
        CGFloat x = endPoint.x > beginPoint.x ? beginPoint.x : endPoint.x;
        CGFloat y = endPoint.y > beginPoint.y ? beginPoint.y : endPoint.y;
        CGFloat width = fabs(endPoint.x - beginPoint.x);
        CGFloat height = fabs(endPoint.y - beginPoint.y);
        
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, lineColor);
        CGContextAddEllipseInRect(context, CGRectMake(x, y, width, height));
        CGContextStrokePath(context);
    }
}

/**
 画箭头
 
 @param context CGContextRef
 @param pointArr 点的数组
 @param lineColor 线的颜色
 */
-(void)drawArrow:(CGContextRef)context pointArr:(NSArray*)pointArr lineColor:(CGColorRef)lineColor
{
    if ([pointArr count] >= 2) {
        
        CGPoint beginPoint = CGPointFromString([NSString stringWithFormat:@"%@",pointArr[0]]);
        CGPoint endPoint = CGPointFromString([NSString stringWithFormat:@"%@",pointArr[1]]);
        
        CGContextBeginPath(context);
        CGContextSetFillColorWithColor(context, lineColor);
        
        CGFloat x_length = fabs(endPoint.x - beginPoint.x);
        CGFloat y_length = fabs(endPoint.y - beginPoint.y);
        CGFloat angle = atan(y_length/x_length) / M_PI * 180;
        //算出目前方向角度 以右边水平线0开始
        CGFloat direction_angle;
        if (beginPoint.x < endPoint.x) {
            if (beginPoint.y < endPoint.y) {
                direction_angle = 360 - angle;
            }else{
                direction_angle = angle;
            }
        }else{
            if (beginPoint.y < endPoint.y) {
                direction_angle = angle + 180;
            }else{
                direction_angle = 90 + 90 - angle;
            }
        }
        
        //起点到终点距离
        CGFloat xy_length = fabs(sqrt(pow(beginPoint.x - endPoint.x, 2)+pow(beginPoint.y - endPoint.y, 2)));
        
        //尾部圆半径
        CGFloat r = (xy_length/10)>2?2:(xy_length/10);
        //弧度
        CGFloat radian = (270 - direction_angle) / 180 * M_PI;
        //弧度两端的点
        CGFloat left_arc_x = cos(radian) * r + beginPoint.x;
        CGFloat left_arc_y = sin(radian) * r + beginPoint.y;
        CGFloat right_arc_x = -cos(radian) * r + beginPoint.x;
        CGFloat right_arc_y = -sin(radian) * r + beginPoint.y;
        
        //以弧度左端点开始画
        CGContextMoveToPoint(context, left_arc_x, left_arc_y);
        
        //箭头边长
        CGFloat triangle_length = (xy_length/2)>20?20:(xy_length/2);
        //箭头顶角角度(目前箭头为等边三角形)
        CGFloat triangle_angle = 60;
        //三角形顶点到第三边的距离
        CGFloat triangle_center_length = sin(triangle_angle/180*M_PI) * triangle_length;
        //圆心到三角行第三遍距离 再往内延伸三角形顶点到第三边的距离的1/6边长
        CGFloat cirleCenter_triangle_length = xy_length - triangle_center_length/6*5;
        
        //三角形第三边到弧度两端点的x距离与y距离
        CGFloat cirleCenter_triangle_x = cos(angle / 180 * M_PI) * cirleCenter_triangle_length;
        CGFloat cirleCenter_triangle_y = sin(angle / 180 * M_PI) * cirleCenter_triangle_length;
        
        //根据方向算出四个方向角度的坐标
        if (direction_angle >= 0 && direction_angle < 90) {
            
            CGContextAddLineToPoint(context, left_arc_x + cirleCenter_triangle_x, left_arc_y - cirleCenter_triangle_y);
            
            if (angle < triangle_angle/2) {
                CGFloat triangle_left_outside_radian = (triangle_angle/2 - (90 - (90 - angle)))/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_left_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_left_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x - triangle_cos, endPoint.y - triangle_sin);
            }else{
                CGFloat triangle_left_outside_radian = ((90 - (90 - angle)) - triangle_angle/2)/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_left_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_left_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x - triangle_cos, endPoint.y + triangle_sin);
            }
            
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            
            if (angle < triangle_angle) {
                CGFloat triangle_right_outside_radian = ((90 - angle) - triangle_angle/2)/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_right_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_right_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x - triangle_sin, endPoint.y + triangle_cos);
                
            }else{
                CGFloat triangle_right_outside_radian = (triangle_angle/2 - (90 - angle))/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_right_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_right_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x + triangle_sin, endPoint.y + triangle_cos);
            }
            
            CGContextAddLineToPoint(context, right_arc_x + cirleCenter_triangle_x, right_arc_y - cirleCenter_triangle_y);
            
        }else if (direction_angle >= 90 && direction_angle < 180) {
            
            CGContextAddLineToPoint(context, left_arc_x - cirleCenter_triangle_x, left_arc_y - cirleCenter_triangle_y);
            
            if (angle < triangle_angle) {
                CGFloat triangle_left_outside_radian = ((90 - angle) - triangle_angle/2)/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_left_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_left_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x + triangle_sin, endPoint.y + triangle_cos);
            }else{
                
                CGFloat triangle_left_outside_radian = (triangle_angle/2 - (90 - angle))/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_left_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_left_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x - triangle_sin, endPoint.y + triangle_cos);
            }
            
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            
            if (angle < triangle_angle/2) {
                CGFloat triangle_right_outside_radian = (triangle_angle/2 - (90 - (90 - angle)))/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_right_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_right_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x + triangle_cos, endPoint.y - triangle_sin);
            }else{
                CGFloat triangle_right_outside_radian = ((90 - (90 - angle)) - triangle_angle/2)/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_right_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_right_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x + triangle_cos, endPoint.y + triangle_sin);
            }
            
            CGContextAddLineToPoint(context, right_arc_x - cirleCenter_triangle_x, right_arc_y - cirleCenter_triangle_y);
            
        }else if (direction_angle >= 180 && direction_angle < 270) {
            
            CGContextAddLineToPoint(context, left_arc_x - cirleCenter_triangle_x, left_arc_y + cirleCenter_triangle_y);
            
            if (angle < triangle_angle/2) {
                CGFloat triangle_left_outside_radian = (triangle_angle/2 - (90 - (90 - angle)))/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_left_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_left_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x + triangle_cos, endPoint.y + triangle_sin);
            }else{
                CGFloat triangle_left_outside_radian = ((90 - (90 - angle)) - triangle_angle/2)/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_left_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_left_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x + triangle_cos, endPoint.y - triangle_sin);
            }
            
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            
            if (angle < triangle_angle) {
                CGFloat triangle_right_outside_radian = ((90 - angle) - triangle_angle/2)/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_right_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_right_outside_radian) * triangle_length;
                
                
                CGContextAddLineToPoint(context, endPoint.x + triangle_sin, endPoint.y - triangle_cos);
                
            }else{
                CGFloat triangle_right_outside_radian = (triangle_angle/2 - (90 - angle))/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_right_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_right_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x - triangle_sin, endPoint.y - triangle_cos);
            }
            
            CGContextAddLineToPoint(context, right_arc_x - cirleCenter_triangle_x, right_arc_y + cirleCenter_triangle_y);
            
        }else if (direction_angle >= 270 && direction_angle < 360) {
            
            CGContextAddLineToPoint(context, left_arc_x + cirleCenter_triangle_x, left_arc_y + cirleCenter_triangle_y);
            
            if (angle < triangle_angle) {
                CGFloat triangle_left_outside_radian = ((90 - angle) - triangle_angle/2)/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_left_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_left_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x - triangle_sin, endPoint.y - triangle_cos);
            }else{
                
                CGFloat triangle_left_outside_radian = (triangle_angle/2 - (90 - angle))/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_left_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_left_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x + triangle_sin, endPoint.y - triangle_cos);
            }
            
            CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
            
            if (angle < triangle_angle/2) {
                CGFloat triangle_right_outside_radian = (triangle_angle/2 - (90 - (90 - angle)))/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_right_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_right_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x - triangle_cos, endPoint.y + triangle_sin);
            }else{
                CGFloat triangle_right_outside_radian = ((90 - (90 - angle)) - triangle_angle/2)/180*M_PI;
                
                CGFloat triangle_cos = cos(triangle_right_outside_radian) * triangle_length;
                CGFloat triangle_sin = sin(triangle_right_outside_radian) * triangle_length;
                
                CGContextAddLineToPoint(context, endPoint.x - triangle_cos, endPoint.y - triangle_sin);
            }
            
            CGContextAddLineToPoint(context, right_arc_x + cirleCenter_triangle_x, right_arc_y + cirleCenter_triangle_y);
            
        }
        
        //弧度右端点
        CGContextAddLineToPoint(context, right_arc_x, right_arc_y);
        //开始点为圆心 r为半径 画圆
        CGContextAddArc(context, beginPoint.x, beginPoint.y, r, 0, M_PI*2, 0);
        //缝合(没啥用 以上代码已完全联合)
        CGContextClosePath(context);
        
        CGContextFillPath(context);
    }
}

#pragma mark - 画线

-(void)drawLineWithPoint:(CGPoint)point
{
    NSString * sPoint = NSStringFromCGPoint(point);
    [self.pointArray addObject:sPoint];
    
    [self setNeedsDisplay];
}

#pragma mark - 画圆角矩形

-(void)drawRoundedRectangleWithPoint:(CGPoint)point
{
    CGFloat x = point.x > self.beginPoint.x ? self.beginPoint.x : point.x;
    CGFloat y = point.y > self.beginPoint.y ? self.beginPoint.y : point.y;
    CGFloat width = fabs(point.x - self.beginPoint.x);
    CGFloat height = fabs(point.y - self.beginPoint.y);
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, width, height) cornerRadius:4];
    [self.pointArray removeAllObjects];
    [self.pointArray addObjectsFromArray:[path bk_points]];
    
    [self setNeedsDisplay];
}

#pragma mark - 画圆

-(void)drawCircleWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint
{
    [self.pointArray removeAllObjects];
    [self.pointArray addObject:NSStringFromCGPoint(beginPoint)];
    [self.pointArray addObject:NSStringFromCGPoint(endPoint)];
    
    [self setNeedsDisplay];
}

#pragma mark - 画箭头

-(void)drawArrowWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint
{
    [self.pointArray removeAllObjects];
    [self.pointArray addObject:NSStringFromCGPoint(beginPoint)];
    [self.pointArray addObject:NSStringFromCGPoint(endPoint)];
    
    [self setNeedsDisplay];
}

@end
