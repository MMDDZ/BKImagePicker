//
//  BKImageTransitionAnimater.m
//  zhaolin
//
//  Created by zhaolin on 2018/2/2.
//  Copyright © 2018年 zhaolin. All rights reserved.
//

#import "BKImageTransitionAnimater.h"
#import "BKImagePickerConst.h"

@interface BKImageTransitionAnimater ()

@property (nonatomic,assign) BKImageTransitionAnimaterType type;
@property (nonatomic,assign) BKImageTransitionAnimaterDirection direction;

@property (nonatomic,strong) UIView * fromShadowView;
@property (nonatomic,strong) UIView * toShadowView;

@end

@implementation BKImageTransitionAnimater

- (instancetype)initWithTransitionType:(BKImageTransitionAnimaterType)type transitionAnimaterDirection:(BKImageTransitionAnimaterDirection)direction
{
    self = [super init];
    if (self) {
        _type = type;
        _direction = direction;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    if (_interation) {
        return 0.5;
    }else{
        return 0.25;
    }
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    switch (_type) {
        case BKImageTransitionAnimaterTypePush:
        {
            [self nextAnimation:transitionContext];
        }
            break;
        case BKImageTransitionAnimaterTypePop:
        {
            [self backAnimation:transitionContext];
        }
            break;
    }
}

- (void)nextAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UITabBarController * tabBarVC = nil;
    if (fromVC.tabBarController && [[fromVC.navigationController viewControllers] count] == 2) {
        tabBarVC = fromVC.tabBarController;
    }
    
    if (_direction == BKImageTransitionAnimaterDirectionRight) {
        toVC.view.bk_x = BK_SCREENW;
    }else {
        toVC.view.bk_x = -BK_SCREENW;
    }
    
    UIView * containerView = [transitionContext containerView];
    [containerView addSubview:fromVC.view];
    if (tabBarVC) {
        [fromVC.view addSubview:tabBarVC.tabBar];
    }
    [containerView addSubview:toVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        if (_direction == BKImageTransitionAnimaterDirectionRight) {
            fromVC.view.bk_x = -BK_SCREENW/2;
        }else {
            fromVC.view.bk_x = BK_SCREENW/2;
        }
        
        toVC.view.bk_x = 0;
        
    } completion:^(BOOL finished) {
        
        [fromVC.view removeFromSuperview];
        
        [transitionContext completeTransition:YES];
        
    }];
}

- (void)backAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UITabBarController * tabBarVC = nil;
    if (toVC.tabBarController && [[fromVC.navigationController viewControllers] count] == 1) {
        tabBarVC = toVC.tabBarController;
    }
    
    UIView * containerView = [transitionContext containerView];
    
    if (_direction == BKImageTransitionAnimaterDirectionRight) {
        toVC.view.bk_x = -BK_SCREENW/2;
    }else {
        toVC.view.bk_x = BK_SCREENW/2;
    }
    [containerView addSubview:toVC.view];
    if (tabBarVC) {
        [toVC.view addSubview:tabBarVC.tabBar];
    }
    
    if (!_toShadowView) {
        _toShadowView = [[UIView alloc]initWithFrame:toVC.view.frame];
        _toShadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.15];
        [containerView addSubview:_toShadowView];
    }
    
    if (!_fromShadowView) {
        _fromShadowView = [[UIView alloc]initWithFrame:fromVC.view.frame];
        _fromShadowView.backgroundColor = [UIColor whiteColor];
        _fromShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _fromShadowView.layer.shadowOpacity = 0.45;
        _fromShadowView.layer.shadowOffset = CGSizeMake(0, 0);
        _fromShadowView.layer.shadowRadius = 7;
        [containerView addSubview:_fromShadowView];
    }
    
    [containerView addSubview:fromVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        if (_direction == BKImageTransitionAnimaterDirectionRight) {
            fromVC.view.bk_x = BK_SCREENW;
            _fromShadowView.bk_x = BK_SCREENW;
        }else{
            fromVC.view.bk_x = -BK_SCREENW;
            _fromShadowView.bk_x = -BK_SCREENW;
        }
        _fromShadowView.alpha = 0;
        toVC.view.bk_x = 0;
        _toShadowView.bk_x = 0;
        _toShadowView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [_fromShadowView removeFromSuperview];
        _fromShadowView = nil;
        [_toShadowView removeFromSuperview];
        _toShadowView = nil;
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled]) {
            fromVC.view.bk_x = 0;
            [toVC.view removeFromSuperview];
        }else {
            if (self.backFinishAction) {
                self.backFinishAction();
            }
            [fromVC.view removeFromSuperview];
            if (tabBarVC) {
                [tabBarVC.view addSubview:tabBarVC.tabBar];
            }
        }
    }];
}

@end
