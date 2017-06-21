//
//  BKDrawView.m
//  BKImagePicker
//
//  Created by 兆林 on 2017/6/21.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKDrawView.h"
#import "UIBezierPath+BKExpand.h"
#import "BKImagePickerConst.h"
#import "BKDrawModel.h"

@interface BKDrawView()

//这一次画的数组
@property (nonatomic,strong) NSMutableArray * pointArray;
//之前保存画的数组model
@property (nonatomic,strong) NSMutableArray<BKDrawModel*> * lineArray;

@property (nonatomic,assign) CGPoint beginPoint;

@end

@implementation BKDrawView

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

#pragma mark - 生成图片

-(UIImage*)checkEditImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, 5);
    
    //之前画的线
    if ([self.lineArray count]>0) {
        for (int i = 0; i < [self.lineArray count]; i++) {
            BKDrawModel * model = self.lineArray[i];
            if (model.drawType == BKDrawTypeLine || model.drawType == BKDrawTypeRoundedRectangle) {
                [self drawLine:context pointArr:model.pointArray lineColor:model.selectColor.CGColor];
            }else if (model.drawType == BKDrawTypeCircle) {
                [self drawCircle:context pointArr:model.pointArray lineColor:model.selectColor.CGColor];
            }
        }
    }
    
    //画当前的线
    if (self.drawType == BKDrawTypeLine || self.drawType == BKDrawTypeRoundedRectangle) {
        [self drawLine:context pointArr:[self.pointArray copy] lineColor:self.selectColor.CGColor];
    }else if (self.drawType == BKDrawTypeCircle) {
        [self drawCircle:context pointArr:[self.pointArray copy] lineColor:self.selectColor.CGColor];
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
    if ([pointArr count]>0) {
        
        CGContextBeginPath(context);
        CGContextSetStrokeColorWithColor(context, lineColor);
        CGPoint startPoint = CGPointFromString([NSString stringWithFormat:@"%@",pointArr[0]]);
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        
        for (int j = 0; j < [pointArr count]-1; j++) {
            CGPoint endPoint = CGPointFromString([NSString stringWithFormat:@"%@",pointArr[j+1]]);
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

#pragma mark - 手势

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    self.beginPoint = point;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (self.beginPoint.x != point.x || self.beginPoint.y != point.y) {
        switch (self.drawType) {
            case BKDrawTypeLine:
            {
                [self drawLineWithPoint:point];
            }
                break;
            case BKDrawTypeRoundedRectangle:
            {
                [self drawRoundedRectangleWithPoint:point];
            }
                break;
            case BKDrawTypeCircle:
            {
                [self drawCircleWithBeginPoint:self.beginPoint endPoint:point];
            }
                break;
            case BKDrawTypeArrow:
            {
                
            }
                break;
            default:
                break;
        }
        [self setNeedsDisplay];
        
        if (self.movedOption) {
            self.movedOption();
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.pointArray count] > 0) {
        
        BKDrawModel * model = [[BKDrawModel alloc]init];
        model.pointArray = [self.pointArray copy];
        model.selectColor = self.selectColor;
        model.selectType = self.selectType;
        model.drawType = self.drawType;
        
        [self.lineArray addObject:model];
        [self.pointArray removeAllObjects];
    }
    
    if (self.moveEndOption) {
        self.moveEndOption();
    }
}

#pragma mark - 画线

-(void)drawLineWithPoint:(CGPoint)point
{
    NSString * sPoint = NSStringFromCGPoint(point);
    [self.pointArray addObject:sPoint];
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
    [self.pointArray addObjectsFromArray:[path points]];
}

#pragma mark - 画圆

-(void)drawCircleWithBeginPoint:(CGPoint)beginPoint endPoint:(CGPoint)endPoint
{
    [self.pointArray removeAllObjects];
    [self.pointArray addObject:NSStringFromCGPoint(beginPoint)];
    [self.pointArray addObject:NSStringFromCGPoint(endPoint)];
}

@end
