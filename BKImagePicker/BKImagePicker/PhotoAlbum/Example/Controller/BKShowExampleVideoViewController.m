//
//  BKShowExampleVideoViewController.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/6.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKShowExampleVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BKTool.h"

@interface BKShowExampleVideoViewController ()

@property (nonatomic,strong) UIImageView * coverImageView;//封面
@property (nonatomic,strong) UIProgressView * progress;//进度条(没加载显示)

@property (nonatomic,strong) AVPlayer * player;
@property (nonatomic,strong) UIView * playerView;
@property (nonatomic,strong) AVPlayerLayer * playerLayer;

@property (nonatomic,assign) id timeObserver;

@property (nonatomic,strong) UIButton * start_pause;

@end

@implementation BKShowExampleVideoViewController

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    self.topNavView.hidden = YES;
    
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_timeObserver) {
        [_player removeTimeObserver:_timeObserver];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - NSNotification

-(void)playbackFinished:(NSNotification *)notification
{
    UIImage * start_image = [[BKTool sharedManager] imageWithImageName:@"video_start"];
    [_start_pause setImage:start_image forState:UIControlStateNormal];
    
    [self.player seekToTime:CMTimeMake(0, 1)];
}

#pragma mark - initBottomNav

-(void)initBottomNav
{
    self.bottomLine.hidden = YES;
    self.bottomNavViewHeight = BK_IPONEX ? BK_SYSTEM_TABBAR_HEIGHT : 64;
    
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
        UIImage * start_image = [[BKTool sharedManager] imageWithImageName:@"video_start"];
        
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
    [[BKTool sharedManager].selectImageArray addObject:self.tapVideoModel];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)start_pauseBtnClick:(UIButton*)button
{
    [_coverImageView removeFromSuperview];
    _coverImageView = nil;
    
    if (self.player.rate == 0) {
        UIImage * pause_image = [[BKTool sharedManager] imageWithImageName:@"video_pause"];
        [_start_pause setImage:pause_image forState:UIControlStateNormal];
        
        [self.player play];
    }else {
        UIImage * start_image = [[BKTool sharedManager] imageWithImageName:@"video_start"];
        [_start_pause setImage:start_image forState:UIControlStateNormal];
        
        [self.player pause];
    }
}

#pragma mark - playerView

-(UIView*)playerView
{
    if (!_playerView) {
        _playerView = [[UIView alloc]initWithFrame:self.view.bounds];
        _playerView.backgroundColor = [UIColor blackColor];
        
        [self loadVideoDataComplete:nil];
    }
    return _playerView;
}

-(void)loadVideoDataComplete:(void (^)(void))complete
{
    [[BKTool sharedManager] getVideoDataWithAsset:self.tapVideoModel.asset complete:^(AVPlayerItem *playerItem) {
        
        if (playerItem) {
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            [self.playerView.layer addSublayer:self.playerLayer];
            
            [self addProgressObserver];
        }else{
            [[BKTool sharedManager] showRemind:@"视频加载失败"];
        }
        
        if (complete) {
            complete();
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
        
        if (self.tapVideoModel.isHaveOriginalImageFlag) {
            self.coverImageView.image = [UIImage imageWithData:self.tapVideoModel.originalImageData];
        }else if (self.tapVideoModel.thumbImage) {
            self.coverImageView.image = self.tapVideoModel.thumbImage;
            
            [[BKTool sharedManager] getOriginalImageDataWithAsset:self.tapVideoModel.asset complete:^(NSData *originalImageData, NSURL *url) {
                self.tapVideoModel.originalImageData = originalImageData;
                self.tapVideoModel.isHaveOriginalImageFlag = YES;
                
                self.coverImageView.image = [UIImage imageWithData:originalImageData];
            }];
        }else{
            [[BKTool sharedManager] getThumbImageWithAsset:self.tapVideoModel.asset complete:^(UIImage *thumbImage) {
                self.tapVideoModel.thumbImage = thumbImage;
                self.coverImageView.image = thumbImage;
            }];
            
            [[BKTool sharedManager] getOriginalImageDataWithAsset:self.tapVideoModel.asset complete:^(NSData *originalImageData, NSURL *url) {
                self.tapVideoModel.originalImageData = originalImageData;
                self.tapVideoModel.isHaveOriginalImageFlag = YES;
                
                self.coverImageView.image = [UIImage imageWithData:originalImageData];
            }];
        }
    }
    return _coverImageView;
}

@end
