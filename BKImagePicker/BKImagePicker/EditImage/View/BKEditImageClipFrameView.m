//
//  BKEditImageClipFrameView.m
//  BKImagePicker
//
//  Created by BIKE on 2018/3/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageClipFrameView.h"
#import "BKTool.h"

@implementation BKEditImageClipFrameView

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self changeSelfFrame];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        [self changeSelfFrame];
    }
}

#pragma mark - changeSelfFrame

-(void)changeSelfFrame
{
    [[self.layer sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(0, 0)];
    [linePath addLineToPoint:CGPointMake(self.bk_width, 0)];
    [linePath addLineToPoint:CGPointMake(self.bk_width, self.bk_height)];
    [linePath addLineToPoint:CGPointMake(0, self.bk_height)];
    [linePath addLineToPoint:CGPointMake(0, 0)];
    
    [linePath moveToPoint:CGPointMake(self.bk_width/3, 0)];
    [linePath addLineToPoint:CGPointMake(self.bk_width/3, self.bk_height)];
    
    [linePath moveToPoint:CGPointMake(self.bk_width/3*2, 0)];
    [linePath addLineToPoint:CGPointMake(self.bk_width/3*2, self.bk_height)];
    
    [linePath moveToPoint:CGPointMake(0, self.bk_height/3)];
    [linePath addLineToPoint:CGPointMake(self.bk_width, self.bk_height/3)];
    
    [linePath moveToPoint:CGPointMake(0, self.bk_height/3*2)];
    [linePath addLineToPoint:CGPointMake(self.bk_width, self.bk_height/3*2)];
    
    CAShapeLayer * border  = [[CAShapeLayer alloc] init];
    border.frame = self.bounds;
    [border setLineWidth:1];
    [border setStrokeColor:[UIColor whiteColor].CGColor];
    [border setFillColor:[UIColor clearColor].CGColor];
    border.path = linePath.CGPath;
    [self.layer addSublayer:border];
    
    UIBezierPath * anglePath = [UIBezierPath bezierPath];
    
    [anglePath moveToPoint:CGPointMake(-1, 20)];
    [anglePath addLineToPoint:CGPointMake(-1, -1)];
    [anglePath addLineToPoint:CGPointMake(20, -1)];
    
    [anglePath moveToPoint:CGPointMake(self.bk_width + 1, 20)];
    [anglePath addLineToPoint:CGPointMake(self.bk_width + 1, -1)];
    [anglePath addLineToPoint:CGPointMake(self.bk_width - 20, -1)];
    
    [anglePath moveToPoint:CGPointMake(self.bk_width + 1, self.bk_height - 20)];
    [anglePath addLineToPoint:CGPointMake(self.bk_width + 1, self.bk_height + 1)];
    [anglePath addLineToPoint:CGPointMake(self.bk_width - 20, self.bk_height + 1)];
    
    [anglePath moveToPoint:CGPointMake(-1, self.bk_height - 20)];
    [anglePath addLineToPoint:CGPointMake(-1, self.bk_height + 1)];
    [anglePath addLineToPoint:CGPointMake(20, self.bk_height + 1)];
    
    CAShapeLayer * angle  = [[CAShapeLayer alloc] init];
    angle.frame = self.bounds;
    [angle setLineWidth:2];
    [angle setStrokeColor:[UIColor whiteColor].CGColor];
    [angle setFillColor:[UIColor clearColor].CGColor];
    angle.path = anglePath.CGPath;
    [self.layer addSublayer:angle];
}

@end
