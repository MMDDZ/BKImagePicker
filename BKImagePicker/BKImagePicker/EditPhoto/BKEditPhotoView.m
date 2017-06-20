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
#import "BKDrawLineView.h"
#import "BKSelectColorView.h"

@interface BKEditPhotoView()<BKSelectColorViewDelegate>

@property (nonatomic,strong) UIImage * editImage;
@property (nonatomic,strong) UIImageView * editImageView;

@property (nonatomic,assign) BOOL isDrawLine;
@property (nonatomic,assign) NSInteger afterDrawTime;
@property (nonatomic,strong) NSTimer * drawTimer;

@property (nonatomic,strong) BKEditGradientView * topView;
@property (nonatomic,strong) BKEditGradientView * bottomView;

@property (nonatomic,strong) UIButton * selectEditBtn;

@property (nonatomic,strong) BKDrawLineView * drawLineView;
@property (nonatomic,strong) BKSelectColorView * selectColorView;

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
        
        [self addSubview:self.selectColorView];
        
        [self addObserver:self forKeyPath:@"isDrawLine" options:NSKeyValueObservingOptionNew context:nil];
        _drawTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(drawThingsTimer) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isDrawLine"]) {
        if ([change[@"new"] boolValue]) {
            
            [UIView animateWithDuration:0.25 animations:^{
                _topView.alpha = 0;
                _bottomView.alpha = 0;
                _selectColorView.alpha = 0;
            }];
        }else{
            [UIView animateWithDuration:0.25 animations:^{
                _topView.alpha = 1;
                _bottomView.alpha = 1;
                _selectColorView.alpha = 1;
            }];
        }
    }
}

-(void)cancelThings
{
    [self removeObserver:self forKeyPath:@"isDrawLine"];
    [_drawTimer invalidate];
    _drawTimer = nil;
}

-(UIImageView*)editImageView
{
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc]initWithFrame:[self calculataImageRect]];
        _editImageView.image = self.editImage;
    }
    return _editImageView;
}

#pragma mark - 算imageView 的 rect

-(CGRect)calculataImageRect
{
    CGRect imageRect = CGRectZero;
    
    CGFloat scale = self.editImage.size.width / self.bk_width;
    CGFloat height = self.editImage.size.height / scale;
    
    if (height > self.bk_height) {
        imageRect.size.height = self.bk_height;
        scale = self.editImage.size.height / self.bk_height;
        imageRect.size.width = self.editImage.size.width / scale;
        imageRect.origin.x = (self.bk_width - imageRect.size.width) / 2.0f;
        imageRect.origin.y = 0;
    }else{
        imageRect.size.height = height;
        imageRect.size.width = self.bk_width;
        imageRect.origin.x = 0;
        imageRect.origin.y = (self.bk_height - imageRect.size.height) / 2.0f;
    }
    
    return imageRect;
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
    
    [self cancelThings];
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
    if (self.selectEditBtn == button) {
        return;
    }
    
    self.selectEditBtn.selected = NO;
    self.selectEditBtn = button;
    self.selectEditBtn.selected = YES;
    
    switch (button.tag) {
        case 0:
        {
            [self drawLineView];
        }
            break;
            
        default:
            break;
    }
}

-(void)sendBtnClick
{
    
}

#pragma mark - 画线

-(BKDrawLineView*)drawLineView
{
    if (!_drawLineView) {
        _drawLineView = [[BKDrawLineView alloc]initWithFrame:self.editImageView.frame];
        __weak typeof(self) weakSelf = self;
        [_drawLineView setMovedOption:^{
            weakSelf.isDrawLine = YES;
            weakSelf.afterDrawTime = 5;
        }];
        [_drawLineView setMoveEndOption:^{
            
            if (weakSelf.isDrawLine) {
                weakSelf.afterDrawTime = 5;
            }else {
                weakSelf.isDrawLine = YES;
            }
            
        }];
        [self insertSubview:_drawLineView aboveSubview:self.editImageView];
    }
    return _drawLineView;
}

-(void)drawThingsTimer
{
    self.afterDrawTime = self.afterDrawTime - 1;
    if (self.afterDrawTime == 0) {
        self.isDrawLine = NO;
    }
}

-(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image1.size);
    
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

#pragma mark - 选颜色

-(BKSelectColorView*)selectColorView
{
    if (!_selectColorView) {
        _selectColorView = [[BKSelectColorView alloc]initWithStartPosition:CGPointMake(UISCREEN_WIDTH - 40,  UISCREEN_HEIGHT - 64 - 200) delegate:self];
    }
    return _selectColorView;
}

#pragma mark - BKSelectColorViewDelegate

-(void)selectColor:(UIColor*)color orSelectType:(BKSelectType)selectType
{
    if (selectType == BKSelectTypeColor) {
        _drawLineView.selectColor = color;
        _drawLineView.selectType = selectType;
    }
}

@end
