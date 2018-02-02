//
//  BKImagePercentDrivenInteractiveTransition.m
//  zhaolin
//
//  Created by zhaolin on 2018/2/2.
//  Copyright © 2018年 zhaolin. All rights reserved.
//

#import "BKImagePercentDrivenInteractiveTransition.h"

@interface BKImagePercentDrivenInteractiveTransition ()

/**
 当前VC
 */
@property (nonatomic, weak) UIViewController * currentVC;

/**
 手势方向
 */
@property (nonatomic, assign) BKImagePercentDrivenInteractiveTransitionGestureDirection direction;

@end

@implementation BKImagePercentDrivenInteractiveTransition

#pragma mark - init

- (instancetype)initWithTransitionGestureDirection:(BKImagePercentDrivenInteractiveTransitionGestureDirection)direction
{
    self = [super init];
    if (self) {
        _direction = direction;
        _enble = YES;
    }
    return self;
}

- (void)addPanGestureForViewController:(UIViewController *)viewController
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    self.currentVC = viewController;
    [viewController.view addGestureRecognizer:pan];
}

/**
 *  手势过渡的过程
 */
- (void)panGesture:(UIPanGestureRecognizer *)panGesture
{
    if (!_enble) {
        panGesture.enabled = NO;
    }
    
    CGPoint point = [panGesture velocityInView:panGesture.view];
    BOOL isPassFlag = NO;
    CGFloat persent = 0;
    switch (_direction) {
        case BKImagePercentDrivenInteractiveTransitionGestureDirectionRight:
        {
            CGFloat transitionX = [panGesture translationInView:panGesture.view].x;
            persent = transitionX / panGesture.view.frame.size.width;
            
            if (point.x > 500) {
                isPassFlag = YES;
            }else{
                isPassFlag = NO;
            }
        }
            break;
        case BKImagePercentDrivenInteractiveTransitionGestureDirectionLeft:
        {
            CGFloat transitionX = -[panGesture translationInView:panGesture.view].x;
            persent = transitionX / panGesture.view.frame.size.width;
            
            if (point.x < -500) {
                isPassFlag = YES;
            }else{
                isPassFlag = NO;
            }
        }
            break;
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.interation = YES;
            
            switch (_direction) {
                case BKImagePercentDrivenInteractiveTransitionGestureDirectionRight:
                {
                    if (point.x > 0 && point.x > fabs(point.y)) {
                        if (_backVC) {
                            [_currentVC.navigationController popToViewController:_backVC animated:YES];
                        }else{
                            [_currentVC.navigationController popViewControllerAnimated:YES];
                        }
                    }
                }
                    break;
                case BKImagePercentDrivenInteractiveTransitionGestureDirectionLeft:
                {
                    if (point.x < 0 && fabs(point.x) > fabs(point.y)) {
                        if (_backVC) {
                            [_currentVC.navigationController popToViewController:_backVC animated:YES];
                        }else{
                            [_currentVC.navigationController popViewControllerAnimated:YES];
                        }
                    }
                }
                    break;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self updateInteractiveTransition:persent];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            self.interation = NO;
            if (persent > 0.5 || isPassFlag) {
                [self finishInteractiveTransition];
            }else{
                [self cancelInteractiveTransition];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            self.interation = NO;
            [self cancelInteractiveTransition];
        }
            break;
        default:
            break;
    }
}

@end
