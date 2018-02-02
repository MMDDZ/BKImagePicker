//
//  BKImageNavViewController.m
//  zhaolin
//
//  Created by zhaolin on 2018/2/2.
//  Copyright © 2018年 zhaolin. All rights reserved.
//

#import "BKImageNavViewController.h"
#import "BKImagePickerConst.h"

@interface BKImageNavViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

/**
 下一个VC
 */
@property (nonatomic,weak) UIViewController * nextVC;

@end

@implementation BKImageNavViewController

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBarHidden = YES;
    self.interactivePopGestureRecognizer.delegate = self;
}

#pragma mark - push / pop

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _customTransition = nil;
    
    if (!_isCustomTransition) {
        self.delegate = self;
    }
    _isCustomTransition = NO;
    
    viewController.dicTag = @{@"direction":@(_direction),@"popVC":_popVC?_popVC:[NSNull null]};
    _nextVC = viewController;
    
    _direction = BKImageTransitionAnimaterDirectionRight;
    _popVC = nil;
    
    [super pushViewController:viewController animated:animated];
}

- (nullable UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if ([self.viewControllers count] == 2) {
        UITabBarController * tabBarVC = [self.viewControllers firstObject].tabBarController;
        if (tabBarVC) {
            [tabBarVC.view addSubview:tabBarVC.tabBar];
        }
    }
    
    return [super popViewControllerAnimated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == [self.viewControllers firstObject]) {
        UITabBarController * tabBarVC = viewController.tabBarController;
        if (tabBarVC) {
            [tabBarVC.view addSubview:tabBarVC.tabBar];
        }
    }
    
    return [super popToViewController:viewController animated:animated];
}

- (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    UIViewController * firstVC = [self.viewControllers firstObject];
    UITabBarController * tabBarVC = firstVC.tabBarController;
    if (tabBarVC) {
        [tabBarVC.view addSubview:tabBarVC.tabBar];
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

#pragma mark - 自定义过场动画

-(void)setPopVC:(UIViewController *)popVC
{
    _popVC = popVC;
    
    if (_customTransition) {
        _customTransition.backVC = _popVC;
    }
}

#pragma mark - BKImagePercentDrivenInteractiveTransition

-(BKImagePercentDrivenInteractiveTransition*)customTransition
{
    if (!_customTransition) {
        
        switch (_direction) {
            case BKImageTransitionAnimaterDirectionRight:
            {
                _customTransition = [[BKImagePercentDrivenInteractiveTransition alloc] initWithTransitionGestureDirection:BKImagePercentDrivenInteractiveTransitionGestureDirectionRight];
            }
                break;
            case BKImageTransitionAnimaterDirectionLeft:
            {
                _customTransition = [[BKImagePercentDrivenInteractiveTransition alloc] initWithTransitionGestureDirection:BKImagePercentDrivenInteractiveTransitionGestureDirectionLeft];
            }
                break;
            default:
                break;
        }
        [_customTransition addPanGestureForViewController:_nextVC];
        if (_popVC) {
            _customTransition.backVC = _popVC;
        }
    }
    
    return _customTransition;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        
        BKImageTransitionAnimater * transitionAnimater = [[BKImageTransitionAnimater alloc] initWithTransitionType:BKImageTransitionAnimaterTypePush transitionAnimaterDirection:_direction];
        
        return transitionAnimater;
    }else{
        
        BKImageTransitionAnimater * transitionAnimater = [[BKImageTransitionAnimater alloc] initWithTransitionType:BKImageTransitionAnimaterTypePop transitionAnimaterDirection:_direction];
        BK_WEAK_SELF(self);
        [transitionAnimater setBackFinishAction:^{
            BK_STRONG_SELF(self);
            strongSelf.customTransition = nil;
            
            NSDictionary * vcMessageDic = toVC.dicTag;
            strongSelf.popVC = [vcMessageDic[@"popVC"] isKindOfClass:[NSNull class]]?nil:vcMessageDic[@"popVC"];
            strongSelf.direction = [vcMessageDic[@"direction"] integerValue];
            strongSelf.nextVC = toVC;
            [strongSelf customTransition];//重置上一个VC导航设置
        }];
        
        return transitionAnimater;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.customTransition.interation?self.customTransition:nil;
}

#pragma mark - UIGestureRecognizerDelegate 在根视图时不响应interactivePopGestureRecognizer手势

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self.viewControllers count] != 1 && ![[self valueForKey:@"isTransitioning"] boolValue];
}

#pragma iPhoneX黑条隐藏

-(BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}

#pragma mark - 屏幕旋转处理

- (BOOL)shouldAutorotate
{
    return [self.viewControllers.lastObject shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.viewControllers.lastObject supportedInterfaceOrientations];
}

@end
