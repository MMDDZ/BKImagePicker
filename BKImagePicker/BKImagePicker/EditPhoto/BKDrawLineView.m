//
//  BKDrawLineView.m
//  BKImagePicker
//
//  Created by 毕珂 on 2017/5/1.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKDrawLineView.h"

@interface BKDrawLineView()

//这一次画的数组
@property (nonatomic,strong) NSMutableArray *pointArray;
//之前保存画的数组
@property (nonatomic,strong) NSMutableArray *lineArray;

@property (nonatomic,assign) CGPoint beginPoint;

@end

@implementation BKDrawLineView

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

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, 5);
    
    //之前画的线
    if ([self.lineArray count]>0) {
        for (int i=0; i<[self.lineArray count]; i++) {
            
            NSDictionary * dic = self.lineArray[i];
            NSArray * array = [NSArray arrayWithArray:dic[@"point"]];
            
            if ([dic[@"type"] integerValue] == BKSelectTypeColor) {
                CGContextSetStrokeColorWithColor(context, ((UIColor*)dic[@"color"]).CGColor);
            }
            
            if ([array count]>0)  {
                
                CGContextBeginPath(context);
                CGPoint myStartPoint=CGPointFromString([array objectAtIndex:0]);
                CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
                
                for (int j=0; j<[array count]-1; j++)
                {
                    CGPoint myEndPoint=CGPointFromString([array objectAtIndex:j+1]);
                    CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);
                }
                
                CGContextStrokePath(context);
            }
        }
    }
    
    CGContextSetStrokeColorWithColor(context, self.selectColor.CGColor);
    
    //画当前的线
    if ([self.pointArray count]>0) {
        
        CGContextBeginPath(context);
        CGPoint myStartPoint=CGPointFromString([self.pointArray objectAtIndex:0]);
        CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
        
        for (int j=0; j<[self.pointArray count]-1; j++) {
            
            CGPoint myEndPoint=CGPointFromString([self.pointArray objectAtIndex:j+1]);
            CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);
        }
        
        CGContextStrokePath(context);
    }
}

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
        NSString * sPoint = NSStringFromCGPoint(point);
        [self.pointArray addObject:sPoint];
        [self setNeedsDisplay];
        
        if (self.movedOption) {
            self.movedOption();
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.pointArray count] > 0) {
        NSArray * array= [NSArray arrayWithArray:self.pointArray];
        [self.lineArray addObject:@{@"point":array,@"color":self.selectColor,@"type":@(self.selectType)}];
        [self.pointArray removeAllObjects];
    }
    
    if (self.moveEndOption) {
        self.moveEndOption();
    }
}

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

-(UIImage*)checkEditImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * okImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return okImage;
}

@end
