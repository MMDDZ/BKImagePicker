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

@property (nonatomic,copy) NSString * bundlePath;

@property (nonatomic,strong) UIButton * revocationBtn;

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
        
        [self addSubview:self.revocationBtn];
        [self createColorView];
        
    }
    return self;
}

-(NSString*)bundlePath
{
    if (!_bundlePath) {
        _bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
    }
    return _bundlePath;
}

#pragma mark - 撤销

-(UIButton *)revocationBtn
{
    if (!_revocationBtn) {
        _revocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _revocationBtn.frame = CGRectMake(0, 5, 40, 40);
        [_revocationBtn setImage:[UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/revocation.png"]] forState:UIControlStateNormal];
        [_revocationBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
        [_revocationBtn addTarget:self action:@selector(revocationBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _revocationBtn;
}

-(void)revocationBtnClick
{
    if ([self.delegate respondsToSelector:@selector(revocationAction)]) {
        [self.delegate revocationAction];
    }
}

#pragma mark - 选色

-(void)createColorView
{
    UIImage * masaike = [UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/masaike.png"]];
    NSArray * arr = @[[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor],[UIColor blackColor],[UIColor whiteColor],[UIColor lightGrayColor],masaike];
    
    __block UIView * lastView;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImageView * colorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, CGRectGetMaxY(_revocationBtn.frame) + 5 + 16*idx, 16, 16)];
        colorImageView.tag = 1;
        [self addSubview:colorImageView];
        
        if ([obj isKindOfClass:[UIColor class]]) {
            colorImageView.backgroundColor = obj;
        }else if ([obj isKindOfClass:[UIImage class]]) {
            colorImageView.image = obj;
        }
        
        if (idx == 0) {
            _selectImageView = colorImageView;
            if ([self.delegate respondsToSelector:@selector(selectColor:orSelectType:)]) {
                [self.delegate selectColor:_selectImageView.backgroundColor orSelectType:BKSelectTypeColor];
            }
        }
        
        lastView = colorImageView;
    }];
    
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
