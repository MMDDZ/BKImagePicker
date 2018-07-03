//
//  BKImageNavViewController.m
//  zhaolin
//
//  Created by BIKE on 2018/2/2.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImageNavViewController.h"
#import "BKImagePercentDrivenInteractiveTransition.h"
#import "BKTool.h"

@interface BKImageNavViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

/**
 下一个VC
 */
@property (nonatomic,weak) UIViewController * nextVC;

/**
 交互方法
 */
@property (nonatomic,strong) BKImagePercentDrivenInteractiveTransition * customTransition;

@end

@implementation BKImageNavViewController

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBarHidden = YES;
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self;
}

#pragma mark - push / pop

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //    NSInteger count = self.viewControllers.count;
    //    if (count != 0) {
    //        viewController.hidesBottomBarWhenPushed = YES;
    //    }
    
    _popVC = nil;
    _popGestureRecognizerEnable = YES;
    
    viewController.bk_dicTag = @{@"direction":@(_direction),
                              @"popVC":_popVC?_popVC:[NSNull null],
                              @"popGestureRecognizerEnable":@(_popGestureRecognizerEnable)
                              };
    
    _nextVC = viewController;
    _direction = BKImageTransitionAnimaterDirectionRight;
    _customTransition = nil;
    
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

-(void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    if (!delegate) {
        self.delegate = self;
        [self resetNavSettingWithVC:[self.viewControllers lastObject]];
    }else{
        [super setDelegate:delegate];
    }
}

-(void)setPopVC:(UIViewController *)popVC
{
    _popVC = popVC;

    _nextVC.bk_dicTag = @{@"direction":_nextVC.bk_dicTag[@"direction"],
                       @"popVC":_popVC?_popVC:[NSNull null],
                       @"popGestureRecognizerEnable":@(_popGestureRecognizerEnable)
                       };

    self.customTransition.backVC = _popVC;
}

-(void)setPopGestureRecognizerEnable:(BOOL)popGestureRecognizerEnable
{
    _popGestureRecognizerEnable = popGestureRecognizerEnable;
    
    self.interactivePopGestureRecognizer.enabled = _popGestureRecognizerEnable;
    
    _nextVC.bk_dicTag = @{@"direction":_nextVC.bk_dicTag[@"direction"],
                       @"popVC":_popVC?_popVC:[NSNull null],
                       @"popGestureRecognizerEnable":@(_popGestureRecognizerEnable)};
    
    self.customTransition.enble = _popGestureRecognizerEnable;
}

#pragma mark - BKImagePercentDrivenInteractiveTransition

-(BKImagePercentDrivenInteractiveTransition*)customTransition
{
    if (!_customTransition) {

        NSDictionary * vcMessageDic = _nextVC.bk_dicTag;

        switch ([vcMessageDic[@"direction"] integerValue]) {
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
    }

    return _customTransition;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    NSDictionary * vcMessageDic = _nextVC.bk_dicTag;

    if (operation == UINavigationControllerOperationPush) {

        BKImageTransitionAnimater * transitionAnimater = [[BKImageTransitionAnimater alloc] initWithTransitionType:BKImageTransitionAnimaterTypePush transitionAnimaterDirection:[vcMessageDic[@"direction"] integerValue]];

        return transitionAnimater;
    }else{

        BKImageTransitionAnimater * transitionAnimater = [[BKImageTransitionAnimater alloc] initWithTransitionType:BKImageTransitionAnimaterTypePop transitionAnimaterDirection:[vcMessageDic[@"direction"] integerValue]];
        transitionAnimater.interation = self.customTransition.interation;
        BK_WEAK_SELF(self);
        [transitionAnimater setBackFinishAction:^{
            BK_STRONG_SELF(self);
            [strongSelf resetNavSettingWithVC:toVC];
        }];

        return transitionAnimater;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.customTransition.interation?self.customTransition:nil;
}

#pragma mark - 重置上一个VC导航设置

-(void)resetNavSettingWithVC:(UIViewController*)currentVC
{
    NSDictionary * vcMessageDic = currentVC.bk_dicTag;
    self.popVC = [vcMessageDic[@"popVC"] isKindOfClass:[NSNull class]]?nil:vcMessageDic[@"popVC"];
    self.direction = [vcMessageDic[@"direction"] integerValue];
    self.nextVC = currentVC;
    self.popGestureRecognizerEnable = [vcMessageDic[@"popGestureRecognizerEnable"] boolValue];
    
    //重置上一个VC导航交互设置
    self.customTransition = nil;
    [self customTransition];
    UIViewController * popVC = [vcMessageDic[@"popVC"] isKindOfClass:[NSNull class]]?nil:vcMessageDic[@"popVC"];
    if (popVC) {
        self.customTransition.backVC = popVC;
    }
    self.customTransition.enble = [vcMessageDic[@"popGestureRecognizerEnable"] boolValue];
}

#pragma mark - UIGestureRecognizerDelegate 在根视图时不响应interactivePopGestureRecognizer手势

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return [self.viewControllers count] != 1 && ![[self valueForKey:@"isTransitioning"] boolValue];
}

//#pragma iPhoneX黑条隐藏
//
//-(BOOL)prefersHomeIndicatorAutoHidden
//{
//    return YES;
//}

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
