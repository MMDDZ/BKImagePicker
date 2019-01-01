//
//  BKEditImageBgView.m
//  BKImagePicker
//
//  Created by BIKE on 2018/3/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageBgView.h"
#import "BKImagePickerMacro.h"
#import "UIView+BKImagePicker.h"

@interface BKEditImageBgView()<UIScrollViewDelegate>

@end

@implementation BKEditImageBgView

#pragma mark - init

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initProperty];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperty];
    }
    return self;
}

-(void)initProperty
{
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.delegate = self;
    self.backgroundColor = BKClearColor;
    self.minimumZoomScale = 1;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

#pragma mark - contentView

-(UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
    }
    return _contentView;
}

#pragma mark - UIScrollViewDelete

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.slideBgScrollViewAction) {
        self.slideBgScrollViewAction();
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if (self.willChangeZoomScaleAction) {
        self.willChangeZoomScaleAction();
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.contentSize = CGSizeMake(self.contentView.bk_width<self.bk_width?self.bk_width:self.contentView.bk_width, self.contentView.bk_height<self.bk_height?self.bk_height:self.contentView.bk_height);
    
    self.contentView.bk_centerX = self.contentView.bk_width>self.bk_width?self.contentSize.width/2.0f:self.bk_centerX;
    self.contentView.bk_centerY = self.contentView.bk_height>self.bk_height?self.contentSize.height/2.0f:self.bk_centerY;
    
    if (self.changeZoomScaleAction) {
        self.changeZoomScaleAction();
    }
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (self.endChangeZoomScaleAction) {
        self.endChangeZoomScaleAction();
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}

@end
