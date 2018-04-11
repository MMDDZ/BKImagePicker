//
//  BKEditImageClipView.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageClipView.h"
#import "BKTool.h"
#import "BKEditImageClipFrameView.h"

typedef NS_ENUM(NSUInteger, BKEditImagePanAngle) {
    BKEditImagePanAngleLeftTop = 0,
    BKEditImagePanAngleRightTop,
    BKEditImagePanAngleLeftBottom,
    BKEditImagePanAngleRightBottom,
};

@interface BKEditImageClipView()<UIGestureRecognizerDelegate>

@property (nonatomic,assign) CGRect shadowViewClipRect;
@property (nonatomic,strong) UIView * shadowView;

@property (nonatomic,strong) BKEditImageClipFrameView * clipFrameView;
@property (nonatomic,assign) CGRect beginClipFrameViewRect;

@property (nonatomic,strong) UIView * bottomNav;

@property (nonatomic,assign) BKEditImageRotation rotation;

@end

@implementation BKEditImageClipView

#pragma mark - 改变背景ScrollView的ZoomScale

-(void)willChangeBgScrollViewZoomScale
{
    [self removeShadowView];
}

-(void)changeBgScrollViewZoomScale
{
    if (_rotation == BKEditImageRotationPortrait || _rotation == BKEditImageRotationUpsideDown) {
        
        _editImageBgView.contentSize = CGSizeMake(_editImageBgView.contentView.bk_width<_editImageBgView.bk_width?_editImageBgView.bk_width:_editImageBgView.contentView.bk_width, _editImageBgView.contentView.bk_height<_editImageBgView.bk_height?_editImageBgView.bk_height:_editImageBgView.contentView.bk_height);
        
        CGFloat width_gap = (_editImageBgView.contentView.bk_width > _editImageBgView.bk_width ? _editImageBgView.bk_width : _editImageBgView.contentView.bk_width) - _clipFrameView.bk_width;
        CGFloat height_gap = (_editImageBgView.contentView.bk_height > _editImageBgView.bk_height ? _editImageBgView.bk_height : _editImageBgView.contentView.bk_height) - _clipFrameView.bk_height;
        
        _editImageBgView.contentInset = UIEdgeInsetsMake(height_gap/2, width_gap/2, height_gap/2, width_gap/2);
        
        _editImageBgView.contentView.bk_centerX = _editImageBgView.contentView.bk_width>_editImageBgView.bk_width?_editImageBgView.contentSize.width/2.0f:_editImageBgView.bk_centerX;
        _editImageBgView.contentView.bk_centerY = _editImageBgView.contentView.bk_height>_editImageBgView.bk_height?_editImageBgView.contentSize.height/2.0f:_editImageBgView.bk_centerY;
    }else{
        
        _editImageBgView.contentSize = CGSizeMake(_editImageBgView.contentView.bk_width<_editImageBgView.bk_height?_editImageBgView.bk_height:_editImageBgView.contentView.bk_width, _editImageBgView.contentView.bk_height<_editImageBgView.bk_width?_editImageBgView.bk_width:_editImageBgView.contentView.bk_height);
        
        CGFloat width_gap = (_editImageBgView.contentView.bk_height > _editImageBgView.bk_width ? _editImageBgView.bk_width : _editImageBgView.contentView.bk_height) - _clipFrameView.bk_width;
        CGFloat height_gap = (_editImageBgView.contentView.bk_width > _editImageBgView.bk_height ? _editImageBgView.bk_height : _editImageBgView.contentView.bk_width) - _clipFrameView.bk_height;
        
        _editImageBgView.contentInset = UIEdgeInsetsMake(width_gap/2, height_gap/2, width_gap/2, height_gap/2);
        
        _editImageBgView.contentView.bk_centerX = _editImageBgView.contentView.bk_width>_editImageBgView.bk_height?_editImageBgView.contentSize.width/2.0f:_editImageBgView.bk_centerY;
        _editImageBgView.contentView.bk_centerY = _editImageBgView.contentView.bk_height>_editImageBgView.bk_width?_editImageBgView.contentSize.height/2.0f:_editImageBgView.bk_centerX;
    }
    
    [self changeShadowViewRect];
}

-(void)endChangeBgScrollViewZoomScale
{
    //结束改变缩放比例时 调整最小缩放比例
    _editImageBgView.minimumZoomScale = [self calculateScrollMinZoomScaleWithNowMinZoomScale:_editImageBgView.minimumZoomScale];
    
    [self addShadowView];
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
        
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(windowPanGesture:)];
        panGesture.delegate = self;
        panGesture.maximumNumberOfTouches = 1;
        panGesture.dicTag = @{@"type":@"window",@"angle":@""};
        [[UIApplication sharedApplication].keyWindow addGestureRecognizer:panGesture];
    }
    return self;
}

#pragma mark - UIPanGestureRecognizer

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
        _beginClipFrameViewRect = _clipFrameView.frame;
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
            
            switch (self.rotation) {
                case BKEditImageRotationPortrait:
                {
                    self.editImageBgView.contentOffset = CGPointMake(self.editImageBgView.contentOffset.x + (self.clipFrameView.center.x - CGRectGetMidX(self.beginClipFrameViewRect)), self.editImageBgView.contentOffset.y + (self.clipFrameView.center.y - CGRectGetMidY(self.beginClipFrameViewRect)));
                }
                    break;
                case BKEditImageRotationLandscapeLeft:
                {
                    self.editImageBgView.contentOffset = CGPointMake(self.editImageBgView.contentOffset.x - (self.clipFrameView.center.y - CGRectGetMidY(self.beginClipFrameViewRect)), self.editImageBgView.contentOffset.y + (self.clipFrameView.center.x - CGRectGetMidX(self.beginClipFrameViewRect)));
                }
                    break;
                case BKEditImageRotationUpsideDown:
                {
                    self.editImageBgView.contentOffset = CGPointMake(self.editImageBgView.contentOffset.x - (self.clipFrameView.center.x - CGRectGetMidX(self.beginClipFrameViewRect)), self.editImageBgView.contentOffset.y - (self.clipFrameView.center.y - CGRectGetMidY(self.beginClipFrameViewRect)));
                }
                    break;
                case BKEditImageRotationLandscapeRight:
                {
                    self.editImageBgView.contentOffset = CGPointMake(self.editImageBgView.contentOffset.x + (self.clipFrameView.center.y - CGRectGetMidY(self.beginClipFrameViewRect)), self.editImageBgView.contentOffset.y - (self.clipFrameView.center.x - CGRectGetMidX(self.beginClipFrameViewRect)));
                }
                    break;
                default:
                    break;
            }
            //改变裁剪框时 调整最小缩放比例
            self.editImageBgView.minimumZoomScale = [self calculateScrollMinZoomScaleWithNowMinZoomScale:self.editImageBgView.minimumZoomScale];
            
            self.clipFrameView.center = CGPointMake(self.editImageBgView.bk_width / 2, self.editImageBgView.bk_height / 2);
            
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
        CGFloat editImageBgViewHeight = _editImageBgView.contentView.bk_height/_editImageBgView.zoomScale;
        if (editImageBgViewHeight > _editImageBgView.bk_height) {
            CGFloat gap = editImageBgViewHeight - _editImageBgView.bk_height;
            minZoomScale = (1 - gap/editImageBgViewHeight)*0.8;
        }
    }
    _editImageBgView.minimumZoomScale = minZoomScale;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.editImageBgView setZoomScale:minZoomScale];
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
-(CGRect)shadowViewClipRect
{
    if (CGRectEqualToRect(_shadowViewClipRect, CGRectZero)) {
        _shadowViewClipRect = _editImageBgView.contentView.bounds;
    }
    return _shadowViewClipRect;
}

/**
 修改阴影框大小
 */
-(void)changeShadowViewRect
{
    if (_shadowView) {
        _shadowViewClipRect = [[_clipFrameView superview] convertRect:_clipFrameView.frame toView:_editImageBgView.contentView];
        
        [self removeShadowView];
        [self addShadowView];
    }
}

-(UIView*)shadowView
{
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:_editImageBgView.contentView.bounds];
        
        UIBezierPath * path = [UIBezierPath bezierPathWithRect:_shadowView.bounds];
        UIBezierPath * rectPath = [UIBezierPath bezierPathWithRect:self.shadowViewClipRect];
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
        if (CGRectEqualToRect(_shadowViewClipRect, CGRectZero)) {
            contentFrame = [[_editImageBgView.contentView superview] convertRect:_editImageBgView.contentView.frame toView:self];
        }else{
            contentFrame = [[_shadowView superview] convertRect:_shadowViewClipRect toView:self];
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
        
        UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, 64, BK_SYSTEM_TABBAR_UI_HEIGHT);
        [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomNav addSubview:backBtn];
        
        UIImageView * backImageView = [[UIImageView alloc]initWithFrame:CGRectMake((backBtn.bk_width - 20)/2, (backBtn.bk_height - 20)/2, 20, 20)];
        backImageView.clipsToBounds = YES;
        backImageView.contentMode = UIViewContentModeScaleAspectFit;
        backImageView.image = [[BKTool sharedManager] editImageWithImageName:@"clip_back"];
        [backBtn addSubview:backImageView];
        
        UIButton * finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        finishBtn.frame = CGRectMake(_bottomNav.bk_width - 64, 0, 64, BK_SYSTEM_TABBAR_UI_HEIGHT);
        [finishBtn addTarget:self action:@selector(finishBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomNav addSubview:finishBtn];
        
        UIImageView * finishImageView = [[UIImageView alloc]initWithFrame:CGRectMake((finishBtn.bk_width - 20)/2, (finishBtn.bk_height - 20)/2, 20, 20)];
        finishImageView.clipsToBounds = YES;
        finishImageView.contentMode = UIViewContentModeScaleAspectFit;
        finishImageView.image = [[BKTool sharedManager] editImageWithImageName:@"clip_finish"];
        [finishBtn addSubview:finishImageView];
        
        UIButton * rotationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rotationBtn.frame = CGRectMake((_bottomNav.bk_width - 64)/2, 0, 64, BK_SYSTEM_TABBAR_UI_HEIGHT);
        [rotationBtn addTarget:self action:@selector(rotationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomNav addSubview:rotationBtn];
        
        UIImageView * rotationImageView = [[UIImageView alloc]initWithFrame:CGRectMake((rotationBtn.bk_width - 20)/2, (rotationBtn.bk_height - 20)/2, 20, 20)];
        rotationImageView.clipsToBounds = YES;
        rotationImageView.contentMode = UIViewContentModeScaleAspectFit;
        rotationImageView.image = [[BKTool sharedManager] editImageWithImageName:@"left_rotation_90"];
        [rotationBtn addSubview:rotationImageView];
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _bottomNav.bk_width, BK_ONE_PIXEL)];
        line.backgroundColor = BKLineColor;
        [_bottomNav addSubview:line];
    }
    return _bottomNav;
}

-(void)backBtnClick
{
    [self removeSelfAuxiliaryUI];
    
    if (self.backAction) {
        self.backAction();
    }
}

-(void)finishBtnClick
{
    if (self.finishAction) {
        self.finishAction(_shadowViewClipRect,_rotation);
    }
}

-(void)rotationBtnClick:(UIButton*)button
{
    if (![UIApplication sharedApplication].keyWindow.userInteractionEnabled) {
        return;
    }
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    
    switch (_rotation) {
        case BKEditImageRotationPortrait:
        {
            _rotation = BKEditImageRotationLandscapeLeft;
        }
            break;
        case BKEditImageRotationLandscapeLeft:
        {
            _rotation = BKEditImageRotationUpsideDown;
        }
            break;
        case BKEditImageRotationUpsideDown:
        {
            _rotation = BKEditImageRotationLandscapeRight;
        }
            break;
            
        case BKEditImageRotationLandscapeRight:
        {
            _rotation = BKEditImageRotationPortrait;
        }
            break;
        default:
            break;
    }
    
    //算出旋转后缩放宽高比
    CGFloat w_h_ratio = (_editImageBgView.bk_height * 0.8) / _clipFrameView.bk_width;
    if (_clipFrameView.bk_height * w_h_ratio > _editImageBgView.bk_width * 0.8) {
        w_h_ratio = (_editImageBgView.bk_width * 0.8) / _clipFrameView.bk_height;
    }
    //缩放不能大于缩放最大比例
    if (_editImageBgView.zoomScale * w_h_ratio > _editImageBgView.maximumZoomScale) {
        w_h_ratio = _editImageBgView.maximumZoomScale / _editImageBgView.zoomScale;
    }
    
    //缩放裁剪框 算出缩放最小比例
    _clipFrameView.transform = CGAffineTransformRotate(_clipFrameView.transform, -M_PI_2);
    _clipFrameView.transform = CGAffineTransformScale(_clipFrameView.transform, w_h_ratio, w_h_ratio);
    
    //算出缩放最小比例
    CGFloat minimumZoomScale = _editImageBgView.minimumZoomScale * w_h_ratio;
    _editImageBgView.minimumZoomScale = [self calculateScrollMinZoomScaleWithNowMinZoomScale:minimumZoomScale];
    
    _shadowView.hidden = YES;
    _clipFrameView.hidden = YES;
    
    CGFloat contentOffsetX = _editImageBgView.contentOffset.x;
    CGFloat contentOffsetY = _editImageBgView.contentOffset.y;
    
    CGFloat contentInsetTop = _editImageBgView.contentInset.top;
    CGFloat contentInsetLeft = _editImageBgView.contentInset.left;
    
    BK_WEAK_SELF(self);
    [UIView animateWithDuration:0.3 animations:^{
        BK_STRONG_SELF(self);
        
        strongSelf.editImageBgView.transform = CGAffineTransformRotate(strongSelf.editImageBgView.transform, -M_PI_2);
        strongSelf.editImageBgView.frame = CGRectMake(0, 0, strongSelf.bk_width, strongSelf.bk_height - strongSelf.bottomNav.bk_height);
        strongSelf.editImageBgView.zoomScale = strongSelf.editImageBgView.zoomScale * w_h_ratio;
        
        [strongSelf changeShadowViewRect];
        [strongSelf changeBgScrollViewZoomScale];
        
        if (contentOffsetX < 0 && contentOffsetY < 0) {
            strongSelf.editImageBgView.contentOffset = CGPointMake((fabs(contentInsetLeft) - fabs(contentOffsetX)) * w_h_ratio - strongSelf.editImageBgView.contentInset.left, (fabs(contentInsetTop) - fabs(contentOffsetY)) * w_h_ratio - strongSelf.editImageBgView.contentInset.top);
        }else if (contentOffsetX >= 0 && contentOffsetY < 0) {
            strongSelf.editImageBgView.contentOffset = CGPointMake((contentOffsetX + contentInsetLeft) * w_h_ratio - strongSelf.editImageBgView.contentInset.left, (fabs(contentInsetTop) - fabs(contentOffsetY)) * w_h_ratio - strongSelf.editImageBgView.contentInset.top);
        }else if (contentOffsetX < 0 && contentOffsetY >= 0) {
            strongSelf.editImageBgView.contentOffset = CGPointMake((fabs(contentInsetLeft) - fabs(contentOffsetX)) * w_h_ratio - strongSelf.editImageBgView.contentInset.left, (contentOffsetY + contentInsetTop) * w_h_ratio - strongSelf.editImageBgView.contentInset.top);
        }else if (contentOffsetX >= 0 && contentOffsetY >= 0) {
            strongSelf.editImageBgView.contentOffset = CGPointMake((contentOffsetX + contentInsetLeft) * w_h_ratio - strongSelf.editImageBgView.contentInset.left, (contentOffsetY + contentInsetTop) * w_h_ratio - strongSelf.editImageBgView.contentInset.top);
        }
        
    } completion:^(BOOL finished) {
        BK_STRONG_SELF(self);
        
        [strongSelf removeShadowView];
        [strongSelf addShadowView];
        
        [strongSelf removeClipFrameView];
        [strongSelf addClipFrameView];
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
    }];
}

/**
 算出scrollview缩放最小比例

 @param minZoomScale 当前缩放比例
 @return 计算后缩放比例
 */
-(CGFloat)calculateScrollMinZoomScaleWithNowMinZoomScale:(CGFloat)minZoomScale
{
    CGFloat minimumZoomScale = minZoomScale;
    
    CGFloat width_minimumZoomScale = 0;
    CGFloat height_minimumZoomScale = 0;
    
    switch (_rotation) {
        case BKEditImageRotationPortrait:
        case BKEditImageRotationUpsideDown:
        {
            width_minimumZoomScale = _clipFrameView.bk_width / (_editImageBgView.contentView.bk_width / _editImageBgView.zoomScale);
            height_minimumZoomScale = _clipFrameView.bk_height / (_editImageBgView.contentView.bk_height / _editImageBgView.zoomScale);
        }
            break;
        case BKEditImageRotationLandscapeLeft:
        case BKEditImageRotationLandscapeRight:
        {
            width_minimumZoomScale = _clipFrameView.bk_width / (_editImageBgView.contentView.bk_height / _editImageBgView.zoomScale);
            height_minimumZoomScale = _clipFrameView.bk_height / (_editImageBgView.contentView.bk_width / _editImageBgView.zoomScale);
        }
            break;
        default:
            break;
    }
    
    if (width_minimumZoomScale > height_minimumZoomScale) {
        minimumZoomScale = width_minimumZoomScale;
    }else{
        minimumZoomScale = height_minimumZoomScale;
    }
    
    //缩小最小比例为0.5
    if (minimumZoomScale < 0.5) {
        minimumZoomScale = 0.5;
    }
    
    return minimumZoomScale;
}

#pragma mark - 辅助UI

-(void)hiddenSelfAuxiliaryUI
{
    _shadowView.hidden = YES;
    _bottomNav.hidden = YES;
}

-(void)showSelfAuxiliaryUI
{
    _shadowView.hidden = NO;
    _bottomNav.hidden = NO;
}

-(void)removeSelfAuxiliaryUI
{
    [_shadowView removeFromSuperview];
    _shadowView = nil;
    
    [_bottomNav removeFromSuperview];
    _bottomNav = nil;
}

@end
