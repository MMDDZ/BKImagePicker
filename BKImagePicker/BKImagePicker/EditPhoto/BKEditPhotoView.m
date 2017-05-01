//
//  BKEditPhotoView.m
//  BKImagePicker
//
//  Created by iMac on 17/1/18.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKEditPhotoView.h"
#import "BKEditGradientView.h"
#import "BKImagePickerConst.h"
#import <Photos/Photos.h>
#import "BKImagePicker.h"

@interface BKEditPhotoView()

@property (nonatomic,strong) UIImage * editImage;
@property (nonatomic,strong) UIImageView * editImageView;

@property (nonatomic,strong) BKEditGradientView * topView;
@property (nonatomic,strong) BKEditGradientView * bottomView;

@property (nonatomic,strong) UIButton * selectEditBtn;

@end

@implementation BKEditPhotoView

-(instancetype)initWithImage:(UIImage*)image
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
        self.editImage = image;
        
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.editImageView];
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
    }
    return self;
}

-(UIImageView*)editImageView
{
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _editImageView.image = self.editImage;
        _editImageView.contentMode = UIViewContentModeScaleAspectFit;
        _editImageView.clipsToBounds = YES;
    }
    return _editImageView;
}

#pragma mark - topView

-(BKEditGradientView*)topView
{
    if (!_topView) {
        _topView = [[BKEditGradientView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, 64) topColor:[UIColor colorWithWhite:0.2 alpha:0.5] bottomColor:[UIColor colorWithWhite:0 alpha:0]];
        
        UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 20, 64, 44);
        [backBtn setTitle:@"取消" forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:backBtn];
        
        UIButton * saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        saveBtn.frame = CGRectMake(_topView.bk_width - 64, 20, 64, 40);
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        [saveBtn setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/save_n.png"]] forState:UIControlStateNormal];
        [saveBtn setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/save_s.png"]] forState:UIControlStateHighlighted];
        [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:saveBtn];
    }
    return _topView;
}

-(void)backBtnClick
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self removeFromSuperview];
}

-(void)saveBtnClick
{
    [BKImagePicker saveImage:self.editImage];
}

#pragma mark - bottomView

-(BKEditGradientView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[BKEditGradientView alloc]initWithFrame:CGRectMake(0, self.bk_height - 64, self.bk_width, 64) topColor:[UIColor colorWithWhite:0 alpha:0] bottomColor:[UIColor colorWithWhite:0.2 alpha:0.5]];
        
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        NSArray * imageArr_n = @[[bundlePath stringByAppendingString:@"/draw_n.png"],[bundlePath stringByAppendingString:@"/rotation_n.png"],[bundlePath stringByAppendingString:@"/write_n.png"],[bundlePath stringByAppendingString:@"/clip_n.png"],[bundlePath stringByAppendingString:@"/filter_n.png"]];
        NSArray * imageArr_s = @[[bundlePath stringByAppendingString:@"/draw_s.png"],[bundlePath stringByAppendingString:@"/rotation_s.png"],[bundlePath stringByAppendingString:@"/write_s.png"],[bundlePath stringByAppendingString:@"/clip_s.png"],[bundlePath stringByAppendingString:@"/filter_s.png"]];
        
        [imageArr_n enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, 64);
            [button setImage:[UIImage imageWithContentsOfFile:obj] forState:UIControlStateNormal];
            [button setImage:[UIImage imageWithContentsOfFile:imageArr_s[idx]] forState:UIControlStateHighlighted];
            [button setImage:[UIImage imageWithContentsOfFile:imageArr_s[idx]] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = idx;
            [_bottomView addSubview:button];
            
            if (idx == 0) {
                [self editBtnClick:button];
            }
        }];
        
        UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(self.bk_width/4*3, (_bottomView.bk_height - 37)/2, self.bk_width/4-6, 37);
        [sendBtn setTitle:@"确认" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn setBackgroundColor:BKNavHighlightTitleColor];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        sendBtn.layer.cornerRadius = 4;
        sendBtn.clipsToBounds = YES;
        [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:sendBtn];
    }
    return _bottomView;
}

-(void)editBtnClick:(UIButton*)button
{
    self.selectEditBtn.selected = NO;
    self.selectEditBtn = button;
    self.selectEditBtn.selected = YES;
}

-(void)sendBtnClick
{
    
}



@end
