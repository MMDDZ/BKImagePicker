//
//  DSPercentDrivenInteractiveTransition.m
//  
//
//  Created by BIKE on 2018/7/12.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "DSPercentDrivenInteractiveTransition.h"

@interface DSPercentDrivenInteractiveTransition ()<UIGestureRecognizerDelegate>

/**
 当前VC
 */
@property (nonatomic,weak) UIViewController * currentVC;
/**
 滑动手势
 */
@property (nonatomic,strong) UIPanGestureRecognizer * panGesture;
/**
 手势方向
 */
@property (nonatomic, assign) DSPercentDrivenInteractiveTransitionGestureDirection direction;

@end

@implementation DSPercentDrivenInteractiveTransition

#pragma mark - init

/**
 创建方法
 
 @param direction 手势的方向
 @return DSPercentDrivenInteractiveTransition
 */
- (instancetype)initWithTransitionGestureDirection:(DSPercentDrivenInteractiveTransitionGestureDirection)direction
{
    self = [super init];
    if (self) {
        _direction = direction;
        _enble = YES;
    }
    return self;
}

#pragma mark - 手势

-(void)addPanGestureForViewController:(UIViewController *)viewController
{
    self.currentVC = viewController;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.panGesture.delegate = self;
    [viewController.view addGestureRecognizer:self.panGesture];
}

/**
 *  手势过渡的过程
 */
- (void)panGesture:(UIPanGestureRecognizer *)panGesture
{
    if (!_enble) {
        panGesture.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            panGesture.enabled = YES;
        });
    }
    
    CGPoint point = [panGesture velocityInView:panGesture.view];
    BOOL isPassFlag = NO;
    CGFloat persent = 0;
    switch (_direction) {
        case DSPercentDrivenInteractiveTransitionGestureDirectionRight:
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
        case DSPercentDrivenInteractiveTransitionGestureDirectionLeft:
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
                case DSPercentDrivenInteractiveTransitionGestureDirectionRight:
                {
                    if (point.x > 0 && point.x > fabs(point.y)) {
                        [self backMethod];
                    }
                }
                    break;
                case DSPercentDrivenInteractiveTransitionGestureDirectionLeft:
                {
                    if (point.x < 0 && fabs(point.x) > fabs(point.y)) {
                        [self backMethod];
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

#pragma mark - 返回方法

-(void)backMethod
{
    if (_backVC) {
        [_currentVC.navigationController popToViewController:_backVC animated:YES];
    }else{
        [_currentVC.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.enble && gestureRecognizer == self.panGesture) {
        return NO;
    }
    return YES;
}

@end
