//
//  BKShowExampleInteractiveTransition.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKShowExampleInteractiveTransition.h"

@interface BKShowExampleInteractiveTransition()<UIGestureRecognizerDelegate>

@property (nonatomic,weak) BKShowExampleImageViewController * vc;//添加手势的vc
@property (nonatomic,assign) CGRect startImageViewRect;//图片起始位置
@property (nonatomic,assign) CGPoint startPoint;//手势起始点

@property (nonatomic,strong) UIPanGestureRecognizer * panGesture;

@end

@implementation BKShowExampleInteractiveTransition

-(void)setStartImageView:(FLAnimatedImageView *)startImageView
{
    _startImageViewRect = [startImageView.superview convertRect:startImageView.frame toView:self.vc.view];
    
    _startImageView = [[FLAnimatedImageView alloc]initWithFrame:_startImageViewRect];
    if (_startImageView.animatedImage) {
        _startImageView.animatedImage = startImageView.animatedImage;
    }else{
        _startImageView.image = startImageView.image;
    }
    _startImageView.clipsToBounds = YES;
    _startImageView.contentMode = UIViewContentModeScaleAspectFill;
}

#pragma mark - 手势

- (void)addPanGestureForViewController:(BKShowExampleImageViewController *)viewController
{
    self.vc = viewController;
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    _panGesture.maximumNumberOfTouches = 1;
    _panGesture.delegate = self;
    [viewController.view addGestureRecognizer:_panGesture];
}

/**
 *  手势过渡的过程
 */
- (void)panGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint nowPoint = [panGesture locationInView:_vc.view];
    
    CGFloat xDistance = (nowPoint.x - _startPoint.x);
    CGFloat yDistance = (nowPoint.y - _startPoint.y);
    
    CGFloat percentage = yDistance / ([UIScreen mainScreen].bounds.size.width / 2);
    if (percentage > 1) {
        percentage = 1;
    }else if (percentage < -0.5) {
        percentage = -0.5;
    }
    
    UIViewController * lastVC = [_vc.navigationController viewControllers][[[_vc.navigationController viewControllers] count] - 2];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            _interation = YES;
            _startPoint = [panGesture locationInView:_panGesture.view];
            
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            if (velocity.y < fabs(velocity.x)) {
                panGesture.enabled = NO;
                return;
            }
            
            [[_vc.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setHidden:YES];
            }];
            if (_isNavHidden) {
                [UIApplication sharedApplication].statusBarHidden = NO;
            }
            
            [[_vc.view superview] insertSubview:lastVC.view atIndex:0];
            [[_vc.view superview] addSubview:_startImageView];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat scale = 1 - fabs(0.4*percentage);
            if (percentage < 0) {
                scale = 1;
                _vc.view.alpha = 1;
            }else{
                _vc.view.alpha = 1 - fabs(0.7*percentage);
            }
            
            _startImageView.center = CGPointMake(CGRectGetMidX(_startImageViewRect) + xDistance, CGRectGetMidY(_startImageViewRect) + yDistance);
            _startImageView.transform = CGAffineTransformMakeScale(scale, scale);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (!panGesture.enabled) {
                panGesture.enabled = YES;
                return;
            }
            
            _interation = NO;
            _startPoint = CGPointZero;
            
            if (percentage > 0.5) {
                [_vc.navigationController popViewControllerAnimated:YES];
            }else{
                [self cancelRecognizerMethodWithPercentage:percentage lastVC:lastVC];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (!panGesture.enabled) {
                panGesture.enabled = YES;
                return;
            }
            
            _interation = NO;
            _startPoint = CGPointZero;
            
            [self cancelRecognizerMethodWithPercentage:percentage lastVC:lastVC];
        }
            break;
        default:
            break;
    }
}

-(void)cancelRecognizerMethodWithPercentage:(CGFloat)percentage lastVC:(UIViewController*)lastVC
{
    CGFloat duration = fabs(0.25 * percentage * 2);
    
    [UIView animateWithDuration:duration animations:^{
        
        _startImageView.center = CGPointMake(CGRectGetMidX(_startImageViewRect), CGRectGetMidY(_startImageViewRect));
        _startImageView.transform = CGAffineTransformMakeScale(1, 1);
        
        _vc.view.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [lastVC.view removeFromSuperview];
        [_startImageView removeFromSuperview];
        
        [[_vc.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setHidden:NO];
        }];
        if (_isNavHidden) {
            [UIApplication sharedApplication].statusBarHidden = YES;
        }else{
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == _panGesture) {
        CGPoint point = [_panGesture velocityInView:_panGesture.view];
        if (_supperScrollView.contentOffset.y <= 0 && point.y > fabs(point.x)) {
            otherGestureRecognizer.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                otherGestureRecognizer.enabled = YES;
            });
        }
    }
    return NO;
}

@end
