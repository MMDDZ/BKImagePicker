//
//  BKShowExampleInteractiveTransition.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKShowExampleInteractiveTransition.h"

@interface BKShowExampleInteractiveTransition()

/**
 添加手势的vc
 */
@property (nonatomic, weak) BKShowExampleImageViewController * vc;
/**
 图片原来父视图
 */
@property (nonatomic, weak) UIView * imageSupperView;
/**
 图片起始位置
 */
@property (nonatomic, assign) CGRect startImageViewRect;
/**
 手势起始点
 */
@property (nonatomic, assign) CGPoint startPoint;
/**
 是否手势移动
 */
@property (nonatomic, assign) BOOL isMoveFlag;
/**
 x轴移动
 */
@property (nonatomic, assign) CGFloat xDistance;
/**
 y轴移动
 */
@property (nonatomic, assign) CGFloat yDistance;

@end

@implementation BKShowExampleInteractiveTransition

-(void)setStartImageView:(FLAnimatedImageView *)startImageView
{
    _startImageView = startImageView;
    _startImageViewRect = _startImageView.frame;
}

#pragma mark - 手势

- (void)addPanGestureForViewController:(BKShowExampleImageViewController *)viewController
{
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    panGesture.maximumNumberOfTouches = 1;
    self.vc = viewController;
    [viewController.view addGestureRecognizer:panGesture];
}

/**
 *  手势过渡的过程
 */
- (void)panGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint nowPoint = [panGesture locationInView:_vc.view];
    CGFloat distance = 0;
    if (!CGPointEqualToPoint(nowPoint, CGPointZero) && !CGPointEqualToPoint(_startPoint, CGPointZero)) {
        _xDistance = (nowPoint.x - _startPoint.x);
        _yDistance = (nowPoint.y - _startPoint.y);
        distance = sqrt(pow(_xDistance, 2) + pow(_yDistance, 2));
    }
    CGFloat percentage = distance / ([UIScreen mainScreen].bounds.size.width / 2);
    if (fabs(percentage) > 1) {
        percentage = 1;
    }
    
    UIViewController * lastVC = [_vc.navigationController viewControllers][[[_vc.navigationController viewControllers] count] - 2];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            _interation = YES;
            _startPoint = [panGesture locationInView:_vc.view];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (!_isMoveFlag) {
                _isMoveFlag = YES;
                [[_vc.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj setHidden:YES];
                }];
                if (_isNavHidden) {
                    [UIApplication sharedApplication].statusBarHidden = NO;
                }
                
                _imageSupperView = [_startImageView superview];
                
                [[_vc.view superview] insertSubview:lastVC.view atIndex:0];
                [[_vc.view superview] addSubview:_startImageView];
            }
            
            CGFloat scale = 1 - fabs(0.4*percentage);
            _startImageView.center = CGPointMake(CGRectGetMidX(_startImageViewRect) + _xDistance, CGRectGetMidY(_startImageViewRect) + _yDistance);
            _startImageView.transform = CGAffineTransformMakeScale(scale, scale);
            
            _vc.view.alpha = 1 - fabs(0.7*percentage);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            _interation = NO;
            _isMoveFlag = NO;
            _startPoint = CGPointZero;
            
            if (percentage > 0.4) {
                [_vc.navigationController popViewControllerAnimated:YES];
            }else{
                [self cancelRecognizerMethodWithPercentage:percentage lastVC:lastVC];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            _interation = NO;
            _isMoveFlag = NO;
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
    CGFloat duration = 0.25 * percentage * 2;
    
    [UIView animateWithDuration:duration animations:^{
        
        _startImageView.center = CGPointMake(CGRectGetMidX(_startImageViewRect), CGRectGetMidY(_startImageViewRect));
        _startImageView.transform = CGAffineTransformMakeScale(1, 1);
        
        _vc.view.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [lastVC.view removeFromSuperview];
        [_startImageView removeFromSuperview];
        [_imageSupperView addSubview:_startImageView];
        
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

@end
