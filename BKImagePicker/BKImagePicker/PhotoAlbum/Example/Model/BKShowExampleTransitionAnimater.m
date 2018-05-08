//
//  BKShowExampleTransitionAnimater.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/5.
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
        self.alphaPercentage = 1;
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
        {
            [self pushAnimation:transitionContext];
        }
            break;
        case BKShowExampleTransitionPop:
        {
            [self popAnimation:transitionContext];
        }
            break;
    }
}

- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    BKShowExampleImageViewController * toVC = (BKShowExampleImageViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    UIView * containerView = [transitionContext containerView];
    
    [containerView addSubview:fromVC.view];
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
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    BKShowExampleImageViewController * real_fromVC = nil;
    if ([fromVC isKindOfClass:[UINavigationController class]]) {
        real_fromVC = (BKShowExampleImageViewController*)[((UINavigationController*)fromVC).viewControllers firstObject];
        fromVC.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    }else{
        real_fromVC = (BKShowExampleImageViewController*)fromVC;
    }
    
    if (![[real_fromVC.view subviews] containsObject:self.startImageView]) {
        CGRect rect = [[self.startImageView superview] convertRect:self.startImageView.frame toView:fromVC.view];
        self.startImageView.frame = rect;
        [fromVC.view addSubview:self.startImageView];
    }
    
    [[real_fromVC.view subviews] enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != self.startImageView) {
            obj.hidden = YES;
        }
    }];
    real_fromVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:self.alphaPercentage];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    UIView * containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    [containerView addSubview:fromVC.view];
    
    //延迟0秒 在ios 11.3 iphone7 状况下不延迟 有可能卡死不动
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            if (CGRectEqualToRect(self.endRect, CGRectZero)) {
                self.startImageView.alpha = 0;
            }else{
                self.startImageView.frame = self.endRect;
            }
            real_fromVC.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        } completion:^(BOOL finished) {
            [self.startImageView removeFromSuperview];
            [transitionContext completeTransition:YES];
            
            if (self.endTransitionAnimateAction) {
                self.endTransitionAnimateAction();
            }
        }];
    });
}

@end
