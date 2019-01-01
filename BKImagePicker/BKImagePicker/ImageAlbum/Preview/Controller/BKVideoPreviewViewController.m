//
//  BKVideoPreviewViewController.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/6.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKVideoPreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+BKImagePicker.h"
#import "BKImagePickerMacro.h"
#import "BKImagePickerConstant.h"
#import "UIView+BKImagePicker.h"
#import "BKImagePicker.h"

@interface BKVideoPreviewViewController ()

@property (nonatomic,assign) BOOL isInCloud;//是否在云盘里 需要下载
@property (nonatomic,assign) PHImageRequestID currentImageRequestID;//当前下载的ID
@property (nonatomic,assign) double downloadProgress;//下载进度
@property (nonatomic,assign) BOOL isDownloadError;//是否下载失败
@property (nonatomic,assign) BOOL isLeaveFlag;//是否离开该界面

@property (nonatomic,strong) UIImageView * coverImageView;//封面
@property (nonatomic,strong) UIProgressView * progress;//播放进度条(没加载显示)
@property (nonatomic,assign) id timeObserver;

@property (nonatomic,strong) UIView * playerView;
@property (nonatomic,strong) AVPlayer * player;
@property (nonatomic,strong) AVPlayerLayer * playerLayer;

@property (nonatomic,strong) UIButton * start_pause;

@end

@implementation BKVideoPreviewViewController

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = BKVideoPreviewBackgroundColor;
    [self.topNavView removeFromSuperview];
    
    [self initBottomNav];
    
    [self.view insertSubview:self.playerView atIndex:0];
    [self.view insertSubview:self.coverImageView aboveSubview:self.playerView];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (_playerView) {
        _playerView.frame = self.view.bounds;
        if (_playerLayer) {
            _playerLayer.frame = _playerView.bounds;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_timeObserver) {
        [_player removeTimeObserver:_timeObserver];
    }
    
    self.isLeaveFlag = YES;
    [[PHImageManager defaultManager] cancelImageRequest:self.currentImageRequestID];
}

#pragma mark - NSNotification

-(void)playbackFinished:(NSNotification *)notification
{
    UIImage * start_image = [UIImage bk_imageWithImageName:@"video_start"];
    [_start_pause setImage:start_image forState:UIControlStateNormal];
    
    [self.player seekToTime:CMTimeMake(0, 1)];
}

#pragma mark - initBottomNav

-(void)initBottomNav
{
    self.bottomLine.hidden = YES;
    self.bottomNavViewHeight = BKImagePicker_is_iPhoneX_series() ? BKImagePicker_get_system_tabbar_height() : 64;
    
    self.bottomNavView.backgroundColor = BKVideoPreviewBottomNavBackgroundColor;
    
    UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(10, 0, 64, 64);
    [back setBackgroundColor:BKClearColor];
    [back setTitle:@"取消" forState:UIControlStateNormal];
    [back setTitleColor:BKVideoPreviewBottomNavTitleColor forState:UIControlStateNormal];
    back.titleLabel.font = [UIFont systemFontOfSize:16];
    [back addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomNavView addSubview:back];
    
    [self.bottomNavView addSubview:[self start_pause]];
    
    UIButton * select = [UIButton buttonWithType:UIButtonTypeCustom];
    select.frame = CGRectMake(self.bottomNavView.bk_width - 64 - 10, 0, 64, 64);
    [select setBackgroundColor:BKClearColor];
    [select setTitle:@"选取" forState:UIControlStateNormal];
    [select setTitleColor:BKVideoPreviewBottomNavTitleColor forState:UIControlStateNormal];
    select.titleLabel.font = [UIFont systemFontOfSize:16];
    [select addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomNavView addSubview:select];
}

-(UIButton*)start_pause
{
    if (!_start_pause) {
        UIImage * start_image = [UIImage bk_imageWithImageName:@"video_start"];
        
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
    if (self.isDownloadError && self.downloadProgress == 0) {
        [self loadVideoDataComplete:^{
            [self selectBtnClick];
        }];
        return;
    }
    
    if (self.downloadProgress != 1) {
        [self.view bk_showRemind:BKSelectVideoDownloadingRemind];
        return;
    }
    
    self.tapVideoModel.url = ((AVURLAsset*)self.player.currentItem.asset).URL;
    [[BKImagePicker sharedManager].imageManageModel.selectImageArray addObject:self.tapVideoModel];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)start_pauseBtnClick:(UIButton*)button
{
    if (self.isDownloadError && self.downloadProgress == 0) {
        [self loadVideoDataComplete:^{
            [self start_pauseBtnClick:self.start_pause];
        }];
        return;
    }
    
    if (self.downloadProgress != 1) {
        [self.view bk_showRemind:BKSelectVideoDownloadingRemind];
        return;
    }
    
    [_coverImageView removeFromSuperview];
    _coverImageView = nil;
    
    if (self.player.rate == 0) {
        UIImage * pause_image = [UIImage bk_imageWithImageName:@"video_pause"];
        [_start_pause setImage:pause_image forState:UIControlStateNormal];
        
        [self.player play];
    }else {
        UIImage * start_image = [UIImage bk_imageWithImageName:@"video_start"];
        [_start_pause setImage:start_image forState:UIControlStateNormal];
        
        [self.player pause];
    }
}

#pragma mark - playerView

-(UIView*)playerView
{
    if (!_playerView) {
        _playerView = [[UIView alloc]initWithFrame:self.view.bounds];
        _playerView.backgroundColor = BKVideoPreviewBackgroundColor;
        
        [self loadVideoDataComplete:nil];
    }
    return _playerView;
}

-(void)loadVideoDataComplete:(void (^)(void))complete
{
    [[BKImagePicker sharedManager] getVideoDataWithAsset:self.tapVideoModel.asset progressHandler:^(double progress, NSError *error, PHImageRequestID imageRequestID) {
        
        self.isInCloud = YES;
        
        self.currentImageRequestID = imageRequestID;
        
        if (error) {
            [self.view bk_hideLoadLayer];
            if (!self.isLeaveFlag) {
                self.isDownloadError = YES;
            }
            return;
        }
        
        [self.view bk_showLoadLayerWithDownLoadProgress:progress];
        
        self.downloadProgress = progress;
        
    } complete:^(AVPlayerItem *playerItem, PHImageRequestID imageRequestID) {
        
        [self.view bk_hideLoadLayer];
        
        if (playerItem) {
            
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            [self.playerView.layer addSublayer:self.playerLayer];
            
            [self addProgressObserver];
            
            self.downloadProgress = 1;
            self.isDownloadError = NO;
            
            if (self.isLeaveFlag) {
                return;
            }
            
            if (complete) {
                complete();
            }
            
        }else{
            self.isDownloadError = YES;
            if (!self.isLeaveFlag) {
                [self.view bk_showRemind:BKVideoDownloadFailedRemind];
            }
        }
    }];
}

//进度监控
-(void)addProgressObserver
{
    AVPlayerItem *playerItem = _player.currentItem;
    UIProgressView *progress = _progress;
    self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (progress) {
            float current = CMTimeGetSeconds(time);
            float total = CMTimeGetSeconds([playerItem duration]);
            if (current) {
                [progress setProgress:(current/total) animated:YES];
            }
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

#pragma mark - coverImageView

-(UIImageView*)coverImageView
{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _coverImageView.clipsToBounds = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        if (self.tapVideoModel.loadingProgress == 1) {
            self.coverImageView.image = [UIImage imageWithData:self.tapVideoModel.originalImageData];
        }else if (self.tapVideoModel.thumbImage) {
            self.coverImageView.image = self.tapVideoModel.thumbImage;
            
            [self getOriginalImageDataComplete:nil];
        }else{
            [[BKImagePicker sharedManager] getThumbImageWithAsset:self.tapVideoModel.asset complete:^(UIImage *thumbImage) {
                self.tapVideoModel.thumbImage = thumbImage;
                self.coverImageView.image = thumbImage;
            }];
            
            [self getOriginalImageDataComplete:nil];
        }
    }
    return _coverImageView;
}

-(void)getOriginalImageDataComplete:(void (^)(void))complete
{
    [[BKImagePicker sharedManager] getOriginalImageDataWithAsset:self.tapVideoModel.asset progressHandler:^(double progress, NSError *error, PHImageRequestID imageRequestID) {
        
        self.tapVideoModel.loadingProgress = progress;
        
    } complete:^(NSData *originalImageData, NSURL *url, PHImageRequestID imageRequestID) {
        
        UIImage * originalImage = [UIImage imageWithData:originalImageData];
        
        if (originalImage) {
            self.tapVideoModel.originalImageData = originalImageData;
            self.tapVideoModel.loadingProgress = 1;
            
            self.coverImageView.image = originalImage;
        }else{
            self.tapVideoModel.loadingProgress = 0;
            [self.view bk_showRemind:BKVideoCoverDownloadFailedRemind];
        }
    }];
}

@end
