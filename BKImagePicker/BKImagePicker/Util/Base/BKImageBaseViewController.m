//
//  BKImageBaseViewController.m
//  zhaolin
//
//  Created by zhaolin on 2018/2/1.
//  Copyright © 2018年 zhaolin. All rights reserved.
//

#import "BKImageBaseViewController.h"

@interface BKImageBaseViewController ()

@end

@implementation BKImageBaseViewController

#pragma mark -  viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.topNavView];
    [self.view addSubview:self.bottomNavView];
    [self addTopNavConstraint];
    [self addBottomNavConstraint];
}

#pragma mark - 顶部导航

-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    _titleLab.text = title;
}

-(UIView*)topNavView
{
    if (!_topNavView) {
        _topNavView = [[UIView alloc]init];
        _topNavView.backgroundColor = BKNavBackgroundColor;
        
        _titleLab = [[UILabel alloc]init];
        _titleLab.textColor = [UIColor blackColor];
        _titleLab.font = [UIFont boldSystemFontOfSize:17];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.text = self.title;
        [_topNavView addSubview:_titleLab];
        
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(0, BK_SYSTEM_STATUSBAR_HEIGHT, 64, BK_SYSTEM_NAV_UI_HEIGHT);
        _leftBtn.backgroundColor = [UIColor clearColor];
        [_leftBtn addTarget:self action:@selector(leftNavBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topNavView addSubview:_leftBtn];
        
        _leftLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _leftBtn.bk_width, _leftBtn.bk_height)];
        _leftLab.font = [UIFont systemFontOfSize:16];
        _leftLab.textColor = BKNavHighlightTitleColor;
        _leftLab.textAlignment = NSTextAlignmentCenter;
        [_leftBtn addSubview:_leftLab];
        
        NSString * backPath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        _leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 20, 20)];
        _leftImageView.bk_centerY = _leftLab.bk_centerY;
        if ([self.navigationController.viewControllers count] != 1) {
            _leftImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/blue_back.png",backPath]];
        }
        _leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        _leftImageView.clipsToBounds = YES;
        [_leftBtn addSubview:_leftImageView];
        
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(BK_SCREENW-64, BK_SYSTEM_STATUSBAR_HEIGHT, 64, BK_SYSTEM_NAV_UI_HEIGHT);
        _rightBtn.backgroundColor = [UIColor clearColor];
        [_rightBtn addTarget:self action:@selector(rightNavBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topNavView addSubview:_rightBtn];
        
        _rightLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, _rightBtn.bk_width, _rightBtn.bk_height)];
        _rightLab.font = [UIFont systemFontOfSize:15];
        _rightLab.textAlignment = NSTextAlignmentCenter;
        _rightLab.textColor = BKNavHighlightTitleColor;
        _rightLab.backgroundColor = [UIColor clearColor];
        [_rightBtn addSubview:_rightLab];
        
        _rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(_rightBtn.bk_width - 20 - 20, 0, 20 , 20)];
        _rightImageView.bk_centerY = _rightLab.bk_centerY;
        _rightImageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightImageView.clipsToBounds = YES;
        [_rightBtn addSubview:_rightImageView];
        
        _topLine = [[UIImageView alloc]init];
        _topLine.backgroundColor = BKLineColor;
        [_topNavView addSubview:_topLine];
    }
    return _topNavView;
}

-(void)addTopNavConstraint
{
    [_topNavView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(0);
        make.top.mas_equalTo(self.view.mas_top).mas_offset(0);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(BK_SCREENW, BK_SYSTEM_NAV_HEIGHT));
    }];
    
    [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_topNavView.mas_left).mas_offset(0);
        make.bottom.mas_equalTo(_topNavView.mas_bottom).mas_offset(0);
        make.size.mas_equalTo(CGSizeMake(64, BK_SYSTEM_NAV_UI_HEIGHT));
    }];

    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_leftBtn.mas_right).mas_offset(0);
        make.bottom.mas_equalTo(_topNavView.mas_bottom).mas_offset(0);
        make.right.mas_equalTo(_rightBtn.mas_left).mas_offset(0);
        make.height.mas_equalTo(BK_SYSTEM_NAV_UI_HEIGHT);
    }];
    
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_topNavView.mas_right).mas_offset(0);
        make.bottom.mas_equalTo(_topNavView.mas_bottom).mas_offset(0);
        make.size.mas_equalTo(CGSizeMake(64, BK_SYSTEM_NAV_UI_HEIGHT));
    }];
    
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_topNavView.mas_left).mas_offset(0);
        make.bottom.mas_equalTo(_topNavView.mas_bottom).mas_offset(0);
        make.size.mas_equalTo(CGSizeMake(BK_SCREENW, BK_ONE_PIXEL));
    }];
}

-(void)leftNavBtnAction:(UIButton*)button
{
    if (self.navigationController) {
        if ([self.navigationController.viewControllers count] != 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)rightNavBtnAction:(UIButton*)button
{
    
}

#pragma mark - 底部导航

-(UIView*)bottomNavView
{
    if (!_bottomNavView) {
        _bottomNavView = [[UIView alloc]init];
        _bottomNavView.backgroundColor = BKNavBackgroundColor;
        
        _bottomLine = [[UIImageView alloc]init];
        _bottomLine.backgroundColor = BKLineColor;
        [_bottomNavView addSubview:_bottomLine];
    }
    return _bottomNavView;
}

-(void)addBottomNavConstraint
{
    [_bottomNavView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).mas_offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(0);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(BK_SCREENW, BK_SYSTEM_TABBAR_HEIGHT));
    }];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_bottomNavView.mas_left).mas_offset(0);
        make.top.mas_equalTo(_bottomNavView.mas_top).mas_offset(0);
        make.size.mas_equalTo(CGSizeMake(BK_SCREENW, BK_ONE_PIXEL));
    }];
}

-(void)setBottomNavViewHeight:(CGFloat)bottomNavViewHeight
{
    _bottomNavViewHeight = bottomNavViewHeight;
    
    [_bottomNavView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_bottomNavViewHeight);
    }];
}

#pragma iPhoneX黑条隐藏

-(BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}

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
