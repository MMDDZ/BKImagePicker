//
//  BKImageTakePhotoViewController.m
//  guoguanjuyanglao
//
//  Created by BIKE on 2017/12/21.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKImageTakePhotoViewController.h"
#import "BKTool.h"
#import <AVFoundation/AVFoundation.h>
#import "BKImageTakePhotoBtn.h"
#import "BKEditImageViewController.h"

@interface BKImageTakePhotoViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic,strong) UIView * previewView;//预览界面
@property (nonatomic,strong) dispatch_queue_t videoQueue;//视频队列
@property (nonatomic,strong) AVCaptureDeviceInput * videoInput;//视频输入
@property (nonatomic,strong) AVCaptureVideoDataOutput * videoOutput;//视频输出
@property (nonatomic,strong) AVCaptureSession * captureSession;//负责输入和输出设备之间的数据传递
@property (nonatomic,strong) AVCaptureVideoPreviewLayer * previewLayer;//相机拍摄预览图层

@property (nonatomic,strong) UIImage * currentImage;//当前图片

@property (nonatomic,strong) UIImageView * focusImageView;//聚焦框
@property (nonatomic,strong) NSTimer * focusCursorTimer;//聚焦框消失定时器

@property (nonatomic,strong) BKImageTakePhotoBtn * shutterBtn;//快门按钮
@property (nonatomic,strong) UIButton * closeBtn;//关闭按钮
@property (nonatomic,strong) UIButton * lightBtn;//闪光按钮
@property (nonatomic,strong) UIButton * switchShotBtn;//镜头按钮


@end

@implementation BKImageTakePhotoViewController

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.topNavView.hidden = YES;
    self.bottomNavView.hidden = YES;
    
    [self.view addSubview:self.previewView];
    
    [self.captureSession startRunning];
    if (_videoInput) {
        AVCaptureDevice * captureDevice = [_videoInput device];
        [self addNotificationToCaptureDevice:captureDevice];
    }
    
    [self.view addSubview:self.shutterBtn];
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.lightBtn];
    [self.view addSubview:self.switchShotBtn];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.captureSession startRunning];
    if (_videoInput) {
        AVCaptureDevice * captureDevice = [_videoInput device];
        [self addNotificationToCaptureDevice:captureDevice];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self.captureSession stopRunning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 预览界面

-(UIView*)previewView
{
    if (!_previewView) {
        _previewView = [[UIView alloc]initWithFrame:self.view.bounds];
        _previewView.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewViewTap:)];
        [_previewView addGestureRecognizer:tap];
    }
    return _previewView;
}

#pragma mark - 初始化拍照属性

-(AVCaptureSession*)captureSession
{
    if (!_captureSession) {
        
        //初始化会话
        _captureSession = [[AVCaptureSession alloc]init];
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {//设置分辨率
            _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        }
        
        _videoQueue = dispatch_queue_create("videoQueue", DISPATCH_QUEUE_SERIAL);
        
        //获得输入设备
        AVCaptureDevice * captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
        if (!captureDevice) {
            captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];//取得前置摄像头
            if (!captureDevice) {
                [[BKTool sharedManager] showRemind:@"取得摄像头时出现问题!"];
                [self dismissViewControllerAnimated:YES completion:nil];
                return nil;
            }
        }
        
        NSError *error = nil;
        
        _videoInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
        if (error) {
            [[BKTool sharedManager] showRemind:@"初始化设备出错"];
            [self dismissViewControllerAnimated:YES completion:nil];
            return nil;
        }
        if ([_captureSession canAddInput:_videoInput]) {
            [_captureSession addInput:_videoInput];
        }
        
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoOutput.alwaysDiscardsLateVideoFrames = YES; //立即丢弃旧帧，节省内存，默认YES
        [_videoOutput setSampleBufferDelegate:self queue:self.videoQueue];
        [_videoOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
                                         @"Width":@([UIScreen mainScreen].scale*BK_SCREENW),
                                         @"Height":@([UIScreen mainScreen].scale*BK_SCREENH),
                                         }];
        if ([_captureSession canAddOutput:_videoOutput]) {
            [_captureSession addOutput:_videoOutput];
        }
        
        //根据设备输出获得连接
        AVCaptureConnection * connection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        AVCaptureDevicePosition currentPosition = [[_videoInput device] position];
        // 前置摄像头镜像翻转 保证和后置摄像头镜头方向一致
        if (currentPosition == AVCaptureDevicePositionFront) {
            connection.videoMirrored = YES;
        }else{
            connection.videoMirrored = NO;
        }
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        
        //创建视频预览层，用于实时展示摄像头状态
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession];
        _previewLayer.frame = self.previewView.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//填充模式
        [self.previewView.layer addSublayer:_previewLayer];
        
    }
    return _captureSession;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    _currentImage = [self imageFromSampleBuffer:sampleBuffer];
}

-(UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    CGImageRelease(quartzImage);
    return image;
}

#pragma mark - 获取摄像头

/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSString * version = [UIDevice currentDevice].systemVersion;
    if ([version doubleValue] >= 10) {
        
        AVCaptureDeviceDiscoverySession * session = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
        
        NSArray * devices  = session.devices;
        for (AVCaptureDevice * device in devices) {
            if ([device position] == position) {
                return device;
            }
        }
        return nil;
    }else{
        NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice * device in devices) {
            if ([device position] == position) {
                return device;
            }
        }
        return nil;
    }
}

#pragma mark - 镜头捕捉区域改变
/**
 *  给输入设备添加通知
 */
-(void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    //捕获区域发生改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}

/**
 捕获区域发生改变
 
 @param notification notification
 */
-(void)areaChange:(NSNotification*)notification
{
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:self.previewView.center];
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:cameraPoint];
}

/**
 手动改变捕获区域

 @param tapGesture 手指点击方法
 */
-(void)previewViewTap:(UITapGestureRecognizer *)tapGesture
{
    //获取点击坐标
    CGPoint point = [tapGesture locationInView:self.previewView];
    [self setFocusCursorWithPoint:point];
    
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:cameraPoint];
}

#pragma mark - 改变录制属性

/**
 *  设置聚焦光标位置
 *
 *  @param point 光标位置
 */
-(void)setFocusCursorWithPoint:(CGPoint)point
{
    if (_focusCursorTimer) {
        [_focusCursorTimer invalidate];
        _focusCursorTimer = nil;
        
        [self.focusImageView removeFromSuperview];
        self.focusImageView = nil;
    }
    
    self.focusImageView.center = point;
    [UIView animateWithDuration:0.2 animations:^{
        self.focusImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }];
    
    _focusCursorTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(deleteFocusCursor:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_focusCursorTimer forMode:NSRunLoopCommonModes];
}

/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(void (^)(AVCaptureDevice *captureDevice))propertyChange
{
    AVCaptureDevice *captureDevice = [self.videoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        if (propertyChange) {
            propertyChange(captureDevice);
        }
        [captureDevice unlockForConfiguration];
    }else{
        [[BKTool sharedManager] showRemind:@"设置设备属性过程发生错误,请重试"];
    }
}

#pragma mark - 聚焦框

-(UIImageView*)focusImageView
{
    if (!_focusImageView) {
        _focusImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, BK_SCREENW/4, BK_SCREENW/4)];
        _focusImageView.clipsToBounds = YES;
        _focusImageView.contentMode = UIViewContentModeScaleAspectFit;
        _focusImageView.image = [[BKTool sharedManager] takePhotoImageWithImageName:@"takephoto_focus"];
        [self.view insertSubview:_focusImageView aboveSubview:_previewView];
    }
    return _focusImageView;
}

-(void)deleteFocusCursor:(NSTimer*)timer
{
    [self.focusImageView removeFromSuperview];
    self.focusImageView = nil;
}

#pragma mark - 关闭按钮

-(UIButton*)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(0, BK_SYSTEM_STATUSBAR_HEIGHT, 64, BK_SYSTEM_NAV_UI_HEIGHT);
        [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView * closeImageView = [[UIImageView alloc]initWithFrame:CGRectMake((_closeBtn.bk_width - 25)/2, (_closeBtn.bk_height - 25)/2, 25, 25)];
        closeImageView.image = [[BKTool sharedManager] takePhotoImageWithImageName:@"takephoto_close"];
        [_closeBtn addSubview:closeImageView];
    }
    return _closeBtn;
}

-(void)closeBtnClick:(UIButton*)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 镜头翻转

-(UIButton*)switchShotBtn
{
    if (!_switchShotBtn) {
        _switchShotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchShotBtn.frame = CGRectMake(BK_SCREENW - 44 - 10, BK_SYSTEM_STATUSBAR_HEIGHT, 44, BK_SYSTEM_NAV_UI_HEIGHT);
        [_switchShotBtn addTarget:self action:@selector(switchShotBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView * switchShotImageView = [[UIImageView alloc]initWithFrame:CGRectMake((_switchShotBtn.bk_width - 25)/2, (_switchShotBtn.bk_height - 25)/2, 25, 25)];
        switchShotImageView.image = [[BKTool sharedManager] takePhotoImageWithImageName:@"takephoto_switch_shot"];
        [_switchShotBtn addSubview:switchShotImageView];
    }
    return _switchShotBtn;
}

-(void)switchShotBtnClick:(UIButton*)button
{
    //当前设备
    AVCaptureDevice * currentDevice = self.videoInput.device;
    //当前摄像头
    AVCaptureDevicePosition currentPosition = self.videoInput.device.position;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentDevice];
    
    //获取需要切换的摄像头
    if (currentPosition == AVCaptureDevicePositionBack) {
        currentPosition = AVCaptureDevicePositionFront;
        _lightBtn.hidden = YES;
        if (_lightBtn.isSelected) {
            [self lightBtnClick:_lightBtn];
        }
    } else {
        currentPosition = AVCaptureDevicePositionBack;
        _lightBtn.hidden = NO;
    }
    //获取新的设备
    AVCaptureDevice * toDevice = nil;
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * camera in cameras) {
        if ([camera position] == currentPosition) {
            toDevice = camera;
        }
    }
    
    [self addNotificationToCaptureDevice:toDevice];
    
    //创建新的input
    AVCaptureDeviceInput * toInput = [AVCaptureDeviceInput deviceInputWithDevice:toDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.videoInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:toInput]) {
        [self.captureSession addInput:toInput];
        self.videoInput = toInput;
    }
    
    //根据设备输出获得连接
    AVCaptureConnection * connection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    // 前置摄像头镜像翻转 保证和后置摄像头镜头方向一致
    if (currentPosition == AVCaptureDevicePositionFront) {
        connection.videoMirrored = YES;
    }else{
        connection.videoMirrored = NO;
    }
    connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    //提交会话配置
    [self.captureSession commitConfiguration];
}

#pragma mark - 闪光灯

-(UIButton*)lightBtn
{
    if (!_lightBtn) {
        _lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lightBtn.frame = CGRectMake(self.switchShotBtn.bk_x - 44, BK_SYSTEM_STATUSBAR_HEIGHT, 44, BK_SYSTEM_NAV_UI_HEIGHT);
        [_lightBtn addTarget:self action:@selector(lightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView * lightImageView = [[UIImageView alloc]initWithFrame:CGRectMake((_lightBtn.bk_width - 25)/2, (_lightBtn.bk_height - 25)/2, 25, 25)];
        lightImageView.image = [[BKTool sharedManager] takePhotoImageWithImageName:@"takephoto_close_light"];
        lightImageView.tag = 1;
        [_lightBtn addSubview:lightImageView];
    }
    return _lightBtn;
}

-(void)lightBtnClick:(UIButton*)button
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            UIImageView * lightImageView = (UIImageView*)[_lightBtn viewWithTag:1];
            
            if (!button.isSelected) {
                button.selected = YES;
                
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
                lightImageView.image = [[BKTool sharedManager] takePhotoImageWithImageName:@"takephoto_open_light"];
            }else{
                button.selected = NO;
                
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                
                lightImageView.image = [[BKTool sharedManager] takePhotoImageWithImageName:@"takephoto_close_light"];
            }
            
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - 快门按钮

-(BKImageTakePhotoBtn*)shutterBtn
{
    if (!_shutterBtn) {
        _shutterBtn = [[BKImageTakePhotoBtn alloc]initWithFrame:CGRectMake((BK_SCREENW - 75)/2, BK_SCREENH - 75 - 40, 75, 75)];
        BK_WEAK_SELF(self);
        [_shutterBtn setShutterAction:^{
            BK_STRONG_SELF(self);
            BKEditImageViewController * vc = [[BKEditImageViewController alloc]init];
            vc.editImageArr = @[strongSelf.currentImage];
            vc.fromModule = BKEditImageFromModuleTakePhoto;
            [strongSelf.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _shutterBtn;
}



@end
