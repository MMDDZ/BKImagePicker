//
//  BKEditImageViewController.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageViewController.h"
#import "BKImagePickerConst.h"
#import "BKImagePicker.h"
#import "BKDrawView.h"
#import "BKSelectColorView.h"
#import "BKDrawModel.h"
#import "BKImageCropView.h"
#import "BKEditImageBottomView.h"

@interface BKEditImageViewController ()<BKSelectColorViewDelegate,BKDrawViewDelegate>

@property (nonatomic,copy) NSString * imagePath;//图片路径

/**
 要修改的图片
 */
@property (nonatomic,strong) UIImageView * editImageView;
/**
 全图马赛克处理
 */
@property (nonatomic,strong) UIImage * mosaicImage;
@property (nonatomic,strong) CAShapeLayer * mosaicImageShapeLayer;

/**
 画图(包括线、圆角矩形、圆、箭头)
 */
@property (nonatomic,strong) BKDrawView * drawView;

/**
 是否正在绘画中
 */
@property (nonatomic,assign) BOOL isDrawingFlag;
/**
 停止绘画后倒计时时间（5s）
 */
@property (nonatomic,assign) NSInteger afterDrawTime;
/**
 倒计时定时器
 */
@property (nonatomic,strong) NSTimer * drawTimer;


@property (nonatomic,strong) BKEditImageBottomView * bottomView;



/**
 颜色选取
 */
@property (nonatomic,strong) BKSelectColorView * selectColorView;

@end

@implementation BKEditImageViewController

#pragma mark - 图片路径

-(NSString*)imagePath
{
    if (!_imagePath) {
        NSString * imageBundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        _imagePath = [NSString stringWithFormat:@"%@",imageBundlePath];
    }
    return _imagePath;
}

-(UIImage*)imageWithImageName:(NSString*)imageName
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.imagePath,imageName]];
}

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initTopNav];
    [self initBottomNav];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    ((BKImageNavViewController*)self.navigationController).customTransition.enble = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    ((BKImageNavViewController*)self.navigationController).customTransition.enble = YES;
}

#pragma mark - initTopNav

-(void)initTopNav
{
    self.leftImageView.image = nil;
    self.leftLab.text = @"取消";
    
    self.rightImageView.image = [self imageWithImageName:@"save_s"];
}

-(void)leftNavBtnAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)rightNavBtnAction:(UIButton *)button
{
    
}

#pragma mark - initBottomNav

-(void)initBottomNav
{
    self.bottomNavViewHeight = BK_SYSTEM_TABBAR_HEIGHT;
    [self.bottomNavView addSubview:self.bottomView];
}

-(BKEditImageBottomView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[BKEditImageBottomView alloc]init];
        BK_WEAK_SELF(self);
        [_bottomView setSelectTypeAction:^(BKEditImageSelectEditType selectEditType, CGFloat height) {
            BK_STRONG_SELF(self);
            
            strongSelf.bottomNavViewHeight = height + BK_SYSTEM_TABBAR_HEIGHT - BK_SYSTEM_TABBAR_UI_HEIGHT;
            
            
            switch (selectEditType) {
                case BKEditImageSelectEditTypeDrawLine:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }
        }];
    }
    return _bottomView;
}




@end
