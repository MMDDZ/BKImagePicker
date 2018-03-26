//
//  BKEditImageClipFrameView.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/3/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageClipFrameView.h"
#import "BKImagePickerConst.h"

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
    
    CGFloat width = 0;
    CGFloat height = 0;
    if (_rotation == BKEditImageRotationPortrait || _rotation == BKEditImageRotationUpsideDown) {
        width = self.bk_width;
        height = self.bk_height;
    }else{
        width = self.bk_height;
        height = self.bk_width;
    }
    
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(0, 0)];
    [linePath addLineToPoint:CGPointMake(width, 0)];
    [linePath addLineToPoint:CGPointMake(width, height)];
    [linePath addLineToPoint:CGPointMake(0, height)];
    [linePath addLineToPoint:CGPointMake(0, 0)];
    
    [linePath moveToPoint:CGPointMake(width/3, 0)];
    [linePath addLineToPoint:CGPointMake(width/3, height)];
    
    [linePath moveToPoint:CGPointMake(width/3*2, 0)];
    [linePath addLineToPoint:CGPointMake(width/3*2, height)];
    
    [linePath moveToPoint:CGPointMake(0, height/3)];
    [linePath addLineToPoint:CGPointMake(width, height/3)];
    
    [linePath moveToPoint:CGPointMake(0, height/3*2)];
    [linePath addLineToPoint:CGPointMake(width, height/3*2)];
    
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
    
    [anglePath moveToPoint:CGPointMake(width + 1, 20)];
    [anglePath addLineToPoint:CGPointMake(width + 1, -1)];
    [anglePath addLineToPoint:CGPointMake(width - 20, -1)];
    
    [anglePath moveToPoint:CGPointMake(width + 1, height - 20)];
    [anglePath addLineToPoint:CGPointMake(width + 1, height + 1)];
    [anglePath addLineToPoint:CGPointMake(width - 20, height + 1)];
    
    [anglePath moveToPoint:CGPointMake(-1, height - 20)];
    [anglePath addLineToPoint:CGPointMake(-1, height + 1)];
    [anglePath addLineToPoint:CGPointMake(20, height + 1)];
    
    CAShapeLayer * angle  = [[CAShapeLayer alloc] init];
    angle.frame = self.bounds;
    [angle setLineWidth:2];
    [angle setStrokeColor:[UIColor whiteColor].CGColor];
    [angle setFillColor:[UIColor clearColor].CGColor];
    angle.path = anglePath.CGPath;
    [self.layer addSublayer:angle];
}

@end
