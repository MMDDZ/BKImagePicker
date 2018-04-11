//
//  BKShowExampleTransitionAnimater.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKShowExampleTransitionAnimater.h"
#import "BKShowExampleImageViewController.h"

@interface BKShowExampleTransitionAnimater()

@property (nonatomic,assign) BKShowExampleTransition type;

@end

@implementation BKShowExampleTransitionAnimater

-(instancetype)initWithTransitionType:(BKShowExampleTransition)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    switch (_type) {
        case BKShowExampleTransitionPush:
            [self pushAnimation:transitionContext];
            break;
            
        case BKShowExampleTransitionPop:
            [self popAnimation:transitionContext];
            break;
    }
}

- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    BKShowExampleImageViewController * toVC = (BKShowExampleImageViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    UIView * containerView = [transitionContext containerView];
    
    [containerView addSubview:toVC.view];
    [containerView addSubview:_startImageView];
    [containerView addSubview:toVC.topNavView];
    [containerView addSubview:toVC.bottomNavView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.startImageView.frame = self.endRect;
        toVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    } completion:^(BOOL finished) {
        
        [self.startImageView removeFromSuperview];
        [toVC.view addSubview:toVC.topNavView];
        [toVC.view addSubview:toVC.bottomNavView];
        [transitionContext completeTransition:YES];
        
        if (self.endTransitionAnimateAction) {
            self.endTransitionAnimateAction();
        }
    }];
}

- (void)popAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    BKShowExampleImageViewController * fromVC = (BKShowExampleImageViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[fromVC.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setHidden:YES];
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    UIView * containerView = [transitionContext containerView];
    [containerView insertSubview:toVC.view atIndex:0];
    [containerView addSubview:_startImageView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if (CGRectEqualToRect(self.endRect, CGRectZero)) {
            self.startImageView.alpha = 0;
            fromVC.view.alpha = 0;
        }else{
            self.startImageView.frame = self.endRect;
            fromVC.view.alpha = 0.3;
        }
        
    } completion:^(BOOL finished) {
        
        [self.startImageView removeFromSuperview];
        [transitionContext completeTransition:YES];
        
        if (self.endTransitionAnimateAction) {
            self.endTransitionAnimateAction();
        }
    }];
}

@end
