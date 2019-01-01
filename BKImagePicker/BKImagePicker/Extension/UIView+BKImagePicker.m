//
//  UIView+BKImagePicker.m
//  BKImagePicker
//
//  Created by BIKE on 16/12/30.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "UIView+BKImagePicker.h"
#import "BKImagePickerMacro.h"
#import "NSString+BKImagePicker.h"

@implementation UIView (BKImagePicker)

#pragma mark - 附加属性

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

#pragma mark - 提示

/**
 提示
 
 @param text 文本
 */
-(void)bk_showRemind:(NSString*)text
{
    UIView * bgView = [[UIView alloc] init];
    bgView.backgroundColor = BKRemindBackgroundColor;
    bgView.layer.cornerRadius = 8.0f;
    bgView.clipsToBounds = YES;
    bgView.userInteractionEnabled = NO;
    [self addSubview:bgView];
    
    UILabel * remindLab = [[UILabel alloc]init];
    remindLab.textColor = BKRemindTitleColor;
    CGFloat fontSize = 13.0 * self.bounds.size.width/320.0f;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    remindLab.font = font;
    remindLab.textAlignment = NSTextAlignmentCenter;
    remindLab.numberOfLines = 0;
    remindLab.backgroundColor = BKClearColor;
    remindLab.text = text;
    [bgView addSubview:remindLab];
    
    CGFloat width = [text bk_calculateSizeWithUIHeight:self.bounds.size.height font:font].width;
    if (width > self.bounds.size.width/4.0*3.0f) {
        width = self.bounds.size.width/4.0*3.0f;
    }
    CGFloat height = [text bk_calculateSizeWithUIWidth:width font:font].height;
    
    bgView.bounds = CGRectMake(0, 0, width+30, height+30);
    bgView.layer.position = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    
    remindLab.bounds = CGRectMake(0, 0, width, height);
    remindLab.layer.position = CGPointMake(bgView.bounds.size.width/2.0f, bgView.bounds.size.height/2.0f);
    
    [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [bgView removeFromSuperview];
    }];
}

#pragma mark - Loading

/**
 查找view中是否存在loadLayer
 
 @return loadLayer
 */
-(CALayer*)bk_findLoadLayer
{
    __block CALayer * loadLayer = nil;
    [[self.layer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"loadLayer"]) {
            loadLayer = obj;
            *stop = YES;
        }
    }];
    return loadLayer;
}

/**
 加载Loading
 
 @return loadLayer
 */
-(CALayer*)bk_showLoadLayer
{
    [self bk_hideLoadLayer];
    
    CGFloat scale = BK_SCREENW / 320.0f;
    CGFloat prepare_layer_width = self.bounds.size.width/4.0f;
    CGFloat min_layer_width = 60 * scale;
    
    CGFloat loadLayer_width = prepare_layer_width < min_layer_width ? min_layer_width : prepare_layer_width;
    
    CALayer * loadLayer = [CALayer layer];
    loadLayer.bounds = CGRectMake(0, 0, loadLayer_width, loadLayer_width);
    loadLayer.position = CGPointMake(self.bk_width/2, self.bk_height/2);
    loadLayer.backgroundColor = BKLoadingBackgroundColor.CGColor;
    loadLayer.cornerRadius = loadLayer.bounds.size.width/10.0f;
    loadLayer.masksToBounds = YES;
    loadLayer.name = @"loadLayer";
    [self.layer addSublayer:loadLayer];
    
    NSTimeInterval beginTime = CACurrentMediaTime();
    
    for (int i = 0; i < 2; i++) {
        CALayer * circle = [CALayer layer];
        circle.bounds = CGRectMake(0, 0, loadLayer.bounds.size.width/2.0f, loadLayer.bounds.size.height/2.0f);
        circle.position = CGPointMake(loadLayer.bounds.size.width/2.0f, loadLayer.bounds.size.height/2.0f);
        circle.backgroundColor = BKLoadingCircleBackgroundColor.CGColor;
        circle.opacity = 0.6;
        circle.cornerRadius = CGRectGetHeight(circle.bounds) * 0.5;
        circle.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
        circle.name = @"loadCircleLayer";
        
        CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.removedOnCompletion = NO;
        animation.repeatCount = MAXFLOAT;
        animation.duration = 1.5;
        animation.beginTime = beginTime - (0.75 * i);
        animation.keyTimes = @[@(0.0), @(0.5), @(1.0)];
        
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 0.0)],
                             [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)]];
        
        [loadLayer addSublayer:circle];
        [circle addAnimation:animation forKey:@"loading_admin"];
    }
    
    return loadLayer;
}

/**
 加载Loading 带下载进度
 
 @param progress 进度
 */
-(void)bk_showLoadLayerWithDownLoadProgress:(CGFloat)progress
{
    CALayer * loadLayer = [self bk_findLoadLayer];
    if (!loadLayer) {
        
        loadLayer = [self bk_showLoadLayer];
        [self bk_createProgressTextLayerInSupperLayer:loadLayer downLoadProgress:progress];
        
    }else{
        
        __block BOOL isFindFlag = NO;
        [[loadLayer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name isEqualToString:@"loadTextLayer"]) {
                CATextLayer * textLayer = (CATextLayer*)obj;
                textLayer.string = [NSString stringWithFormat:@"iCloud同步\n%.0f%%",progress*100];
                isFindFlag = YES;
                *stop = YES;
            }
        }];
        
        if (isFindFlag == NO) {
            [self bk_createProgressTextLayerInSupperLayer:loadLayer downLoadProgress:progress];
        }
    }
}

-(void)bk_createProgressTextLayerInSupperLayer:(CALayer*)supperLayer downLoadProgress:(CGFloat)progress
{
    CGFloat scale = BK_SCREENW / 320.0f;
    
    UIFont * font = [UIFont systemFontOfSize:10.0 * scale];
    NSString * string = [NSString stringWithFormat:@"iCloud同步\n%.0f%%",progress*100];
    
    CGFloat height = [string bk_calculateSizeWithUIWidth:supperLayer.frame.size.width font:font].height;
    
    CATextLayer * textLayer = [CATextLayer layer];
    textLayer.bounds = CGRectMake(0, 0, supperLayer.frame.size.width, height);
    textLayer.position = CGPointMake(supperLayer.frame.size.width/2, supperLayer.frame.size.height/2);
    textLayer.string = string;
    textLayer.wrapped = YES;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.foregroundColor = BKLoadingTitleColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.name = @"loadTextLayer";
    [supperLayer addSublayer:textLayer];
    
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
}

/**
 隐藏Loading
 */
-(void)bk_hideLoadLayer
{
    CALayer * loadLayer = [self bk_findLoadLayer];
    if (!loadLayer) {
        return;
    }
    
    [[loadLayer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"loadCircleLayer"]) {
            [obj removeAnimationForKey:@"loading_admin"];
        }
    }];
    [loadLayer removeFromSuperlayer];
    loadLayer = nil;
}

@end
