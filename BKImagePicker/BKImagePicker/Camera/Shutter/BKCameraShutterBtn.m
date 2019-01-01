//
//  BKCameraShutterBtn.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/23.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKCameraShutterBtn.h"
#import "BKImagePickerMacro.h"
#import "BKImagePickerConstant.h"
#import "UIView+BKImagePicker.h"
#import "BKTimer.h"

typedef NS_ENUM(NSUInteger, BKShutterState) {
    BKShutterStateCancel = 0,      //没有点中状态
    BKShutterStateLongPress        //长按状态
};

float const kTimerInterval = 0.01;//定时器执行间距

@interface BKCameraShutterBtn()

@property (nonatomic,strong) UILongPressGestureRecognizer * longPress;//长按手势
@property (nonatomic,assign) CGPoint startPoint;//记录开始手势的位置
@property (nonatomic,assign) CGPoint blurView_startCenterPoint;
@property (nonatomic,assign) CGPoint middleCircleView_startCenterPoint;

@property (nonatomic,strong) UIView * blurView;
@property (nonatomic,strong) UIView * middleCircleView;

@property (nonatomic,assign) BKShutterState shutterState;//拍照状态
@property (nonatomic,assign) BKRecordState recordState;//录像状态

@property (nonatomic,assign) CGFloat recordTime;//录制时间
@property (nonatomic,strong) dispatch_source_t recordTimer;//录制视频倒计时定时器

@end

@implementation BKCameraShutterBtn

#pragma mark - 外部调用方法

/**
 录制失败调用 停止动画
 */
-(void)recordingFailure
{
    self.recordState = BKRecordStateRecordingFailure;
    [self removeLongPress];
}

/**
 修改录制时间(当调用删除一段视频方法等等)
 
 @param time 时间
 */
-(void)modifyRecordTime:(CGFloat)time
{
    self.recordTime = time;
}

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.clipsToBounds = NO;
        self.backgroundColor = BKClearColor;
        
        [self addSubview:self.blurView];
        [self addSubview:self.middleCircleView];
    
        [self addGestureRecognizer:self.longPress];
    }
    return self;
}

-(UILongPressGestureRecognizer*)longPress
{
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selfLongPress:)];
        _longPress.minimumPressDuration = 0.01;
    }
    return _longPress;
}

-(UIView*)blurView
{
    if (!_blurView) {
        _blurView = [[UIView alloc]initWithFrame:self.bounds];
        _blurView.clipsToBounds = YES;
        _blurView.layer.cornerRadius = _blurView.bk_height/2;
        _blurView.userInteractionEnabled = NO;
        
        UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView * effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = self.bounds;
        [_blurView addSubview:effectView];
    }
    return _blurView;
}

-(UIView*)middleCircleView
{
    if (!_middleCircleView) {
        _middleCircleView = [[UIView alloc]initWithFrame:CGRectMake(self.bk_width/8, self.bk_height/8, self.bk_width/4*3, self.bk_height/4*3)];
        _middleCircleView.clipsToBounds = YES;
        _middleCircleView.layer.cornerRadius = _middleCircleView.bk_height/2;
        _middleCircleView.backgroundColor = BKCameraBottomShutterColor;
        _middleCircleView.userInteractionEnabled = NO;
    }
    return _middleCircleView;
}

#pragma mark - 长按快门按钮

-(void)selfLongPress:(UILongPressGestureRecognizer*)longPress
{
    if (_cameraType == BKCameraTypeTakePhoto) {
        [self takePictureLongPress:longPress];
    }else if (_cameraType == BKCameraTypeRecordVideo) {
        [self recordVideoLongPress:longPress];
    }
}

#pragma mark - 拍照模式

-(void)takePictureLongPress:(UILongPressGestureRecognizer*)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.shutterState = BKShutterStateLongPress;
            _startPoint = [longPress locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [longPress locationOfTouch:0 inView:self];
            CGFloat tranX = point.x - _startPoint.x;
            CGFloat tranY = point.y - _startPoint.y;
            
            if (fabs(tranX) > self.bk_width || fabs(tranY) > self.bk_height) {
                self.shutterState = BKShutterStateCancel;
            }else{
                self.shutterState = BKShutterStateLongPress;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (_shutterState == BKShutterStateLongPress) {
                [self tapShutterAction];
            }
            
            self.shutterState = BKShutterStateCancel;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            self.shutterState = BKShutterStateCancel;
        }
            break;
        default:
            break;
    }
}

/**
 改变快门按钮的状态
 */
-(void)setShutterState:(BKShutterState)shutterState
{
    _shutterState = shutterState;
    
    [UIView animateWithDuration:0.1 animations:^{
        if (self.shutterState == BKShutterStateCancel) {
            self.blurView.transform = CGAffineTransformIdentity;
            self.middleCircleView.transform = CGAffineTransformIdentity;
        }else if (self.shutterState == BKShutterStateLongPress) {
            self.blurView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            self.middleCircleView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }
    }];
}

-(void)tapShutterAction
{
    if (self.takePictureAction) {
        self.takePictureAction();
    }
}

#pragma mark - 录制模式

-(void)removeLongPress
{
    self.longPress.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.longPress.enabled = YES;
    });
}

-(void)reachMaxRecordTime
{
    [[UIApplication sharedApplication].keyWindow bk_showRemind:BKRecordingTimeIsUpRemind];
    [self removeLongPress];
}

-(void)recordVideoLongPress:(UILongPressGestureRecognizer*)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            UIWindow * window = [UIApplication sharedApplication].keyWindow;
            if (!window.userInteractionEnabled) {
                return;
            }
            window.userInteractionEnabled = NO;
            
            if (self.recordState == BKRecordStatePrepare || self.recordState == BKRecordStatePause) {
                
                self.startPoint = [longPress locationInView:self];
                self.blurView_startCenterPoint = self.blurView.center;
                self.middleCircleView_startCenterPoint = self.middleCircleView.center;
                
                self.recordState = BKRecordStateRecording;
                [self changeRecordAction];
                
            }else if (self.recordState == BKRecordStateEnd) {
                [self reachMaxRecordTime];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (self.recordState == BKRecordStateRecording) {
                CGPoint point = [longPress locationOfTouch:0 inView:self];
                CGFloat tranX = point.x - _startPoint.x;
                CGFloat tranY = point.y - _startPoint.y;
                
                if (self.changeCaptureDeviceFactorPAction) {
                    CGFloat totalHeight = BK_SCREENH - 200;
                    CGFloat addFactorP = -(self.middleCircleView_startCenterPoint.y + tranY - self.middleCircleView.bk_centerY) / totalHeight;
                    self.changeCaptureDeviceFactorPAction(addFactorP);
                }
                
                self.blurView.center = CGPointMake(self.blurView_startCenterPoint.x + tranX, self.blurView_startCenterPoint.y + tranY);
                self.middleCircleView.center = CGPointMake(self.middleCircleView_startCenterPoint.x + tranX, self.middleCircleView_startCenterPoint.y + tranY);
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            //拖延0.25s可以对屏幕操作 是为了保证再点击过快时未结束录制视频又开始执行录制视频
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
            });
            
            if (self.recordState == BKRecordStateRecording) {
                if (self.recordTime == BKRecordVideoMaxTime) {
                    self.recordState = BKRecordStateEnd;
                }else{
                    self.recordState = BKRecordStatePause;
                }
                //拖延0.15s结束录制 是为了保证该段录制视频时间大于0.15s
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self changeRecordAction];
                });
            }else if (self.recordState == BKRecordStateRecordingFailure) {
                [self changeRecordAction];
                self.recordState = BKRecordStatePause;
            }
        }
            break;
        default:
            break;
    }
}

/**
 改变录制按钮状态
 */
-(void)setRecordState:(BKRecordState)recordState
{
    _recordState = recordState;
        
    if (_recordState == BKRecordStateRecording) {
        [self unfoldAnimate:0];
        [self setupTimer];
    }else if (_recordState == BKRecordStatePause || _recordState == BKRecordStateEnd) {
        [self closeAnimate];
        [self removeTimer];
    }
}

/**
 展开动画

 @param state 0第一次大动画 1大动画 2小动画
 */
-(void)unfoldAnimate:(NSInteger)state
{
    if (self.recordState == BKRecordStateRecording) {
        [UIView animateWithDuration:state==0?0.2:0.4 animations:^{
            if (state == 0 || state == 1) {
                self.blurView.transform = CGAffineTransformMakeScale(1.4, 1.4);
                self.middleCircleView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            }else{
                self.blurView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                self.middleCircleView.transform = CGAffineTransformMakeScale(0.8, 0.8);
            }
        } completion:^(BOOL finished) {
            if (state == 1) {
                [self unfoldAnimate:2];
            }else{
                [self unfoldAnimate:1];
            }
        }];
    }
}

/**
 关闭动画
 */
-(void)closeAnimate
{
    [UIView animateWithDuration:0.2 animations:^{
        
        self.blurView.center = self.blurView_startCenterPoint;
        self.middleCircleView.center = self.middleCircleView_startCenterPoint;
        
        self.blurView.transform = CGAffineTransformIdentity;
        self.middleCircleView.transform = CGAffineTransformIdentity;
    }];
}

/**
 进度定时器
 */
-(void)setupTimer
{
    /*
     CABasicAnimation动画已废弃(删除)
     貌似CABasicAnimation动画比定时以kTimerInterval(即0.01)执行一次速度快一个kTimerInterval(即0.01)
     所以全部时间 - 一次间隔 才会和停止的线相对齐
     */
    
    
    CGFloat totalTime = BKRecordVideoMaxTime - self.recordTime;
    if (totalTime < 0) {//如果定时器时间小于0 return
        return;
    }
    self.recordTimer = [[BKTimer sharedManager] bk_setupTimerWithTimeInterval:kTimerInterval totalTime:totalTime handler:^(BKTimerModel *timerModel) {
        self.recordTime = BKRecordVideoMaxTime - timerModel.lastTime;
        if (self.changeRecordTimeAction) {
            self.changeRecordTimeAction(self.recordTime);
        }
        if (self.recordTime == BKRecordVideoMaxTime) {
            [self reachMaxRecordTime];
        }
    }];
}

/**
 删除定时器
 */
-(void)removeTimer
{
    [[BKTimer sharedManager] bk_removeTimer:self.recordTimer];
}

-(void)changeRecordAction
{
    if (self.recordVideoAction) {
        self.recordVideoAction(self.recordState);
    }
}

@end
