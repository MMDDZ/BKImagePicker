//
//  BKImageTransitionAnimater.m
//  zhaolin
//
//  Created by zhaolin on 2018/2/2.
//  Copyright © 2018年 zhaolin. All rights reserved.
//

#import "BKImageTransitionAnimater.h"
#import "BKTool.h"

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
    if ([[UIDevice currentDevice].systemVersion floatValue] < 11) {
        return 0.25;
    }else{
        if (_interation) {
            return 0.5;
        }else{
            return 0.25;
        }
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
    
    BK_WEAK_SELF(self);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        BK_STRONG_SELF(self);
        
        if (strongSelf.direction == BKImageTransitionAnimaterDirectionRight) {
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
    
    UITabBarController * tabBarVC = toVC.tabBarController;
    if (toVC.tabBarController) {
        __block BOOL flag = NO;
        [toVC.tabBarController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[UINavigationController class]]) {
                if ([[(UINavigationController*)obj viewControllers] firstObject] == toVC) {
                    flag = YES;
                    *stop = YES;
                }
            }else{
                if (obj == toVC) {
                    flag = YES;
                    *stop = YES;
                }
            }
        }];
        
        if (!flag) {
            if ([[toVC.navigationController viewControllers] count] == 1) {
                flag = YES;
            }
        }
        
        if (flag) {
            tabBarVC.tabBar.hidden = NO;
        }else{
            tabBarVC.tabBar.hidden = YES;
        }
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
    
    BK_WEAK_SELF(self);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        BK_STRONG_SELF(self);
        
        if (strongSelf.direction == BKImageTransitionAnimaterDirectionRight) {
            fromVC.view.bk_x = BK_SCREENW;
            strongSelf.fromShadowView.bk_x = BK_SCREENW;
        }else{
            fromVC.view.bk_x = -BK_SCREENW;
            strongSelf.fromShadowView.bk_x = -BK_SCREENW;
        }
        strongSelf.fromShadowView.alpha = 0;
        toVC.view.bk_x = 0;
        strongSelf.toShadowView.bk_x = 0;
        strongSelf.toShadowView.alpha = 0;
        
    } completion:^(BOOL finished) {
        BK_STRONG_SELF(self);
        
        [strongSelf.fromShadowView removeFromSuperview];
        strongSelf.fromShadowView = nil;
        [strongSelf.toShadowView removeFromSuperview];
        strongSelf.toShadowView = nil;
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled]) {
            fromVC.view.bk_x = 0;
            [toVC.view removeFromSuperview];
        }else {
            if (strongSelf.backFinishAction) {
                strongSelf.backFinishAction();
            }
            [fromVC.view removeFromSuperview];
            if (!tabBarVC.tabBar.hidden) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [tabBarVC.view addSubview:tabBarVC.tabBar];
                });
            }
        }
    }];
}

@end
