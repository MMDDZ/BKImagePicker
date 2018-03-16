//
//  BKEditImageCropView.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageCropView.h"
#import "BKImagePickerConst.h"

typedef NS_ENUM(NSUInteger, BKEditImageRotation) {
    BKEditImageRotationVertical = 0, //竖直
    BKEditImageRotationHorizontal, //水平
};

@interface BKEditImageCropView()

@property (nonatomic,strong) UIView * shadowView;
@property (nonatomic,strong) UIView * clipFrameView;

@property (nonatomic,strong) UIView * bottomNav;

@property (nonatomic,assign) BKEditImageRotation rotation;

@end

@implementation BKEditImageCropView

#pragma mark - 改变背景ScrollView的ZoomScale

-(void)changeBgScrollViewZoomScale
{
    if (_rotation == BKEditImageRotationVertical) {
        
        self.editImageBgView.contentSize = CGSizeMake(self.editImageBgView.contentView.bk_width<self.editImageBgView.bk_width?self.editImageBgView.bk_width:self.editImageBgView.contentView.bk_width, self.editImageBgView.contentView.bk_height<self.editImageBgView.bk_height?self.editImageBgView.bk_height:self.editImageBgView.contentView.bk_height);
        
        CGFloat width_gap = (self.editImageBgView.contentView.bk_width > self.editImageBgView.bk_width ? self.editImageBgView.bk_width : self.editImageBgView.contentView.bk_width) - self.clipFrameView.bk_width;
        CGFloat height_gap = (self.editImageBgView.contentView.bk_height > self.editImageBgView.bk_height ? self.editImageBgView.bk_height : self.editImageBgView.contentView.bk_height) - self.clipFrameView.bk_height;
        
        self.editImageBgView.contentInset = UIEdgeInsetsMake(height_gap/2, width_gap/2, height_gap/2, width_gap/2);
        
        self.editImageBgView.contentView.bk_centerX = self.editImageBgView.contentView.bk_width>self.editImageBgView.bk_width?self.editImageBgView.contentSize.width/2.0f:self.editImageBgView.bk_centerX;
        self.editImageBgView.contentView.bk_centerY = self.editImageBgView.contentView.bk_height>self.editImageBgView.bk_height?self.editImageBgView.contentSize.height/2.0f:self.editImageBgView.bk_centerY;
    }else{
        
        self.editImageBgView.contentSize = CGSizeMake(self.editImageBgView.contentView.bk_height<self.editImageBgView.bk_height?self.editImageBgView.bk_height:self.editImageBgView.contentView.bk_width, self.editImageBgView.contentView.bk_width<self.editImageBgView.bk_width?self.editImageBgView.bk_width:self.editImageBgView.contentView.bk_height);
        
        CGFloat width_gap = (self.editImageBgView.contentView.bk_height > self.editImageBgView.bk_width ? self.editImageBgView.bk_width : self.editImageBgView.contentView.bk_height) - self.clipFrameView.bk_width;
        CGFloat height_gap = (self.editImageBgView.contentView.bk_width > self.editImageBgView.bk_height ? self.editImageBgView.bk_height : self.editImageBgView.contentView.bk_width) - self.clipFrameView.bk_height;
        
        self.editImageBgView.contentInset = UIEdgeInsetsMake(width_gap/2, height_gap/2, width_gap/2, height_gap/2);
        
        self.editImageBgView.contentView.bk_centerX = self.editImageBgView.contentView.bk_height>self.editImageBgView.bk_height?self.editImageBgView.contentSize.width/2.0f:self.editImageBgView.bk_centerY;
        self.editImageBgView.contentView.bk_centerY = self.editImageBgView.contentView.bk_width>self.editImageBgView.bk_width?self.editImageBgView.contentSize.height/2.0f:self.editImageBgView.bk_centerX;
    }
    
    
}

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.bottomNav];
    }
    return self;
}

#pragma mark - showCropView

-(void)showCropView
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
        [self addSubview:self.clipFrameView];
        [self addShadowView];
        
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
    [self addSubview:self.shadowView];
}

-(UIView*)shadowView
{
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:self.bounds];
        
        UIBezierPath * path = [UIBezierPath bezierPathWithRect:_shadowView.bounds];
        UIBezierPath * rectPath = [UIBezierPath bezierPathWithRect:self.clipFrameView.frame];
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

-(UIView*)clipFrameView
{
    if (!_clipFrameView) {
        
        CGRect clipFrame = [[_editImageBgView.contentView superview] convertRect:_editImageBgView.contentView.frame toView:self];
        
        _clipFrameView = [[UIView alloc]initWithFrame:clipFrame];
        _clipFrameView.layer.borderColor = [UIColor whiteColor].CGColor;
        _clipFrameView.layer.borderWidth = 1;
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
    if (!button.userInteractionEnabled) {
        return;
    }
    button.userInteractionEnabled = NO;
    
    [self removeShadowView];
    
    if (_rotation == BKEditImageRotationVertical) {
        _rotation = BKEditImageRotationHorizontal;
    }else{
        _rotation = BKEditImageRotationVertical;
    }
    
    CGFloat w_h_ratio = _clipFrameView.bk_width / _clipFrameView.bk_height;
    _editImageBgView.minimumZoomScale = _editImageBgView.minimumZoomScale * w_h_ratio;
    
    [UIView animateWithDuration:0.3 animations:^{
        _editImageBgView.transform = CGAffineTransformRotate(_editImageBgView.transform, -M_PI_2);
        _editImageBgView.frame = CGRectMake(0, 0, self.bk_width, self.bk_height - self.bottomNav.bk_height);
        _editImageBgView.zoomScale = _editImageBgView.zoomScale * w_h_ratio;
        
        _clipFrameView.transform = CGAffineTransformRotate(_clipFrameView.transform, -M_PI_2);
        _clipFrameView.transform = CGAffineTransformScale(_clipFrameView.transform, w_h_ratio, w_h_ratio);
        
        [self changeBgScrollViewZoomScale];
    } completion:^(BOOL finished) {
        
        NSLog(@"%@",NSStringFromCGRect(self.editImageBgView.frame));
        NSLog(@"%@",NSStringFromCGRect(self.clipFrameView.frame));
        NSLog(@"%@",NSStringFromCGRect(self.editImageBgView.contentView.frame));
        NSLog(@"%@",NSStringFromCGSize(self.editImageBgView.contentSize));
        
        [self addShadowView];
        button.userInteractionEnabled = YES;
    }];
}

@end
