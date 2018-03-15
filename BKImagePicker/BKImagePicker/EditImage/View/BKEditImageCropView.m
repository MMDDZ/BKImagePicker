//
//  BKEditImageCropView.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/3/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageCropView.h"
#import "BKImagePickerConst.h"

@interface BKEditImageCropView()

@property (nonatomic,strong) UIView * shadowView;
@property (nonatomic,strong) UIView * clipFrameView;

@property (nonatomic,strong) UIView * bottomNav;

@end

@implementation BKEditImageCropView

#pragma mark - 改变背景ScrollView的ZoomScale

-(void)changeBgScrollViewZoomScale
{
    CGFloat width_gap = self.editImageBgView.bk_width - self.clipFrameView.bk_width;
    CGFloat height_gap = self.editImageBgView.bk_height - self.clipFrameView.bk_height;
    
    self.editImageBgView.contentSize = CGSizeMake(self.editImageBgView.contentView.bk_width + width_gap, self.editImageBgView.contentView.bk_height + height_gap);
    
    self.editImageBgView.contentView.bk_centerX = self.editImageBgView.contentView.bk_width>self.editImageBgView.bk_width?self.editImageBgView.contentSize.width/2.0f:self.editImageBgView.bk_centerX + (self.editImageBgView.contentView.bk_width - self.clipFrameView.bk_width)/2;
    self.editImageBgView.contentView.bk_centerY = self.editImageBgView.contentView.bk_height>self.editImageBgView.bk_height?self.editImageBgView.contentSize.height/2.0f:self.editImageBgView.bk_centerY + (self.editImageBgView.contentView.bk_height - self.clipFrameView.bk_height)/2;
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
    _editImageBgView.minimumZoomScale = 0.8;
    _editImageBgView.clipsToBounds = NO;
    _editImageBgView.bk_height = self.bk_height - self.bottomNav.bk_height;
    
    [UIView animateWithDuration:0.2 animations:^{
        [_editImageBgView setZoomScale:0.8];
    } completion:^(BOOL finished) {
        [self addSubview:self.clipFrameView];
        [self addShadowView];
        
        [self changeBgScrollViewZoomScale];
    }];
}

#pragma mark - addShadowView

-(void)addShadowView
{
    if (_shadowView) {
        [_shadowView removeFromSuperview];
        _shadowView = nil;
    }
    
    [self addSubview:self.shadowView];
}

#pragma mark - shadowView

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

@end
