//
//  BKSelectColorView.m
//  BKImagePicker
//
//  Created by 毕珂 on 2017/5/1.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKSelectColorView.h"
#import "BKImagePickerConst.h"

@interface BKSelectColorView()

@property(nonatomic,strong) UIImageView * selectImageView;

@end

@implementation BKSelectColorView

-(instancetype)initWithStartPosition:(CGPoint)point
{
    self = [super initWithFrame:CGRectMake(point.x, point.y, 0, 30)];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        
        [self createColorView];
        
    }
    return self;
}

-(void)createColorView
{
    UIView * lastView;
    for (int i = 0; i < 10 ; i++) {
        
        UIImageView * colorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(16*i, (self.bk_height - 16)/2, 16, 16)];
        colorImageView.tag = 1;
        switch (i) {
            case 0:
            {
                colorImageView.backgroundColor = [UIColor redColor];
            }
                break;
            case 1:
            {
                colorImageView.backgroundColor = [UIColor orangeColor];
            }
                break;
            case 2:
            {
                colorImageView.backgroundColor = [UIColor yellowColor];
            }
                break;
            case 3:
            {
                colorImageView.backgroundColor = [UIColor greenColor];
            }
                break;
            case 4:
            {
                colorImageView.backgroundColor = [UIColor blueColor];
            }
                break;
            case 5:
            {
                colorImageView.backgroundColor = [UIColor purpleColor];
            }
                break;
            case 6:
            {
                colorImageView.backgroundColor = [UIColor blackColor];
            }
                break;
            case 7:
            {
                colorImageView.backgroundColor = [UIColor whiteColor];
            }
                break;
            case 8:
            {
                colorImageView.backgroundColor = [UIColor lightGrayColor];
            }
                break;
            case 9:
            {
                NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
                bundlePath = [bundlePath stringByAppendingString:@"/masaike.png"];
                colorImageView.image = [UIImage imageWithContentsOfFile:bundlePath];
            }
                break;
            default:
                break;
        }
        [self addSubview:colorImageView];
        
        lastView = colorImageView;
    }
    
    self.bk_width = CGRectGetMaxX(lastView.frame);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self currentTouches:touches];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self currentTouches:touches];
}

-(void)currentTouches:(NSSet *)touches
{
    UITouch * touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    for (UIView * view in [self subviews]) {
        if (CGRectContainsPoint(view.frame, currentPoint) && view.tag == 1) {
            _selectImageView = (UIImageView*)view;
            [self bringSubviewToFront:_selectImageView];
            view.transform = CGAffineTransformMakeScale(1.5, 1.5);
            break;
        }
    }
    
    for (UIView * view in [self subviews]) {
        if (_selectImageView != view && view.tag == 1) {
            view.transform = CGAffineTransformMakeScale(1, 1);
        }
    }
}

@end