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

@property (nonatomic,strong) UIImageView * selectImageView;

@property (nonatomic,strong) BKSelectColorMarkView * markView;

@end

@implementation BKSelectColorView

-(instancetype)initWithStartPosition:(CGPoint)point delegate:(id)delegate
{
    self = [super initWithFrame:CGRectMake(point.x, point.y, 40, 0)];
    if (self) {
        
        self.delegate = delegate;
        
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
        
        UIImageView * colorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 16*i, 16, 16)];
        colorImageView.tag = 1;
        switch (i) {
            case 0:
            {
                colorImageView.backgroundColor = [UIColor redColor];
                _selectImageView = colorImageView;
                
                if ([self.delegate respondsToSelector:@selector(selectColor:orSelectType:)]) {
                    [self.delegate selectColor:_selectImageView.backgroundColor orSelectType:BKSelectTypeColor];
                }
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
    
    self.bk_height = CGRectGetMaxY(lastView.frame);
    
    _selectImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [self bringSubviewToFront:_selectImageView];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self currentTouches:touches];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self currentTouches:touches];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_markView removeFromSuperview];
}

-(void)currentTouches:(NSSet *)touches
{
    UITouch * touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    for (UIView * view in [self subviews]) {
        if (CGRectContainsPoint(CGRectMake(0, view.bk_y, self.bk_width, 16) , currentPoint) && view.tag == 1) {
            _selectImageView = (UIImageView*)view;

            [self bringSubviewToFront:_selectImageView];
            view.transform = CGAffineTransformMakeScale(1.5, 1.5);
            
            if (![[self subviews] containsObject:self.markView]) {
                [self addSubview:self.markView];
            }
            if (!_selectImageView.image) {
                _markView.selectColor = _selectImageView.backgroundColor;
                if ([self.delegate respondsToSelector:@selector(selectColor:orSelectType:)]) {
                    [self.delegate selectColor:_markView.selectColor orSelectType:BKSelectTypeColor];
                }
            }else{
                _markView.selectType = BKSelectTypeMaSaiKe;
                if ([self.delegate respondsToSelector:@selector(selectColor:orSelectType:)]) {
                    [self.delegate selectColor:nil orSelectType:BKSelectTypeMaSaiKe];
                }
            }
            
            _markView.bk_centerY = _selectImageView.bk_centerY;
            _markView.bk_x = _selectImageView.bk_x - 10 - _markView.bk_width;
            
            break;
        }
    }
    
    for (UIView * view in [self subviews]) {
        if (_selectImageView != view && view.tag == 1) {
            view.transform = CGAffineTransformMakeScale(1, 1);
        }
    }
}

#pragma mark - 标记

-(BKSelectColorMarkView*)markView
{
    if (!_markView) {
        _markView = [[BKSelectColorMarkView alloc]init];
    }
    return _markView;
}

@end
