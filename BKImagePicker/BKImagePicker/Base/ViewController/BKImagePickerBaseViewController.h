//
//  BKImagePickerBaseViewController.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/16.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKImagePickerNavButton.h"
#import "BKNavigationController.h"

@interface BKImagePickerBaseViewController : UIViewController

#pragma mark - 顶部导航

@property (nonatomic,strong) UIView * topNavView;
@property (nonatomic,strong) UILabel * titleLab;
@property (nonatomic,strong) NSArray<BKImagePickerNavButton*> * leftNavBtns;
@property (nonatomic,strong) NSArray<BKImagePickerNavButton*> * rightNavBtns;
@property (nonatomic,strong) UIImageView * topLine;
@property (nonatomic,assign) CGFloat topNavViewHeight;

/**
 添加左边返回按钮(特殊情况时使用)
 */
-(void)addLeftBackNavBtn;

#pragma mark - 底部导航

@property (nonatomic,strong) UIView * bottomNavView;
@property (nonatomic,strong) UIImageView * bottomLine;
@property (nonatomic,assign) CGFloat bottomNavViewHeight;

#pragma mark - 状态栏

@property (nonatomic,assign) UIStatusBarStyle statusBarStyle;//状态栏样式
@property (nonatomic,assign) BOOL statusBarHidden;//状态栏是否隐藏
@property (nonatomic,assign) UIStatusBarAnimation statusBarUpdateAnimation;//状态栏更新动画

/**
 状态栏是否隐藏(带动画)
 
 @param hidden 是否隐藏
 @param animation 动画类型
 */
-(void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation;

@end
