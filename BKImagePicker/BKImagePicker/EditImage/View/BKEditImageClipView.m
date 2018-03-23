//
//  BKEditImageClipView.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageClipView.h"
#import "BKImagePickerConst.h"
#import "BKEditImageClipFrameView.h"

typedef NS_ENUM(NSUInteger, BKEditImagePanAngle) {
    BKEditImagePanAngleLeftTop = 0,
    BKEditImagePanAngleRightTop,
    BKEditImagePanAngleLeftBottom,
    BKEditImagePanAngleRightBottom,
};

@interface BKEditImageClipView()<UIGestureRecognizerDelegate>

@property (nonatomic,assign) CGRect shadowViewRect;
@property (nonatomic,strong) UIView * shadowView;

@property (nonatomic,strong) BKEditImageClipFrameView * clipFrameView;

@property (nonatomic,strong) UIView * bottomNav;

@property (nonatomic,assign) BKEditImageRotation rotation;

@end

@implementation BKEditImageClipView

#pragma mark - 改变背景ScrollView的ZoomScale

-(void)changeBgScrollViewZoomScale
{
    if (_rotation == BKEditImageRotationVertical) {
        
        _editImageBgView.contentSize = CGSizeMake(_editImageBgView.contentView.bk_width<_editImageBgView.bk_width?_editImageBgView.bk_width:_editImageBgView.contentView.bk_width, _editImageBgView.contentView.bk_height<_editImageBgView.bk_height?_editImageBgView.bk_height:_editImageBgView.contentView.bk_height);
        
        CGFloat width_gap = (_editImageBgView.contentView.bk_width > _editImageBgView.bk_width ? _editImageBgView.bk_width : _editImageBgView.contentView.bk_width) - (_clipFrameView?_clipFrameView.bk_width:CGRectGetWidth(_shadowViewRect));
        CGFloat height_gap = (_editImageBgView.contentView.bk_height > _editImageBgView.bk_height ? _editImageBgView.bk_height : _editImageBgView.contentView.bk_height) - (_clipFrameView?_clipFrameView.bk_height:CGRectGetHeight(_shadowViewRect));
        
        _editImageBgView.contentInset = UIEdgeInsetsMake(height_gap/2, width_gap/2, height_gap/2, width_gap/2);
        
        _editImageBgView.contentView.bk_centerX = _editImageBgView.contentView.bk_width>_editImageBgView.bk_width?_editImageBgView.contentSize.width/2.0f:_editImageBgView.bk_centerX;
        _editImageBgView.contentView.bk_centerY = _editImageBgView.contentView.bk_height>_editImageBgView.bk_height?_editImageBgView.contentSize.height/2.0f:_editImageBgView.bk_centerY;
    }else{
        
        _editImageBgView.contentSize = CGSizeMake(_editImageBgView.contentView.bk_width<_editImageBgView.bk_height?_editImageBgView.bk_height:_editImageBgView.contentView.bk_width, _editImageBgView.contentView.bk_height<_editImageBgView.bk_width?_editImageBgView.bk_width:_editImageBgView.contentView.bk_height);
        
        CGFloat width_gap = (_editImageBgView.contentView.bk_height > _editImageBgView.bk_width ? _editImageBgView.bk_width : _editImageBgView.contentView.bk_height) - (_clipFrameView?_clipFrameView.bk_width:CGRectGetWidth(_shadowViewRect));
        CGFloat height_gap = (_editImageBgView.contentView.bk_width > _editImageBgView.bk_height ? _editImageBgView.bk_height : _editImageBgView.contentView.bk_width) - (_clipFrameView?_clipFrameView.bk_height:CGRectGetHeight(_shadowViewRect));
        
        _editImageBgView.contentInset = UIEdgeInsetsMake(width_gap/2, height_gap/2, width_gap/2, height_gap/2);
        
        _editImageBgView.contentView.bk_centerX = _editImageBgView.contentView.bk_width>_editImageBgView.bk_height?_editImageBgView.contentSize.width/2.0f:_editImageBgView.bk_centerY;
        _editImageBgView.contentView.bk_centerY = _editImageBgView.contentView.bk_height>_editImageBgView.bk_width?_editImageBgView.contentSize.height/2.0f:_editImageBgView.bk_centerX;
    }
    
    [self changeShadowViewRect];
}

#pragma mark - 移动背景scrollView

-(void)slideBgScrollView
{
    [self changeShadowViewRect];
}

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.bottomNav];
        
//        NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//           NSLog(@"%@",NSStringFromCGPoint(_editImageBgView.contentOffset));
//        }];
//        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(windowPanGesture:)];
        panGesture.delegate = self;
        panGesture.maximumNumberOfTouches = 1;
        panGesture.dicTag = @{@"type":@"window",@"angle":@""};
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:panGesture];
    }
    return self;
}

#pragma mark - UIPanGestureRecognizer

static CGRect beginClipFrameViewRect;
-(void)windowPanGesture:(UIPanGestureRecognizer*)panGesture
{
    if ([panGesture.dicTag[@"angle"] isEqual:@""]) {

        panGesture.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            panGesture.enabled = YES;
        });

        return;
    }
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        beginClipFrameViewRect = _clipFrameView.frame;
    }
    
    CGPoint translation = [panGesture translationInView:[UIApplication sharedApplication].keyWindow];
    
    CGRect contentRect = [[_editImageBgView.contentView superview] convertRect:_editImageBgView.contentView.frame toView:self];
    
    CGFloat minX = _editImageBgView.bk_width * 0.1 < CGRectGetMinX(contentRect) ? CGRectGetMinX(contentRect) : _editImageBgView.bk_width * 0.1;
    CGFloat minY = _editImageBgView.bk_height * 0.1 < CGRectGetMinY(contentRect) ? CGRectGetMinY(contentRect) : _editImageBgView.bk_height * 0.1;
    CGFloat maxX = _editImageBgView.bk_width * 0.9 > CGRectGetMaxX(contentRect) ? CGRectGetMaxX(contentRect) : _editImageBgView.bk_width * 0.9;
    CGFloat maxY = _editImageBgView.bk_height * 0.9 > CGRectGetMaxY(contentRect) ? CGRectGetMaxY(contentRect) : _editImageBgView.bk_height * 0.9;
    
    CGFloat minL = 40;//最小宽度
    CGFloat maxW = _editImageBgView.bk_width * 0.8 > CGRectGetWidth(contentRect) ? CGRectGetWidth(contentRect) : _editImageBgView.bk_width * 0.8;
    CGFloat maxH = _editImageBgView.bk_height * 0.8 > CGRectGetHeight(contentRect) ? CGRectGetHeight(contentRect) : _editImageBgView.bk_height * 0.8;
    
    CGFloat X = _clipFrameView.bk_x;
    CGFloat Y = _clipFrameView.bk_y;
    CGFloat width = _clipFrameView.bk_width;
    CGFloat height = _clipFrameView.bk_height;
    
    switch ([panGesture.dicTag[@"angle"] integerValue]) {
        case BKEditImagePanAngleLeftTop:
        {
            if (X + translation.x < minX) {
                X = minX;
                width = CGRectGetMaxX(_clipFrameView.frame) - X;
            }else if (width - translation.x < minL) {
                width = minL;
                X = CGRectGetMaxX(_clipFrameView.frame) - width;
            }else{
                X = X + translation.x;
                width = width - translation.x;
            }
            
            if (Y + translation.y < minY) {
                Y = minY;
                height = CGRectGetMaxY(_clipFrameView.frame) - Y;
            }else if (height - translation.y < minL) {
                height = minL;
                Y = CGRectGetMaxY(_clipFrameView.frame) - height;
            }else{
                Y = Y + translation.y;
                height = height - translation.y;
            }
        }
            break;
        case BKEditImagePanAngleRightTop:
        {
            if (width + translation.x < minL) {
                width = minL;
            }else if (X + width + translation.x > maxX) {
                width = maxX - X;
                X = maxX - width;
            }else{
                width = width + translation.x;
            }
            
            if (Y + translation.y < minY) {
                Y = minY;
                height = CGRectGetMaxY(_clipFrameView.frame) - Y;
            }else if (height - translation.y < minL) {
                height = minL;
                Y = CGRectGetMaxY(_clipFrameView.frame) - height;
            }else{
                Y = Y + translation.y;
                height = height - translation.y;
            }
        }
            break;
        case BKEditImagePanAngleLeftBottom:
        {
            if (X + translation.x < minX) {
                X = minX;
                width = CGRectGetMaxX(_clipFrameView.frame) - X;
            }else if (width - translation.x < minL) {
                width = minL;
                X = CGRectGetMaxX(_clipFrameView.frame) - width;
            }else{
                X = X + translation.x;
                width = width - translation.x;
            }
            
            if (height + translation.y < minL) {
                height = minL;
            }else if (Y + height + translation.y > maxY) {
                height = maxY - Y;
                Y = maxY - height;
            }else{
                height = height + translation.y;
            }
        }
            break;
        case BKEditImagePanAngleRightBottom:
        {
            if (width + translation.x < minL) {
                width = minL;
            }else if (X + width + translation.x > maxX) {
                width = maxX - X;
                X = maxX - width;
            }else{
                width = width + translation.x;
            }
            
            if (height + translation.y < minL) {
                height = minL;
            }else if (Y + height + translation.y > maxY) {
                height = maxY - Y;
                Y = maxY - height;
            }else{
                height = height + translation.y;
            }
        }
            break;
        default:
            break;
    }
    
    if (width > maxW) {
        width = maxW;
    }
    
    if (height > maxH) {
        height = maxH;
    }
    
    _clipFrameView.frame = CGRectMake(X, Y, width, height);
    [self changeShadowViewRect];
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateFailed || panGesture.state == UIGestureRecognizerStateCancelled) {
        panGesture.dicTag = @{@"type":@"window",@"angle":@""};
        
        if (![UIApplication sharedApplication].keyWindow.userInteractionEnabled) {
            return;
        }
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            _editImageBgView.contentOffset = CGPointMake(_editImageBgView.contentOffset.x + (_clipFrameView.center.x - CGRectGetMidX(beginClipFrameViewRect)), _editImageBgView.contentOffset.y + (_clipFrameView.center.y - CGRectGetMidY(beginClipFrameViewRect)));
            
            _clipFrameView.center = CGPointMake(_editImageBgView.bk_width / 2, _editImageBgView.bk_height / 2);
            
            [self changeBgScrollViewZoomScale];
            
        } completion:^(BOOL finished) {
           [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        }];
        
    }
    
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer.dicTag[@"type"] isEqualToString:@"window"]) {
        
        CGPoint point = [gestureRecognizer locationInView:self];
        
        NSArray * frame_angle_rectArr = @[NSStringFromCGRect(CGRectMake(CGRectGetMinX(_clipFrameView.frame) - 25, CGRectGetMinY(_clipFrameView.frame) - 25, 50, 50)),
                                          NSStringFromCGRect(CGRectMake(CGRectGetMaxX(_clipFrameView.frame) - 25, CGRectGetMinY(_clipFrameView.frame) - 25, 50, 50)),
                                          NSStringFromCGRect(CGRectMake(CGRectGetMinX(_clipFrameView.frame) - 25, CGRectGetMaxY(_clipFrameView.frame) - 25, 50, 50)),
                                          NSStringFromCGRect(CGRectMake(CGRectGetMaxX(_clipFrameView.frame) - 25, CGRectGetMaxY(_clipFrameView.frame) - 25, 50, 50))];
        
        [frame_angle_rectArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGRect rect = CGRectFromString(obj);
            
            if (CGRectContainsPoint(rect, point)) {
                
                switch (idx) {
                    case 0:
                    {
                        gestureRecognizer.dicTag = @{@"type":@"window",@"angle":@(BKEditImagePanAngleLeftTop)};
                    }
                        break;
                    case 1:
                    {
                        gestureRecognizer.dicTag = @{@"type":@"window",@"angle":@(BKEditImagePanAngleRightTop)};
                    }
                        break;
                    case 2:
                    {
                        gestureRecognizer.dicTag = @{@"type":@"window",@"angle":@(BKEditImagePanAngleLeftBottom)};
                    }
                        break;
                    case 3:
                    {
                        gestureRecognizer.dicTag = @{@"type":@"window",@"angle":@(BKEditImagePanAngleRightBottom)};
                    }
                        break;
                    default:
                        break;
                }
                
                if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
                    otherGestureRecognizer.enabled = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        otherGestureRecognizer.enabled = YES;
                    });
                }
                
                *stop = YES;
            }
        }];
    }
    
    return YES;
}

#pragma mark - showClipView

-(void)showClipView
{
    _editImageBgView.clipsToBounds = NO;
    _editImageBgView.bk_height = self.bk_height - self.bottomNav.bk_height;
 
    CGFloat minZoomScale = 0.8;
    if (_editImageBgView.contentView.bk_height > _editImageBgView.contentView.bk_width) {
        if (_editImageBgView.contentView.bk_height > _editImageBgView.bk_height) {
            CGFloat gap = _editImageBgView.contentView.bk_height - _editImageBgView.bk_height;
            minZoomScale = (1 - gap/_editImageBgView.contentView.bk_height)*0.8;
        }
    }
    _editImageBgView.minimumZoomScale = minZoomScale;
    
    [UIView animateWithDuration:0.2 animations:^{
        [_editImageBgView setZoomScale:minZoomScale];
    } completion:^(BOOL finished) {
        
        [self addShadowView];
        [self addSubview:self.clipFrameView];
        
        [self changeBgScrollViewZoomScale];
    }];
}

#pragma mark - shadowView

-(void)removeShadowView
{
    [_shadowView removeFromSuperview];
    _shadowView = nil;
}

-(void)addShadowView
{
    if (_shadowView) {
        [self removeShadowView];
    }
    [_editImageBgView.contentView addSubview:self.shadowView];
}

/**
 起始阴影框大小

 @return 阴影框大小
 */
-(CGRect)shadowViewRect
{
    if (CGRectEqualToRect(_shadowViewRect, CGRectZero)) {
        _shadowViewRect = _editImageBgView.contentView.bounds;
    }
    return _shadowViewRect;
}

/**
 修改阴影框大小
 */
-(void)changeShadowViewRect
{
    if (_shadowView) {
        _shadowViewRect = [[_clipFrameView superview] convertRect:_clipFrameView.frame toView:_editImageBgView.contentView];
        
        [self removeShadowView];
        [self addShadowView];
    }
}

-(UIView*)shadowView
{
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:_editImageBgView.contentView.bounds];
        
        UIBezierPath * path = [UIBezierPath bezierPathWithRect:_shadowView.bounds];
        UIBezierPath * rectPath = [UIBezierPath bezierPathWithRect:self.shadowViewRect];
        [path appendPath:rectPath];
        
        CAShapeLayer * shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        shapeLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        [_shadowView.layer addSublayer:shapeLayer];
    }
    return _shadowView;
}

#pragma mark - clipFrameView

-(void)removeClipFrameView
{
    [_clipFrameView removeFromSuperview];
    _clipFrameView = nil;
}

-(void)addClipFrameView
{
    if (_clipFrameView) {
        [self removeClipFrameView];
    }
    [self addSubview:self.clipFrameView];
}

-(BKEditImageClipFrameView*)clipFrameView
{
    if (!_clipFrameView) {
        
        CGRect contentFrame;
        if (CGRectEqualToRect(_shadowViewRect, CGRectZero)) {
            contentFrame = [[_editImageBgView.contentView superview] convertRect:_editImageBgView.contentView.frame toView:self];
        }else{
            contentFrame = [[_editImageBgView.contentView superview] convertRect:_shadowViewRect toView:self];
        }
        
        _clipFrameView = [[BKEditImageClipFrameView alloc]initWithFrame:contentFrame];
    }
    
    return _clipFrameView;
}

#pragma mark - bottomNav

-(UIView*)bottomNav
{
    if (!_bottomNav) {
        _bottomNav = [[UIView alloc]initWithFrame:CGRectMake(0, self.bk_height - BK_SYSTEM_TABBAR_HEIGHT, self.bk_width, BK_SYSTEM_TABBAR_HEIGHT)];
        _bottomNav.backgroundColor = BKNavBackgroundColor;
        
        NSString * imageBundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        NSString * imagePath = [NSString stringWithFormat:@"%@",imageBundlePath];
        
        UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 64, BK_SYSTEM_TABBAR_UI_HEIGHT);
        [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomNav addSubview:backBtn];
        
        UIImageView * backImageView = [[UIImageView alloc]initWithFrame:CGRectMake((backBtn.bk_width - 20)/2, (backBtn.bk_height - 20)/2, 20, 20)];
        backImageView.clipsToBounds = YES;
        backImageView.contentMode = UIViewContentModeScaleAspectFit;
        backImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/EditImage/%@",imagePath,@"clip_back"]];
        [backBtn addSubview:backImageView];
        
        UIButton * finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        finishBtn.frame = CGRectMake(_bottomNav.bk_width - 64, 0, 64, BK_SYSTEM_TABBAR_UI_HEIGHT);
        [finishBtn addTarget:self action:@selector(finishBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomNav addSubview:finishBtn];
        
        UIImageView * finishImageView = [[UIImageView alloc]initWithFrame:CGRectMake((finishBtn.bk_width - 20)/2, (finishBtn.bk_height - 20)/2, 20, 20)];
        finishImageView.clipsToBounds = YES;
        finishImageView.contentMode = UIViewContentModeScaleAspectFit;
        finishImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/EditImage/%@",imagePath,@"clip_finish"]];
        [finishBtn addSubview:finishImageView];
        
        UIButton * rotationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rotationBtn.frame = CGRectMake((_bottomNav.bk_width - 64)/2, 0, 64, BK_SYSTEM_TABBAR_UI_HEIGHT);
        [rotationBtn addTarget:self action:@selector(rotationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomNav addSubview:rotationBtn];
        
        UIImageView * rotationImageView = [[UIImageView alloc]initWithFrame:CGRectMake((rotationBtn.bk_width - 20)/2, (rotationBtn.bk_height - 20)/2, 20, 20)];
        rotationImageView.clipsToBounds = YES;
        rotationImageView.contentMode = UIViewContentModeScaleAspectFit;
        rotationImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/EditImage/%@",imagePath,@"left_rotation_90"]];
        [rotationBtn addSubview:rotationImageView];
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _bottomNav.bk_width, BK_ONE_PIXEL)];
        line.backgroundColor = BKLineColor;
        [_bottomNav addSubview:line];
    }
    return _bottomNav;
}

-(void)backBtnClick
{
    _editImageBgView.clipsToBounds = YES;
    _editImageBgView.bk_height = self.bk_height;
    _editImageBgView.minimumZoomScale = 1;
    
    [_bottomNav removeFromSuperview];
    _bottomNav = nil;
    
    if (self.backAction) {
        self.backAction();
    }
}

-(void)finishBtnClick
{
    _editImageBgView.clipsToBounds = YES;
    _editImageBgView.bk_height = self.bk_height;
    _editImageBgView.minimumZoomScale = 1;
    
    [_bottomNav removeFromSuperview];
    _bottomNav = nil;
    
    if (self.finishAction) {
        self.finishAction();
    }
}

-(void)rotationBtnClick:(UIButton*)button
{
    if (![UIApplication sharedApplication].keyWindow.userInteractionEnabled) {
        return;
    }
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    
    
    CGFloat w_h_ratio = 0;
    if (_rotation == BKEditImageRotationVertical) {
        _rotation = BKEditImageRotationHorizontal;
        
        w_h_ratio = _editImageBgView.bk_height / (_editImageBgView.contentView.bk_width / _editImageBgView.zoomScale);
        if ((_editImageBgView.contentView.bk_height / _editImageBgView.zoomScale) * w_h_ratio > _editImageBgView.bk_width) {
            w_h_ratio = _editImageBgView.bk_width / (_editImageBgView.contentView.bk_height / _editImageBgView.zoomScale);
        }
    }else{
        _rotation = BKEditImageRotationVertical;
        
        w_h_ratio = _editImageBgView.bk_width / (_editImageBgView.contentView.bk_height / _editImageBgView.zoomScale);
        if ((_editImageBgView.contentView.bk_width / _editImageBgView.zoomScale) * w_h_ratio > _editImageBgView.bk_height) {
            w_h_ratio = _editImageBgView.bk_height / (_editImageBgView.contentView.bk_width / _editImageBgView.zoomScale);
        }
    }
//    _clipFrameView.rotation = _rotation;
    
//    CGFloat w_h_ratio = (_editImageBgView.bk_height * 0.8) / _clipFrameView.bk_width;
//    if (_clipFrameView.bk_height * w_h_ratio > _editImageBgView.bk_width * 0.8) {
//        w_h_ratio = (_editImageBgView.bk_width * 0.8) / _clipFrameView.bk_height;
//    }

    
    
    _editImageBgView.minimumZoomScale = _editImageBgView.minimumZoomScale * w_h_ratio;
    
    [self removeShadowView];
    [self removeClipFrameView];
    
    [UIView animateWithDuration:0.3 animations:^{
        _editImageBgView.transform = CGAffineTransformRotate(_editImageBgView.transform, -M_PI_2);
        _editImageBgView.frame = CGRectMake(0, 0, self.bk_width, self.bk_height - self.bottomNav.bk_height);
        _editImageBgView.zoomScale = _editImageBgView.zoomScale * w_h_ratio;
        
//        _clipFrameView.transform = CGAffineTransformRotate(_clipFrameView.transform, -M_PI_2);
//        _clipFrameView.transform = CGAffineTransformScale(_clipFrameView.transform, w_h_ratio, w_h_ratio);
        
        [self changeBgScrollViewZoomScale];
        
        
        
    } completion:^(BOOL finished) {
        [self addShadowView];
        [self addClipFrameView];
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
    }];
}

@end
