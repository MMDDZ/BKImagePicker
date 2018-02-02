//
//  BKShowExampleVideoView.m
//  BKImagePicker
//
//  Created by iMac on 16/11/1.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKShowExampleVideoView.h"
#import <AVFoundation/AVFoundation.h>

@interface BKShowExampleVideoView ()

@property (nonatomic ,strong) AVPlayer * player;
@property (nonatomic ,strong) AVPlayerLayer * playerLayer;

@property (nonatomic ,strong) UIView * bottomView;
@property (nonatomic ,strong) UIButton * start_pause;

@property (nonatomic ,strong) BKImageModel * model;

@property (nonatomic,weak) UIViewController * locationVC;

@end

@implementation BKShowExampleVideoView

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)playbackFinished:(NSNotification *)notification
{
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
    UIImage * start_image = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/video_start.png"]];
    [_start_pause setImage:start_image forState:UIControlStateNormal];
    
    [self.player seekToTime:CMTimeMake(0, 1)];
}

-(instancetype)initWithModel:(BKImageModel*)model
{
    self = [super initWithFrame:CGRectMake(BK_SCREENW, 0, BK_SCREENW, BK_SCREENH)];
    if (self) {
        
        self.model = model;
        
        self.backgroundColor = [UIColor blackColor];
        
        [self initPrepareVideo];
        [self getOriginalImageDataSizeWithAsset:self.model.asset];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }
    return self;
}

-(void)showInVC:(UIViewController *)locationVC
{
    self.locationVC = locationVC;
    [[self.locationVC.view superview] addSubview:self];
}

#pragma mark - 原图属性

/**
 获取对应原图data
 
 @param asset 相簿
 */
-(void)getOriginalImageDataSizeWithAsset:(PHAsset*)asset
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        self.model.originalImageData = imageData;
    }];
}

#pragma mark - initVideo

-(void)initPrepareVideo
{
    [self requestPlayerItemHandler:^(AVPlayerItem *playerItem) {
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.layer addSublayer:[self playerLayer]];
            [self addSubview:[self bottomView]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animateShow];
            });
        });
    }];
}

-(void)animateShow
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:BKCheckExampleGifAndVideoAnimateTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.locationVC.view.bk_x = -BK_SCREENW/2.0f;
        self.bk_x = 0;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)requestPlayerItemHandler:(void (^)(AVPlayerItem * playerItem))handler
{
    PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc]init];
    
    [[PHImageManager defaultManager] requestPlayerItemForVideo:self.model.asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (handler) {
            handler(playerItem);
        }
    }];
}

-(AVPlayerLayer*)playerLayer
{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = self.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _playerLayer;
}

#pragma mark - bottomView

-(UIView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bk_height - 64, self.bk_width, 64)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        
        UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.frame = CGRectMake(10, 0, 64, 64);
        [back setBackgroundColor:[UIColor clearColor]];
        [back setTitle:@"取消" forState:UIControlStateNormal];
        [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        back.titleLabel.font = [UIFont systemFontOfSize:16];
        [back addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:back];
        
        [_bottomView addSubview:[self start_pause]];
        
        UIButton * select = [UIButton buttonWithType:UIButtonTypeCustom];
        select.frame = CGRectMake(self.bk_width - 64 - 10, 0, 64, 64);
        [select setBackgroundColor:[UIColor clearColor]];
        [select setTitle:@"选取" forState:UIControlStateNormal];
        [select setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        select.titleLabel.font = [UIFont systemFontOfSize:16];
        [select addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:select];
    }
    return _bottomView;
}

-(UIButton*)start_pause
{
    if (!_start_pause) {
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        UIImage * start_image = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/video_start.png"]];
        
        _start_pause = [UIButton buttonWithType:UIButtonTypeCustom];
        _start_pause.frame = CGRectMake((self.bk_width - 64)/2.0f, 0, 64, 64);
        [_start_pause setImage:start_image forState:UIControlStateNormal];
        [_start_pause setImageEdgeInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
        _start_pause.clipsToBounds = YES;
        _start_pause.adjustsImageWhenHighlighted = NO;
        [_start_pause addTarget:self action:@selector(start_pauseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _start_pause;
}

-(void)backBtnClick
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.locationVC.view.bk_x = - BK_SCREENW/2.0f;
    
    [UIView animateWithDuration:BKCheckExampleGifAndVideoAnimateTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.locationVC.view.bk_x = 0;
        self.bk_x = BK_SCREENW;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

-(void)selectBtnClick
{
    self.model.url = ((AVURLAsset*)self.player.currentItem.asset).URL;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:@{@"object":self.model}];
    [self.locationVC dismissViewControllerAnimated:YES completion:nil];
}

-(void)start_pauseBtnClick:(UIButton*)button
{
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
    
    if (self.player.rate == 0) {
        UIImage * pause_image = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/video_pause.png"]];
        [button setImage:pause_image forState:UIControlStateNormal];
        
        [self.player play];
    }else {
        UIImage * start_image = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/video_start.png"]];
        [button setImage:start_image forState:UIControlStateNormal];
        
        [self.player pause];
    }
}

@end
