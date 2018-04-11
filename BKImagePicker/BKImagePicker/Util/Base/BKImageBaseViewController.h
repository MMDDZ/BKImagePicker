//
//  BKImageBaseViewController.h
//  zhaolin
//
//  Created by zhaolin on 2018/2/1.
//  Copyright © 2018年 zhaolin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKTool.h"

@interface BKImageBaseViewController : UIViewController

#pragma mark - 顶部导航

@property (nonatomic,strong) UIView * topNavView;//默认高度为 BK_SYSTEM_NAV_HEIGHT
@property (nonatomic,strong) UILabel * titleLab;
@property (nonatomic,strong) UIButton * leftBtn;
@property (nonatomic,strong) UILabel * leftLab;
@property (nonatomic,strong) UIImageView * leftImageView;
@property (nonatomic,strong) UIButton * rightBtn;
@property (nonatomic,strong) UILabel * rightLab;
@property (nonatomic,strong) UIImageView * rightImageView;
@property (nonatomic,strong) UIImageView * topLine;

/**
 导航左边按钮事件
 
 @param button 按钮
 */
-(void)leftNavBtnAction:(UIButton*)button;

/**
 导航右边按钮事件
 
 @param button 按钮
 */
-(void)rightNavBtnAction:(UIButton*)button;

#pragma mark - 底部导航

@property (nonatomic,strong) UIView * bottomNavView;//默认高度为 0
@property (nonatomic,strong) UIImageView * bottomLine;
@property (nonatomic,assign) CGFloat bottomNavViewHeight;//bottomNavView的高度 默认高度为 0

@end
