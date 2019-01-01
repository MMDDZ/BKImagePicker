//
//  BKCameraFocusRectangle.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKCameraFocusRectangle.h"
#import "BKImagePickerMacro.h"
#import "UIView+BKImagePicker.h"

const float kLineW = 2;//线宽
const float kHalfLineW = 1;//线宽的一半长
const float kTrebleLineW = 6;//线宽的三倍长
const float kSpaceOfFocusAndSun = 6;//聚焦框和太阳之间的距离
const float kSunTotalL = 50;//太阳总长 = (kSunSpace + kSunLightL + kSunCircleR)*2
const float kSunSpace = 6;//太阳线与其他的间距
const float kSunLightL = 9;//太阳光线长
const float kSunCircleR = 10;//太阳圆半径

@interface BKCameraFocusRectangle()

@property (nonatomic,assign) CGFloat focusW;
@property (nonatomic,assign) CGFloat focusH;
@property (nonatomic,assign) CGFloat sunW;
@property (nonatomic,assign) CGFloat sunH;
@property (nonatomic,assign) CGFloat spaceOfFocusAndSun;//聚焦框和太阳之间的距离
@property (nonatomic,assign) CGFloat sunTotalL;//太阳总长 = (sunSpace + sunLightL + sunCircleR)*2
@property (nonatomic,assign) CGFloat sunSpace;//太阳线与其他的间距
@property (nonatomic,assign) CGFloat sunLightL;//太阳光线长
@property (nonatomic,assign) CGFloat sunCircleR;//太阳圆半径

@property (nonatomic,assign) CGPoint initPoint;
@property (nonatomic,assign) CGFloat drawFocus_x_increment;//画聚焦框时x的增量
@property (nonatomic,assign) CGFloat drawSun_x_increment;//画聚焦框时x的增量

@end

@implementation BKCameraFocusRectangle
@synthesize isDisplaySun = _isDisplaySun;

#pragma mark - sunLevel

-(void)setSunLevel:(CGFloat)sunLevel
{
    _sunLevel = sunLevel;
    [self setNeedsDisplay];
}

#pragma mark - get

-(CGFloat)focusW
{
    if (_focusW == 0) {
        _focusW = BK_SCREENW/3;
    }
    return _focusW;
}

-(CGFloat)focusH
{
    if (_focusH == 0) {
        _focusH = BK_SCREENW/3;
    }
    return _focusH;
}

-(CGFloat)sunW
{
    if (_sunW == 0) {
        _sunW = self.sunTotalL;
    }
    return _sunW;
}

-(CGFloat)sunH
{
    if (_sunH == 0) {
        _sunH = self.sunW;
    }
    return _sunH;
}

-(CGFloat)spaceOfFocusAndSun
{
    if (_spaceOfFocusAndSun == 0) {
        _spaceOfFocusAndSun = kSpaceOfFocusAndSun * BK_SCREENW / 375.0f;
    }
    return _spaceOfFocusAndSun;
}

-(CGFloat)sunTotalL
{
    if (_sunTotalL == 0) {
        _sunTotalL = kSunTotalL * BK_SCREENW / 375.0f;
    }
    return _sunTotalL;
}

-(CGFloat)sunSpace
{
    if (_sunSpace == 0) {
        _sunSpace = kSunSpace * BK_SCREENW / 375.0f;
    }
    return _sunSpace;
}

-(CGFloat)sunLightL
{
    if (_sunLightL == 0) {
        _sunLightL = kSunLightL * BK_SCREENW / 375.0f;
    }
    return _sunLightL;
}

-(CGFloat)sunCircleR
{
    if (_sunCircleR == 0) {
        _sunCircleR = kSunCircleR * BK_SCREENW / 375.0f;
    }
    return _sunCircleR;
}

#pragma mark - init

-(instancetype)initWithPoint:(CGPoint)point
{
    self = [super initWithFrame:CGRectMake(0, 0, self.focusW, self.focusH)];
    if (self) {
        
        self.initPoint = point;
        _isDisplaySun = NO;
       
        self.center = point;
        
        self.userInteractionEnabled = NO;
        self.clipsToBounds = NO;
        self.backgroundColor = BKClearColor;
    }
    return self;
}

-(instancetype)initWithPoint:(CGPoint)point sunLevel:(CGFloat)sunLevel
{
    self = [super initWithFrame:CGRectMake(0, 0, self.focusW + self.sunW + self.spaceOfFocusAndSun, self.focusH + self.sunH * 2)];
    if (self) {
        
        self.initPoint = point;
        _isDisplaySun = YES;
        self.sunLevel = sunLevel;
        
        if (point.x <= BK_SCREENW/2) {
            self.bk_centerX = point.x + self.sunW/2 + self.spaceOfFocusAndSun/2;
            self.drawFocus_x_increment = 0;
            self.drawSun_x_increment = self.focusW + self.spaceOfFocusAndSun;
        }else{
            self.bk_centerX = point.x - self.sunW/2 - self.spaceOfFocusAndSun/2;
            self.drawFocus_x_increment = self.sunW + self.spaceOfFocusAndSun;
            self.drawSun_x_increment = 0;
        }
        self.bk_centerY = point.y;
        
        self.userInteractionEnabled = NO;
        self.clipsToBounds = NO;
        self.backgroundColor = BKClearColor;
    }
    return self;
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kLineW);
    CGContextSetStrokeColorWithColor(context, BKCameraFocusBackgroundColor.CGColor);
    
    //聚焦框
    NSArray * focusLineArr = @[@[@(CGPointMake(kHalfLineW, kHalfLineW)),
                                 @(CGPointMake(self.focusW - kHalfLineW, kHalfLineW)),
                                 @(CGPointMake(self.focusW - kHalfLineW, self.focusH - kHalfLineW)),
                                 @(CGPointMake(kHalfLineW, self.focusH - kHalfLineW)),
                                 @(CGPointMake(kHalfLineW, kHalfLineW))],
                               @[@(CGPointMake(self.focusW/2, kLineW)),
                                 @(CGPointMake(self.focusW/2, kLineW + kTrebleLineW))],
                               @[@(CGPointMake(self.focusW - kLineW, self.focusH/2)),
                                 @(CGPointMake(self.focusW - kLineW - kTrebleLineW, self.focusH/2))],
                               @[@(CGPointMake(self.focusW/2, self.focusH - kLineW)),
                                 @(CGPointMake(self.focusW/2, self.focusH - kLineW - kTrebleLineW))],
                               @[@(CGPointMake(kLineW, self.focusH/2)),
                                 @(CGPointMake(kLineW + kTrebleLineW, self.focusH/2))]];
    for (NSArray * arr in focusLineArr) {
        [self context:context drawFocusLineArr:arr];
    }
    
    if (self.isDisplaySun) {
        //太阳
        CGFloat totalH = self.focusH + self.sunH*2;
        CGFloat normalL = (totalH - (self.sunH + self.sunSpace*2 + kHalfLineW*2))/2;
        CGFloat topL = 0;
        CGFloat bottomL = 0;
        if (self.sunLevel > 0) {
            topL = (1 - self.sunLevel) * normalL;
            bottomL = normalL*2 - topL;
        }else if (self.sunLevel < 0) {
            bottomL = -(-1 - self.sunLevel) * normalL;
            topL = normalL*2 - bottomL;
        }else{
            topL = normalL;
            bottomL = normalL;
        }
        
        CGPoint originalPoint = CGPointMake(self.sunW/2, kHalfLineW + topL + self.sunSpace + self.sunLightL + self.sunSpace + self.sunCircleR);
        CGFloat start_hypotenuseL = self.sunLightL + self.sunSpace + self.sunCircleR;//开始点斜边长
        CGFloat end_hypotenuseL = self.sunSpace + self.sunCircleR;//结束点斜边长
        
        CGPoint point1_start = CGPointMake(originalPoint.x, originalPoint.y - self.sunCircleR - self.sunSpace - self.sunLightL);
        CGPoint point1_end = CGPointMake(originalPoint.x, originalPoint.y - self.sunCircleR - self.sunSpace);
        
        CGPoint point2_start = CGPointMake(originalPoint.x + cos(M_PI_4)*start_hypotenuseL, originalPoint.y + sin(M_PI_4)*start_hypotenuseL);
        CGPoint point2_end = CGPointMake(originalPoint.x + cos(M_PI_4)*end_hypotenuseL, originalPoint.y + sin(M_PI_4)*end_hypotenuseL);
        
        CGPoint point3_start = CGPointMake(originalPoint.x + self.sunCircleR + self.sunSpace + self.sunLightL, originalPoint.y);
        CGPoint point3_end = CGPointMake(originalPoint.x + self.sunCircleR + self.sunSpace, originalPoint.y);
        
        CGPoint point4_start = CGPointMake(originalPoint.x + cos(M_PI_4)*start_hypotenuseL, originalPoint.y - sin(M_PI_4)*start_hypotenuseL);
        CGPoint point4_end = CGPointMake(originalPoint.x + cos(M_PI_4)*end_hypotenuseL, originalPoint.y - sin(M_PI_4)*end_hypotenuseL);
        
        CGPoint point5_start = CGPointMake(originalPoint.x, originalPoint.y + self.sunCircleR + self.sunSpace + self.sunLightL);
        CGPoint point5_end = CGPointMake(originalPoint.x, originalPoint.y + self.sunCircleR + self.sunSpace);
        
        CGPoint point6_start = CGPointMake(originalPoint.x - cos(M_PI_4)*start_hypotenuseL, originalPoint.y - sin(M_PI_4)*start_hypotenuseL);
        CGPoint point6_end = CGPointMake(originalPoint.x - cos(M_PI_4)*end_hypotenuseL, originalPoint.y - sin(M_PI_4)*end_hypotenuseL);
        
        CGPoint point7_start = CGPointMake(originalPoint.x - self.sunCircleR - self.sunSpace - self.sunLightL, originalPoint.y);
        CGPoint point7_end = CGPointMake(originalPoint.x - self.sunCircleR - self.sunSpace, originalPoint.y);
        
        CGPoint point8_start = CGPointMake(originalPoint.x - cos(M_PI_4)*start_hypotenuseL, originalPoint.y + sin(M_PI_4)*start_hypotenuseL);
        CGPoint point8_end = CGPointMake(originalPoint.x - cos(M_PI_4)*end_hypotenuseL, originalPoint.y + sin(M_PI_4)*end_hypotenuseL);
        
        NSArray * sunLineArr = @[@[@(CGPointMake(self.sunW/2, kHalfLineW)),
                                   @(CGPointMake(self.sunW/2, kHalfLineW + topL))],
                                 @[@(CGPointMake(self.sunW/2, totalH - kHalfLineW - bottomL)),
                                   @(CGPointMake(self.sunW/2, totalH - kHalfLineW))],
                                 @[@(point1_start),
                                   @(point1_end)],
                                 @[@(point2_start),
                                   @(point2_end)],
                                 @[@(point3_start),
                                   @(point3_end)],
                                 @[@(point4_start),
                                   @(point4_end)],
                                 @[@(point5_start),
                                   @(point5_end)],
                                 @[@(point6_start),
                                   @(point6_end)],
                                 @[@(point7_start),
                                   @(point7_end)],
                                 @[@(point8_start),
                                   @(point8_end)],
                                 ];
        for (NSArray * arr in sunLineArr) {
            [self context:context drawSunLineArr:arr];
        }
        
        CGContextSetFillColorWithColor(context, BKCameraFocusBackgroundColor.CGColor);
        CGContextAddArc(context, self.drawSun_x_increment + originalPoint.x, originalPoint.y, self.sunCircleR, 0, M_PI*2, YES);
        CGContextFillPath(context);
    }
}

/**
 画聚焦框按偏移量重新计算point
 */
-(CGPoint)resetDrawFocusPoint:(CGPoint)point
{
    if (self.isDisplaySun) {
        return CGPointMake(self.drawFocus_x_increment + point.x, self.sunH + point.y);
    }else{
        return point;
    }
}

/**
 画聚焦框
 */
-(void)context:(CGContextRef)context drawFocusLineArr:(NSArray*)lineArr
{
    [lineArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [self resetDrawFocusPoint:[obj CGPointValue]];
        if (idx == 0) {
            CGContextMoveToPoint(context, point.x, point.y);
        }else{
            CGContextAddLineToPoint(context, point.x, point.y);
        }
    }];
    CGContextStrokePath(context);
}

/**
 画太阳按偏移量重新计算point
 */
-(CGPoint)resetDrawSunPoint:(CGPoint)point
{
    return CGPointMake(self.drawSun_x_increment + point.x, point.y);
}

/**
 画太阳
 */
-(void)context:(CGContextRef)context drawSunLineArr:(NSArray*)lineArr
{
    [lineArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [self resetDrawSunPoint:[obj CGPointValue]];
        if (idx == 0) {
            CGContextMoveToPoint(context, point.x, point.y);
        }else{
            CGContextAddLineToPoint(context, point.x, point.y);
        }
    }];
    CGContextStrokePath(context);
}

@end
