//
//  BKImagePickerBaseViewController.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/16.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImagePickerBaseViewController.h"
#import "BKImagePickerMacro.h"
#import "UIImage+BKImagePicker.h"
#import "UIView+BKImagePicker.h"

const CGFloat kImagePickerTopNavLeftRightOffset = 6;

@interface BKImagePickerBaseViewController ()

@property (nonatomic,assign) CGFloat leftNavSpace;
@property (nonatomic,assign) CGFloat rightNavSpace;

@end

@implementation BKImagePickerBaseViewController

#pragma mark -  viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = BKWhiteColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initSubViewUI];
}

#pragma mark - 创建UI

-(void)initSubViewUI
{
    self.topNavViewHeight = BKImagePicker_get_system_nav_height();
    self.bottomNavViewHeight = 0;
    
    [self.view addSubview:self.topNavView];
    [self.topNavView addSubview:self.titleLab];
    [self.topNavView addSubview:self.topLine];
    
    [self.view addSubview:self.bottomNavView];
    [self.bottomNavView addSubview:self.bottomLine];
    
    if ([self.navigationController.viewControllers count] > 1 && self != [self.navigationController.viewControllers firstObject]) {
        [self addLeftBackNavBtn];
    }
}

#pragma mark - 顶部导航

-(UIView*)topNavView
{
    if (!_topNavView) {
        _topNavView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bk_width, self.topNavViewHeight)];
        _topNavView.backgroundColor = BKNavBackgroundColor;
    }
    return _topNavView;
}

-(UILabel*)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, BKImagePicker_get_system_statusBar_height(), self.topNavView.bk_height, BKImagePicker_get_system_nav_ui_height())];
        _titleLab.textColor = BKNavTitleColor;
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.text = self.title;
    }
    return _titleLab;
}

-(UIImageView*)topLine
{
    if (!_topLine) {
        _topLine = [[UIImageView alloc] init];
        _topLine.backgroundColor = BKLineColor;
    }
    return _topLine;
}

-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    _titleLab.text = title;
}

-(void)setTopNavViewHeight:(CGFloat)topNavViewHeight
{
    _topNavViewHeight = topNavViewHeight;
    if ([[self.view subviews] containsObject:self.topNavView]) {
        self.topNavView.bk_height = _topNavViewHeight;
    }
}

#pragma mark - 返回按钮

-(void)setLeftNavBtns:(NSArray<BKImagePickerNavButton *> *)leftNavBtns
{
    [_leftNavBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _leftNavBtns = leftNavBtns;
    
    BKImagePickerNavButton * lastBtn;
    for (BKImagePickerNavButton * currentBtn in _leftNavBtns) {
        [self.topNavView addSubview:currentBtn];
        currentBtn.bk_x = lastBtn ? CGRectGetMaxX(lastBtn.frame) : kImagePickerTopNavLeftRightOffset;
        lastBtn = currentBtn;
    }
    
    self.leftNavSpace = CGRectGetMaxX(lastBtn.frame);
    [self remakeTitleConstraints];
}

-(void)setRightNavBtns:(NSArray<BKImagePickerNavButton *> *)rightNavBtns
{
    [_rightNavBtns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _rightNavBtns = rightNavBtns;
    
    BKImagePickerNavButton * lastBtn;
    for (BKImagePickerNavButton * currentBtn in _rightNavBtns) {
        [self.topNavView addSubview:currentBtn];
        currentBtn.bk_x = lastBtn ? (lastBtn.bk_x - currentBtn.bk_width) : (self.topNavView.bk_width - kImagePickerTopNavLeftRightOffset - currentBtn.bk_width);
        lastBtn = currentBtn;
    }
    
    self.rightNavSpace = lastBtn.bk_x;
    [self remakeTitleConstraints];
}

-(void)remakeTitleConstraints
{
    CGFloat offset = 0;
    if (self.rightNavSpace < self.leftNavSpace) {
        offset = self.leftNavSpace;
    }else{
        offset = self.rightNavSpace;
    }
    self.titleLab.bk_x = offset;
    self.titleLab.bk_width = self.bottomNavView.bk_width - offset*2;
}

#pragma mark - 导航左右按钮

-(void)addLeftBackNavBtn
{
    BKImagePickerNavButton * backBtn = [[BKImagePickerNavButton alloc] initWithImage:[UIImage imageNamed:@"blue_back"]];
    [backBtn addTarget:self action:@selector(leftNavBtnAction)];
    self.leftNavBtns = @[backBtn];
}

-(void)leftNavBtnAction
{
    if ([self.navigationController.viewControllers count] != 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 底部导航

-(UIView*)bottomNavView
{
    if (!_bottomNavView) {
        _bottomNavView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bk_width, self.view.bk_height - self.bottomNavViewHeight)];
        _bottomNavView.backgroundColor = BKNavBackgroundColor;
    }
    return _bottomNavView;
}

-(UIImageView*)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bottomNavView.bk_width, BK_ONE_PIXEL)];
        _bottomLine.backgroundColor = BKLineColor;
    }
    return _bottomLine;
}

-(void)setBottomNavViewHeight:(CGFloat)bottomNavViewHeight
{
    _bottomNavViewHeight = bottomNavViewHeight;
    if ([[self.view subviews] containsObject:self.bottomNavView]) {
        self.bottomNavView.bk_y = self.view.bk_height - _bottomNavViewHeight;
        self.bottomNavView.bk_height = _bottomNavViewHeight;
    }
}

#pragma mark - 状态栏

-(void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
    _statusBarStyle = statusBarStyle;
    
    [UIApplication sharedApplication].statusBarStyle = _statusBarStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)setStatusBarHidden:(BOOL)statusBarHidden
{
    _statusBarHidden = statusBarHidden;
    
    [UIApplication sharedApplication].statusBarHidden = _statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation
{
    _statusBarHidden = hidden;
    _statusBarUpdateAnimation = animation;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden withAnimation:_statusBarUpdateAnimation];
#pragma clang diagnostic pop
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)setStatusBarUpdateAnimation:(UIStatusBarAnimation)statusBarUpdateAnimation
{
    _statusBarUpdateAnimation = statusBarUpdateAnimation;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return self.statusBarStyle;
}

-(BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return self.statusBarUpdateAnimation;
}

//#pragma iPhoneX黑条隐藏
//
//-(BOOL)prefersHomeIndicatorAutoHidden
//{
//    return YES;
//}

#pragma mark - 屏幕旋转处理

// 只支持竖屏
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
