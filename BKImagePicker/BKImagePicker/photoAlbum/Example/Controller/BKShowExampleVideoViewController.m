//
//  BKShowExampleVideoViewController.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/6.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKShowExampleVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BKImagePickerConst.h"

@interface BKShowExampleVideoViewController ()

@property (nonatomic,strong) AVPlayer * player;
@property (nonatomic,strong) UIView * playerView;
@property (nonatomic,strong) AVPlayerLayer * playerLayer;

@property (nonatomic,strong) UIButton * start_pause;

@end

@implementation BKShowExampleVideoViewController

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
        
        self.tapVideoModel.originalImageData = imageData;
    }];
}

#pragma mark - NSNotification

-(void)playbackFinished:(NSNotification *)notification
{
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
    UIImage * start_image = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/video_start.png"]];
    [_start_pause setImage:start_image forState:UIControlStateNormal];
    
    [self.player seekToTime:CMTimeMake(0, 1)];
}

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    self.topNavView.hidden = YES;
    [self initBottomNav];
    
    [self.view insertSubview:self.playerView atIndex:0];
    [self getOriginalImageDataSizeWithAsset:self.tapVideoModel.asset];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.playerView.frame = self.view.bounds;
    self.playerLayer.frame = _playerView.bounds;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - initBottomNav

-(void)initBottomNav
{
    self.bottomLine.hidden = YES;
    self.bottomNavViewHeight = 64;
    
    self.bottomNavView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
    
    UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(10, 0, 64, 64);
    [back setBackgroundColor:[UIColor clearColor]];
    [back setTitle:@"取消" forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    back.titleLabel.font = [UIFont systemFontOfSize:16];
    [back addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomNavView addSubview:back];
    
    [self.bottomNavView addSubview:[self start_pause]];
    
    UIButton * select = [UIButton buttonWithType:UIButtonTypeCustom];
    select.frame = CGRectMake(self.bottomNavView.bk_width - 64 - 10, 0, 64, 64);
    [select setBackgroundColor:[UIColor clearColor]];
    [select setTitle:@"选取" forState:UIControlStateNormal];
    [select setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    select.titleLabel.font = [UIFont systemFontOfSize:16];
    [select addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomNavView addSubview:select];
}

-(UIButton*)start_pause
{
    if (!_start_pause) {
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        UIImage * start_image = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/video_start.png"]];
        
        _start_pause = [UIButton buttonWithType:UIButtonTypeCustom];
        _start_pause.frame = CGRectMake((self.bottomNavView.bk_width - 64)/2.0f, 0, 64, 64);
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
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)selectBtnClick
{
    self.tapVideoModel.url = ((AVURLAsset*)self.player.currentItem.asset).URL;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:@{@"object":self.tapVideoModel}];
    [self.getCurrentVC dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - playerView

-(UIView*)playerView
{
    if (!_playerView) {
        _playerView = [[UIView alloc]initWithFrame:self.view.bounds];
        _playerView.backgroundColor = [UIColor blackColor];
        
        [self requestPlayerItemHandler:^(AVPlayerItem *playerItem) {
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_playerView.layer addSublayer:self.playerLayer];
            });
        }];
    }
    return _playerView;
}

-(void)requestPlayerItemHandler:(void (^)(AVPlayerItem * playerItem))handler
{
    PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc]init];
    
    [[PHImageManager defaultManager] requestPlayerItemForVideo:self.tapVideoModel.asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (handler) {
            handler(playerItem);
        }
    }];
}

#pragma mark - playerLayer

-(AVPlayerLayer*)playerLayer
{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = _playerView.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _playerLayer;
}

@end
