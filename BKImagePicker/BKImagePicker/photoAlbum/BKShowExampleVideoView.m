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

@property (nonatomic ,strong) UIView * currentView;

@property (nonatomic ,strong) UIView * bottomView;

@end

@implementation BKShowExampleVideoView

-(UIView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 64, self.frame.size.width, 64)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        
        UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.frame = CGRectMake(10, 0, 64, 64);
        [back setBackgroundColor:[UIColor clearColor]];
        [back setTitle:@"取消" forState:UIControlStateNormal];
        [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        back.titleLabel.font = [UIFont systemFontOfSize:16];
        [back addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:back];
        
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        UIImage * start_image = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/video_start.png"]];
        
        UIButton * start_pause = [UIButton buttonWithType:UIButtonTypeCustom];
        start_pause.frame = CGRectMake((self.frame.size.width - 64)/2.0f, 0, 64, 64);
        [start_pause setImage:start_image forState:UIControlStateNormal];
        [start_pause setImageEdgeInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
        start_pause.clipsToBounds = YES;
        start_pause.adjustsImageWhenHighlighted = NO;
        [start_pause addTarget:self action:@selector(start_pauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:start_pause];
        
        UIButton * select = [UIButton buttonWithType:UIButtonTypeCustom];
        select.frame = CGRectMake(self.frame.size.width - 64 - 10, 0, 64, 64);
        [select setBackgroundColor:[UIColor clearColor]];
        [select setTitle:@"选取" forState:UIControlStateNormal];
        [select setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        select.titleLabel.font = [UIFont systemFontOfSize:16];
        [select addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:select];
    }
    return _bottomView;
}

-(void)backBtnClick
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    CGRect currentRect = self.currentView.frame;
    CGRect selfRect = self.frame;
    currentRect.origin.x = 0;
    selfRect.origin.x = self.frame.size.width;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.currentView.frame = currentRect;
        self.frame = selfRect;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

-(void)selectBtnClick
{
    
}

-(void)start_pauseBtnClick
{
    [self.player play];
}

//-(void)dealloc
//{
//    [self removeObserverFromPlayerItem:self.player.currentItem];
//}
//
//-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem
//{
//    [playerItem removeObserver:self forKeyPath:@"status"];
//    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//}

-(instancetype)initWithAsset:(PHAsset*)asset
{
    self = [super initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        [self initPrepareVideoWithAsset:asset];
    }
    return self;
}

-(void)initPrepareVideoWithAsset:(PHAsset*)asset
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
    } withAsset:asset];
}

-(void)requestPlayerItemHandler:(void (^)(AVPlayerItem * playerItem))handler withAsset:(PHAsset*)asset
{
    PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc]init];
    
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
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

-(void)showInVC:(UIViewController *)vc
{
    self.currentView = vc.navigationController.view;
    [[self.currentView superview] addSubview:self];
}

-(void)animateShow
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    CGRect currentRect = self.currentView.frame;
    CGRect selfRect = self.frame;
    currentRect.origin.x = -self.frame.size.width/2.0f;
    selfRect.origin.x = 0;
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.currentView.frame = currentRect;
        self.frame = selfRect;
        
    } completion:^(BOOL finished) {
        
    }];
}

@end
