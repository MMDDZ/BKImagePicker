//
//  BKCameraGradientShadow.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/20.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKCameraGradientShadow.h"
#import "BKImagePickerMacro.h"
#import "UIView+BKImagePicker.h"

@implementation BKCameraGradientShadow

#pragma mark - Setter

-(void)setDirection:(BKCameraGradientDirection)direction
{
    _direction = direction;
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

#pragma mark - init

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPathRef pathRef = CGPathCreateWithRect(self.bounds, nil);
    CGContextAddPath(context, pathRef);
    CGContextClip(context);
    
    CGFloat start_R = [[BKCameraGradientShadowStartColor valueForKey:@"redComponent"] floatValue];
    CGFloat start_G = [[BKCameraGradientShadowStartColor valueForKey:@"greenComponent"] floatValue];
    CGFloat start_B = [[BKCameraGradientShadowStartColor valueForKey:@"blueComponent"] floatValue];
    CGFloat start_A = [[BKCameraGradientShadowStartColor valueForKey:@"alphaComponent"] floatValue];
    
    CGFloat end_R = [[BKCameraGradientShadowEndColor valueForKey:@"redComponent"] floatValue];
    CGFloat end_G = [[BKCameraGradientShadowEndColor valueForKey:@"greenComponent"] floatValue];
    CGFloat end_B = [[BKCameraGradientShadowEndColor valueForKey:@"blueComponent"] floatValue];
    CGFloat end_A = [[BKCameraGradientShadowEndColor valueForKey:@"alphaComponent"] floatValue];
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] = {
        start_R, start_G, start_B, start_A,
        end_R, end_G, end_B, end_A,
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    CGColorSpaceRelease(rgb);
    
    CGPoint start = CGPointZero;
    CGPoint end = CGPointZero;
    switch (_direction) {
        case BKCameraGradientDirectionLeft:
        {
            start = CGPointMake(self.bk_width, self.bk_height/2);
            end = CGPointMake(0, self.bk_height/2);
        }
            break;
        case BKCameraGradientDirectionRight:
        {
            start = CGPointMake(0, self.bk_height/2);
            end = CGPointMake(self.bk_width, self.bk_height/2);
        }
            break;
        case BKCameraGradientDirectionTop:
        {
            start = CGPointMake(self.bk_width/2, self.bk_height);
            end = CGPointMake(self.bk_width/2, 0);
        }
            break;
        case BKCameraGradientDirectionBottom:
        {
            start = CGPointMake(self.bk_width/2, 0);
            end = CGPointMake(self.bk_width/2, self.bk_height);
        }
            break;
        default:
            break;
    }
    
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);

}

@end
