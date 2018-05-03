//
//  BKEditImageClipView.m
//  BKImagePicker
//
//  Created by BIKE on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageClipView.h"
#import "BKTool.h"
#import "BKEditImageClipFrameView.h"

typedef NS_OPTIONS(NSUInteger, BKEditImagePanContains) {
    BKEditImagePanContainsNone = 1 << 0,
    BKEditImagePanContainsLineLeft = 1 << 1,
    BKEditImagePanContainsLineRight = 1 << 2,
    BKEditImagePanContainsLineTop = 1 << 3,
    BKEditImagePanContainsLineBottom = 1 << 4,
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
        
        //预定裁剪模式不能修改裁剪框大小
        if ([BKTool sharedManager].clipSize_width_height_ratio == 0) {
            UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(windowPanGesture:)];
            panGesture.delegate = self;
            panGesture.maximumNumberOfTouches = 1;
            panGesture.bk_dicTag = @{@"type":@"window",@"line":@""};
            [[UIApplication sharedApplication].keyWindow addGestureRecognizer:panGesture];
        }
    }
    return self;
}

#pragma mark - UIPanGestureRecognizer

-(void)windowPanGesture:(UIPanGestureRecognizer*)panGesture
{
    if ([panGesture.bk_dicTag[@"line"] isEqual:@""]) {

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
    
    __block CGFloat X = _clipFrameView.bk_x;
    __block CGFloat Y = _clipFrameView.bk_y;
    __block CGFloat width = _clipFrameView.bk_width;
    __block CGFloat height = _clipFrameView.bk_height;
    
    BKEditImagePanContains panContains = [panGesture.bk_dicTag[@"line"] integerValue];
    
    if (panContains & BKEditImagePanContainsLineLeft) {
        [self moveClipFrameContainsLeftLineWithBeginX:X beginWidth:width translation:translation minX:minX minL:minL calculateComplete:^(CGFloat result_X, CGFloat result_width) {
            X = result_X;
            width = result_width;
        }];
    }else if (panContains & BKEditImagePanContainsLineRight) {
        [self moveClipFrameContainsRightLineWithBeginX:X beginWidth:width translation:translation maxX:maxX minL:minL calculateComplete:^(CGFloat result_X, CGFloat result_width) {
            X = result_X;
            width = result_width;
        }];
    }
    
    if (panContains & BKEditImagePanContainsLineTop) {
        [self moveClipFrameContainsTopLineWithBeginY:Y beginHeight:height translation:translation minY:minY minL:minL calculateComplete:^(CGFloat result_Y, CGFloat result_height) {
            Y = result_Y;
            height = result_height;
        }];
    }else if (panContains & BKEditImagePanContainsLineBottom) {
        [self moveClipFrameContainsBottomLineWithBeginY:Y beginHeight:height translation:translation maxY:maxY minL:minL calculateComplete:^(CGFloat result_Y, CGFloat result_height) {
            Y = result_Y;
            height = result_height;
        }];
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
        panGesture.bk_dicTag = @{@"type":@"window",@"line":@""};
        
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

//移动包含左边线
-(void)moveClipFrameContainsLeftLineWithBeginX:(CGFloat)X beginWidth:(CGFloat)width translation:(CGPoint)translation minX:(CGFloat)minX minL:(CGFloat)minL calculateComplete:(void (^)(CGFloat result_X, CGFloat result_width))complete
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
    
    if (complete) {
        complete(X,width);
    }
}

//移动包含右边线
-(void)moveClipFrameContainsRightLineWithBeginX:(CGFloat)X beginWidth:(CGFloat)width translation:(CGPoint)translation maxX:(CGFloat)maxX minL:(CGFloat)minL calculateComplete:(void (^)(CGFloat result_X, CGFloat result_width))complete
{
    if (width + translation.x < minL) {
        width = minL;
    }else if (X + width + translation.x > maxX) {
        width = maxX - X;
        X = maxX - width;
    }else{
        width = width + translation.x;
    }
    
    if (complete) {
        complete(X,width);
    }
}

//移动包含上边线
-(void)moveClipFrameContainsTopLineWithBeginY:(CGFloat)Y beginHeight:(CGFloat)height translation:(CGPoint)translation minY:(CGFloat)minY minL:(CGFloat)minL calculateComplete:(void (^)(CGFloat result_Y, CGFloat result_height))complete
{
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
    
    if (complete) {
        complete(Y,height);
    }
}

//移动包含底边线
-(void)moveClipFrameContainsBottomLineWithBeginY:(CGFloat)Y beginHeight:(CGFloat)height translation:(CGPoint)translation maxY:(CGFloat)maxY minL:(CGFloat)minL calculateComplete:(void (^)(CGFloat result_Y, CGFloat result_height))complete
{
    if (height + translation.y < minL) {
        height = minL;
    }else if (Y + height + translation.y > maxY) {
        height = maxY - Y;
        Y = maxY - height;
    }else{
        height = height + translation.y;
    }
    
    if (complete) {
        complete(Y,height);
    }
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer.bk_dicTag[@"type"] isEqualToString:@"window"]) {
        
        CGPoint point = [gestureRecognizer locationInView:self];
        
        NSMutableArray * frame_all_rectArr = [NSMutableArray array];
        //四个角
        NSArray * frame_angle_rectArr = @[
                                          NSStringFromCGRect(CGRectMake(CGRectGetMinX(_clipFrameView.frame) - 30, CGRectGetMinY(_clipFrameView.frame) - 30, 60, 60)),
                                          NSStringFromCGRect(CGRectMake(CGRectGetMaxX(_clipFrameView.frame) - 30, CGRectGetMinY(_clipFrameView.frame) - 30, 60, 60)),
                                          NSStringFromCGRect(CGRectMake(CGRectGetMinX(_clipFrameView.frame) - 30, CGRectGetMaxY(_clipFrameView.frame) - 30, 60, 60)),
                                          NSStringFromCGRect(CGRectMake(CGRectGetMaxX(_clipFrameView.frame) - 30, CGRectGetMaxY(_clipFrameView.frame) - 30, 60, 60))];
        [frame_all_rectArr addObjectsFromArray:frame_angle_rectArr];
        
        //当裁剪框高大于2个角的高度(60)时 添加左右两条边拖动框
        if (_clipFrameView.bk_height > 60) {
            //左右两条边
            NSArray * frame_line_rectArr = @[
                                             NSStringFromCGRect(CGRectMake(CGRectGetMinX(_clipFrameView.frame) - 30, CGRectGetMinY(_clipFrameView.frame) + 30, 60, _clipFrameView.bk_height - 60)),
                                             NSStringFromCGRect(CGRectMake(CGRectGetMaxX(_clipFrameView.frame) - 30, CGRectGetMinY(_clipFrameView.frame) + 30, 60, _clipFrameView.bk_height - 60))];
            [frame_all_rectArr addObjectsFromArray:frame_line_rectArr];
        }
        
        //当裁剪框宽大于2个角的宽度(60)时 添加上线两条边拖动框
        if (_clipFrameView.bk_width > 60) {
            //左右两条边
            NSArray * frame_line_rectArr = @[
                                             NSStringFromCGRect(CGRectMake(CGRectGetMinX(_clipFrameView.frame) + 30, CGRectGetMinY(_clipFrameView.frame) - 30, _clipFrameView.bk_width - 60, 60)),
                                             NSStringFromCGRect(CGRectMake(CGRectGetMinX(_clipFrameView.frame) + 30, CGRectGetMaxY(_clipFrameView.frame) - 30, _clipFrameView.bk_width - 60, 60))];
            [frame_all_rectArr addObjectsFromArray:frame_line_rectArr];
        }
        
        [frame_all_rectArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGRect rect = CGRectFromString(obj);
            
            if (CGRectContainsPoint(rect, point)) {
                
                switch (idx) {
                    case 0:
                    {
                        gestureRecognizer.bk_dicTag = @{@"type":@"window",@"line":@(BKEditImagePanContainsLineLeft | BKEditImagePanContainsLineTop)};
                    }
                        break;
                    case 1:
                    {
                        gestureRecognizer.bk_dicTag = @{@"type":@"window",@"line":@(BKEditImagePanContainsLineRight | BKEditImagePanContainsLineTop)};
                    }
                        break;
                    case 2:
                    {
                        gestureRecognizer.bk_dicTag = @{@"type":@"window",@"line":@(BKEditImagePanContainsLineLeft | BKEditImagePanContainsLineBottom)};
                    }
                        break;
                    case 3:
                    {
                        gestureRecognizer.bk_dicTag = @{@"type":@"window",@"line":@(BKEditImagePanContainsLineRight | BKEditImagePanContainsLineBottom)};
                    }
                        break;
                    case 4:
                    {
                        gestureRecognizer.bk_dicTag = @{@"type":@"window",@"line":@(BKEditImagePanContainsLineLeft)};
                    }
                        break;
                    case 5:
                    {
                        gestureRecognizer.bk_dicTag = @{@"type":@"window",@"line":@(BKEditImagePanContainsLineRight)};
                    }
                        break;
                    case 6:
                    {
                        gestureRecognizer.bk_dicTag = @{@"type":@"window",@"line":@(BKEditImagePanContainsLineTop)};
                    }
                        break;
                    case 7:
                    {
                        gestureRecognizer.bk_dicTag = @{@"type":@"window",@"line":@(BKEditImagePanContainsLineBottom)};
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
 
    _editImageBgView.minimumZoomScale = 0.8;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [self.editImageBgView setZoomScale:0.8];
        
        if (self.editImageBgView.contentView.bk_height > self.editImageBgView.contentView.bk_width) {
            CGFloat editImageBgViewHeight = self.editImageBgView.contentView.bk_height/self.editImageBgView.zoomScale;
            if (editImageBgViewHeight > self.editImageBgView.bk_height && editImageBgViewHeight < self.bk_height) {
                
                CGFloat contentOffsetY = (editImageBgViewHeight - self.editImageBgView.bk_height)*0.8/2;
                self.editImageBgView.contentOffset = CGPointMake(0, -contentOffsetY);
            }else if (editImageBgViewHeight > self.bk_height) {
                self.editImageBgView.contentOffset = CGPointMake(0, -self.editImageBgView.bk_height*0.1);
            }
        }
        
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
        if (_shadowViewClipRect.size.height > _editImageBgView.bk_height) {
            _shadowViewClipRect.size.height = _editImageBgView.bk_height;
        }
        
        //如果是预定裁剪模式 按照预定比例修改裁剪框大小
        if ([BKTool sharedManager].clipSize_width_height_ratio != 0) {
            CGFloat clipRect_width_height_ratio = _shadowViewClipRect.size.width / _shadowViewClipRect.size.height;
            if (clipRect_width_height_ratio > [BKTool sharedManager].clipSize_width_height_ratio) {
                CGFloat new_clipRect_width = _shadowViewClipRect.size.height * [BKTool sharedManager].clipSize_width_height_ratio;
                _shadowViewClipRect.origin.x = (_shadowViewClipRect.size.width - new_clipRect_width)/2;
                _shadowViewClipRect.size.width = new_clipRect_width;
            }else{
                CGFloat new_clipRect_height = _shadowViewClipRect.size.width / [BKTool sharedManager].clipSize_width_height_ratio;
                _shadowViewClipRect.origin.y = (_shadowViewClipRect.size.height - new_clipRect_height)/2;
                _shadowViewClipRect.size.height = new_clipRect_height;
            }
        }
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
        
        CGRect contentFrame = CGRectZero;
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
        
        //不是预定裁剪模式有旋转
        if ([BKTool sharedManager].clipSize_width_height_ratio == 0) {
            UIButton * rotationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            rotationBtn.frame = CGRectMake((_bottomNav.bk_width - 64)/2, 0, 64, BK_SYSTEM_TABBAR_UI_HEIGHT);
            [rotationBtn addTarget:self action:@selector(rotationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomNav addSubview:rotationBtn];
            
            UIImageView * rotationImageView = [[UIImageView alloc]initWithFrame:CGRectMake((rotationBtn.bk_width - 20)/2, (rotationBtn.bk_height - 20)/2, 20, 20)];
            rotationImageView.clipsToBounds = YES;
            rotationImageView.contentMode = UIViewContentModeScaleAspectFit;
            rotationImageView.image = [[BKTool sharedManager] editImageWithImageName:@"left_rotation_90"];
            [rotationBtn addSubview:rotationImageView];
        }
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _bottomNav.bk_width, BK_ONE_PIXEL)];
        line.backgroundColor = BKLineColor;
        [_bottomNav addSubview:line];
    }
    return _bottomNav;
}

-(void)backBtnClick
{
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
    
    //缩小最小比例为0.4
    if (minimumZoomScale < 0.4) {
        minimumZoomScale = 0.4;
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
