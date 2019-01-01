//
//  BKCameraManager.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/24.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKCameraManager.h"
#import "BKCameraFocusRectangle.h"
#import "BKTimer.h"
#import "GPUImage.h"
#import "BKImagePickerMacro.h"
#import "BKImagePickerConstant.h"
#import "UIView+BKImagePicker.h"
#import "UIImage+BKImagePicker.h"
#import "NSObject+BKImagePicker.h"

@interface BKCameraManager()<GPUImageVideoCameraDelegate,GPUImageMovieWriterDelegate>

@property (nonatomic,weak) UIViewController * currentVC;//所在VC
@property (nonatomic,assign) CGPoint startPoint;//记录开始手势的位置

@property (nonatomic,strong) GPUImageVideoCamera * videoCamera;//相机
@property (nonatomic,strong) BKGPUImageBeautyFilter * beautyFilter;//美颜滤镜
@property (nonatomic,strong) GPUImageView * previewView;//预览界面
@property (nonatomic,strong) CIImage * currentCIImage;//当前图像

@property (nonatomic,strong) GPUImageMovieWriter * movieWriter;//视频写入者
@property (nonatomic,strong) UIImage * firstWriteMovieImage;//录制视频第一帧图片
@property (nonatomic,copy) NSString * writeFilePath;//当前写入路径
@property (nonatomic,strong) NSMutableArray * videoPathArr;//录制所有片段路径数组
@property (nonatomic,copy) NSString * previewVideoPath;//预览视频路径

@property (nonatomic,strong) BKCameraFocusRectangle * focusView;//聚焦框
@property (nonatomic,strong) dispatch_source_t focusCursorTimer;//聚焦框消失定时器
@property (nonatomic,assign) CGFloat sunLevel;//太阳级别(亮度) -1~1 默认0

@end

@implementation BKCameraManager

#pragma mark - 公开方法

/**
 开始捕捉画面(在viewDidAppear中调用)
 */
-(void)captureSessionStartRunning
{
    [self.videoCamera startCameraCapture];
    [self setOriginalFocus];
}

/**
 停止捕捉画面(在viewWillDisappear中调用)
 */
-(void)captureSessionStopRunning
{
    [self.videoCamera stopCameraCapture];
}

/**
 获取当前捕捉的图像

 @return 当前捕捉图像
 */
-(UIImage *)getCurrentCaptureImage
{
    UIImage * currentImage = [self imageFromCIImage:self.currentCIImage];
    
    if ([self.videoCamera.targets containsObject:self.beautyFilter]) {

        /*
         报错 Assertion failure in -[GPUImageFramebuffer unlock]
         Tried to overrelease a framebuffer, did you forget to call -useNextFrameForImageCapture before using -imageFromCurrentFramebuffer?
         */
//        GPUImagePicture * imageSource = [[GPUImagePicture alloc] initWithImage:currentImage];
//        [imageSource addTarget:self.beautyFilter];
//        [imageSource processImage];
//        UIImage * resultImage = [self.beautyFilter imageFromCurrentFramebuffer];
//        [self.beautyFilter useNextFrameForImageCapture];
//
//        return resultImage;
       
        /*
         调用以下方法获得当前图片暂时不会报错 时间长了也会报错 Assertion failure in -[GPUImageFramebuffer unlock]
         Tried to overrelease a framebuffer, did you forget to call -useNextFrameForImageCapture before using -imageFromCurrentFramebuffer?
         */
//        setFrameProcessingCompletionBlock有弊端会一直调用
//        __block BOOL next = YES;
//        [self.beautyFilter setFrameProcessingCompletionBlock:^(GPUImageOutput * output, CMTime time) {
//            if (next) {
//                next = NO;
//                UIImage * resultImage = [output imageFromCurrentFramebuffer];
//                [output useNextFrameForImageCapture];
//                if (complete) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        complete(resultImage);
//                    });
//                }
//            }
//        }];
        
        /*
         GPUImage中GPUImageFrameburrer.m文件中 -(void)unlock方法修改成如下
         - (void)unlock;
         {
            if (referenceCountingDisabled)
            {
                return;
            }
         
            if (framebufferReferenceCount < 1) {
                return;
            }
         
            NSAssert(framebufferReferenceCount > 0, @"Tried to overrelease a framebuffer, did you forget to call -useNextFrameForImageCapture before using -imageFromCurrentFramebuffer?");
            framebufferReferenceCount--;
            if (framebufferReferenceCount < 1)
            {
                [[GPUImageContext sharedFramebufferCache] returnFramebufferToCache:self];
            }
         }
         */
        //给while语句加个上限
        NSInteger count = 100;
        GPUImagePicture * imageSource = [[GPUImagePicture alloc] initWithImage:currentImage];
        [imageSource addTarget:self.beautyFilter];
        [imageSource processImage];
        UIImage * resultImage = nil;
        //获取一次图片有可能为nil 多获取几次就有了
        while (!resultImage) {
            if (count < 0) {
                break;
            }
            resultImage = [self.beautyFilter imageFromCurrentFramebuffer];
            [self.beautyFilter useNextFrameForImageCapture];
            count--;
        }
        return resultImage;
    }else {
        return currentImage;
    }
}

/**
 获取当前摄像头方向
 */
-(AVCaptureDevicePosition)getCurrentCaptureDevicePosition
{
    return [self.videoCamera cameraPosition];
}

/**
 开始录制
 */
-(void)startRecordVideo
{
    [self startWriteMovie];
}

/**
 暂停录制
 */
-(void)pauseRecordVideo
{
    [self stopWriteMovie];
}

/**
 完成录制
 */
-(void)finishRecordVideo
{
    [self finishWriteMovie];
}

/**
 视频预览
 */
-(void)previewRecordVideo
{
    if ([self.delegate respondsToSelector:@selector(previewRecordVideo:)]) {
        if ([self.previewVideoPath length] > 0) {
            [self.delegate previewRecordVideo:self.previewVideoPath];
        }else {
            [self synthesisVideoComplete:^(NSString *videoUrlPath) {
                self.previewVideoPath = videoUrlPath;
                [self.delegate previewRecordVideo:self.previewVideoPath];
            }];
        }
    }
}

/**
 删除上一段录制视频

 @return 是否删除成功
 */
-(BOOL)removeLastRecordVideo
{
    if ([self.videoPathArr count] == 0) {
        return NO;
    }
    
    self.previewVideoPath = nil;
    
    NSString * lastVideoPath = [self.videoPathArr lastObject];
    
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:lastVideoPath];
    if (!isExist) {
//        NSLog(@"文件不存在");
        return NO;
    }
    
    NSError * error = nil;
    BOOL flag = [[NSFileManager defaultManager] removeItemAtPath:lastVideoPath error:&error];
    if (!flag) {
//        NSLog(@"%@",error.description);
        return NO;
    }
    [self.videoPathArr removeLastObject];
    if ([self.videoPathArr count] == 0) {
        self.firstWriteMovieImage = nil;
    }
    
    return YES;
}

/**
 切换镜头
 */
-(void)switchCaptureDeviceComplete:(void (^)(BOOL flag, AVCaptureDevicePosition position))complete
{
    //之前的镜头
    AVCaptureDevicePosition oldPosition = [_videoCamera cameraPosition];
    [self.videoCamera rotateCamera];//切换镜头
    //现在的镜头
    AVCaptureDevicePosition currentPosition = [_videoCamera cameraPosition];
    if (oldPosition != currentPosition) {//判断两次镜头是否一致 一致代表失败 不一致代表成功
        [self editVideoPositionAndVideoMirror];
        if (complete) {
            complete(YES, currentPosition);
        }
    }else{
        if (complete) {
            complete(NO, currentPosition);
        }
    }
    
    [self setOriginalFocus];
}

/**
 切换闪光灯 闪光灯只有两种状态 关闭/开启
 */
-(void)modifyFlashModeComplete:(void (^)(BOOL flag, AVCaptureFlashMode flashMode))complete
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice hasTorch] && [captureDevice hasFlash]) {
            if (captureDevice.flashMode == AVCaptureFlashModeOn) {
                [captureDevice setTorchMode:AVCaptureTorchModeOff];
                [captureDevice setFlashMode:AVCaptureFlashModeOff];
            }else if (captureDevice.flashMode == AVCaptureFlashModeOff) {
                [captureDevice setTorchMode:AVCaptureTorchModeOn];
                [captureDevice setFlashMode:AVCaptureFlashModeOn];
            }
            if (complete) {
                complete(YES, captureDevice.flashMode);
            }
        }else {
            if (complete) {
                complete(NO, captureDevice.flashMode);
            }
        }
    }];
}

/**
 增加焦距比例
 
 @param factorP 焦距比例 (焦距范围1~2 默认1)
 */
-(void)addFactorP:(CGFloat)factorP
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        
        CGFloat minFactor = 1;
        CGFloat maxFactor = 6;
        if (@available(iOS 11.0, *)) {
            if (maxFactor > captureDevice.maxAvailableVideoZoomFactor) {
                maxFactor = captureDevice.maxAvailableVideoZoomFactor;
            }
        } else {
            if (maxFactor > captureDevice.activeFormat.videoMaxZoomFactor) {
                maxFactor = captureDevice.activeFormat.videoMaxZoomFactor;
            }
        }
        CGFloat factor_max_min_gap = maxFactor - minFactor;
        CGFloat resultFactor = captureDevice.videoZoomFactor + factorP * factor_max_min_gap;
        if (resultFactor > maxFactor) {
            resultFactor = maxFactor;
        }else if (resultFactor < minFactor) {
            resultFactor = minFactor;
        }
        captureDevice.videoZoomFactor = resultFactor;
        
    }];
}

/**
 修改美颜等级
 
 @param level 等级 0~5
 */
-(void)switchBeautyFilterLevel:(BKBeautyLevel)level
{
    //美颜最高等级5
    if (level > BKBeautyLevelFive) {
        level = BKBeautyLevelFive;
    }else if (level < BKBeautyLevelZero) {//美颜最低等级0
        level = BKBeautyLevelZero;
    }
    
    self.beautyFilter.beautyLevel = level;
}

/**
 修改皮肤色彩
 
 @param type 色彩滤镜格式
 @param level 级别 0~1
 */
-(void)switchLookupFilterType:(BKBeautifulSkinType)type level:(CGFloat)level
{
    [self.beautyFilter switchLookupFilterType:type level:level];
}

/**
 删除文件目录

 @return 是否删除成功
 */
-(BOOL)removeSaveFileDirectory
{
    NSString * fileDir = [self checkSaveFileDirectory];
    NSError * error = nil;
    BOOL flag = [[NSFileManager defaultManager] removeItemAtPath:fileDir error:&error];
    if (!flag) {
        //        NSLog(@"%@",error.description);
        return NO;
    }
    return YES;
}

#pragma mark - 初始方法

-(instancetype)initWithCurrentVC:(UIViewController*)currentVC
{
    self = [super init];
    if (self) {
        self.currentVC = currentVC;
        //添加预览界面
        [self.currentVC.view insertSubview:self.previewView atIndex:0];
        //录制设备添加滤镜
        [self.videoCamera addTarget:self.beautyFilter];
        //把添加完成滤镜的图像添加在预览界面
        [self.beautyFilter addTarget:self.previewView];
    }
    return self;
}

#pragma mark - GPUImageView

-(GPUImageView*)previewView
{
    if (!_previewView) {
        _previewView = [[GPUImageView alloc] initWithFrame:self.currentVC.view.bounds];
        _previewView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
        [_previewView setBackgroundColorRed:0 green:0 blue:0 alpha:1];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewViewTap:)];
        [_previewView addGestureRecognizer:tap];
        
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(previewViewPan:)];
        [_previewView addGestureRecognizer:pan];
    }
    return _previewView;
}

-(void)previewViewTap:(UITapGestureRecognizer *)tapGesture
{
    //获取点击坐标
    CGPoint point = [tapGesture locationInView:self.previewView];
    [self setFocusCursorWithPoint:point isDisPlaySun:YES];
    
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = CGPointZero;
    if ([_videoCamera cameraPosition] == AVCaptureDevicePositionBack) {
        cameraPoint = CGPointMake(point.y / self.previewView.bk_height, 1 - (point.x / self.previewView.bk_width));
    }else if ([_videoCamera cameraPosition] == AVCaptureDevicePositionFront) {
        cameraPoint = CGPointMake(point.y / self.previewView.bk_height, point.x / self.previewView.bk_width);
    }
    //聚焦一次效果不佳 第二次连续聚焦
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:cameraPoint];
    
    if ([self.delegate respondsToSelector:@selector(recordViewTapGestureRecognizer)]) {
        [self.delegate recordViewTapGestureRecognizer];
    }
}

-(void)previewViewPan:(UIPanGestureRecognizer*)panGesture
{
    CGPoint point = [panGesture translationInView:self.previewView];
    
    CGFloat totalHeight = self.previewView.bk_height - 200;
    CGFloat addY = -point.y / totalHeight;
    
    //如果聚焦框不存在 滑动手势调整焦距大小
    if (!self.focusView) {
        [self addFactorP:addY];
    }else {
        //如果聚焦框存在 & 显示太阳 滑动手势调整亮度
        if (self.focusView.isDisplaySun) {
            self.sunLevel += addY;
            if (self.sunLevel > 1) {
                self.sunLevel = 1;
            }else if (self.sunLevel < -1) {
                self.sunLevel = -1;
            }
            self.focusView.sunLevel = self.sunLevel;
            self.beautyFilter.brightnessLevel = self.sunLevel*0.7;
            
            [self resetFocusCursorTimer];
        }
    }
    
    [panGesture setTranslation:CGPointZero inView:self.previewView];
}

#pragma mark - GPUImageVideoCamera

-(GPUImageVideoCamera*)videoCamera
{
    if (!_videoCamera) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.delegate = self;
        [_videoCamera addAudioInputsAndOutputs];
        [self editVideoPositionAndVideoMirror];
    }
    return _videoCamera;
}

/**
 调整摄像方向和镜像翻转
 */
-(void)editVideoPositionAndVideoMirror
{
    if ([_videoCamera cameraPosition] == AVCaptureDevicePositionBack) {
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    }else if ([_videoCamera cameraPosition] == AVCaptureDevicePositionFront) {
        [_videoCamera videoCaptureConnection].videoMirrored = YES;
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortraitUpsideDown;
    }
}

#pragma mark - GPUImageVideoCameraDelegate

-(void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //用此方法把CMSampleBufferRef转CIImage再转UIImage此时image方向不对 调整方向需要UIImage转CGImageRef这时转的CGImageRef为空
    //需要提前把CIImage转成CGImageRef调整方向 最后转成UIImage
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    self.currentCIImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
}

#pragma mark - 把CIImage转UIImage

/**
 把设备获取的CIImage转成UIImage
 */
-(UIImage*)imageFromCIImage:(CIImage*)ciImage
{
    CIContext * context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:ciImage fromRect:[ciImage extent]];
    
    UIImage * image = nil;
    if ([_videoCamera cameraPosition] == AVCaptureDevicePositionBack) {
        image = [self bk_editImageRef:imageRef Orientation:UIImageOrientationRight];
    }else if ([_videoCamera cameraPosition] == AVCaptureDevicePositionFront){
        image = [self bk_editImageRef:imageRef Orientation:UIImageOrientationLeft];
    }
    
    CGImageRelease(imageRef);
    
    return image;

//    用GPUImage录像下面方法报错 [Unknown process name] CGBitmapContextCreate: invalid data bytes/row: should be at least 7680 for 8 integer bits/component, 3 components, kCGImageAlphaPremultipliedFirst
//    自己写的录像代理方法中下面方法没错 自己在此记录一下
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CVPixelBufferLockBaseAddress(imageBuffer, 0);
//    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//    size_t width = CVPixelBufferGetWidth(imageBuffer);
//    size_t height = CVPixelBufferGetHeight(imageBuffer);
//    if (width == 0 || height == 0) {
//        return nil;
//    }
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    void * baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
//
//    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
//    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
//
//    UIImage * image = [UIImage imageWithCGImage:quartzImage];
//    CGImageRelease(quartzImage);
//    return image;
}

/**
 修改图片方向
 */
-(UIImage*)bk_editImageRef:(CGImageRef)imageRef Orientation:(UIImageOrientation)orientation
{
    CGRect rect = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    
    CGRect editRect = rect;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown:
        {
            transform = CGAffineTransformMakeTranslation(rect.size.width, rect.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
        }
            break;
        case UIImageOrientationLeft:
        {
            editRect = CGRectMake(0, 0, rect.size.height, rect.size.width);
            transform = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
        }
            break;
        case UIImageOrientationRight:
        {
            editRect = CGRectMake(0, 0, rect.size.height, rect.size.width);
            transform = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
        }
            break;
        case UIImageOrientationUpMirrored:
        {
            transform = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
        }
            break;
        case UIImageOrientationDownMirrored:
        {
            transform = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
        }
            break;
        case UIImageOrientationLeftMirrored:
        {
            editRect = CGRectMake(0, 0, rect.size.height, rect.size.width);
            transform = CGAffineTransformMakeTranslation(rect.size.height, rect.size.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
        }
            break;
        case UIImageOrientationRightMirrored:
        {
            editRect = CGRectMake(0, 0, rect.size.height, rect.size.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
        }
            break;
        default:
        {
            return [UIImage imageWithCGImage:imageRef];
        }
            break;
    }
    
    UIGraphicsBeginImageContext(editRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    switch (orientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            CGContextScaleCTM(ctx, -1.0, 1.0);
            CGContextTranslateCTM(ctx, -rect.size.height, 0.0);
        }
            break;
        default:
        {
            CGContextScaleCTM(ctx, 1.0, -1.0);
            CGContextTranslateCTM(ctx, 0.0, -rect.size.height);
        }
            break;
    }
    
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imageRef);
    
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

#pragma mark - BKGPUImageBeautyFilter

-(BKGPUImageBeautyFilter*)beautyFilter
{
    if (!_beautyFilter) {
        _beautyFilter = [[BKGPUImageBeautyFilter alloc] init];
    }
    return _beautyFilter;
}

#pragma mark - GPUImageMovieWriter

-(NSMutableArray*)videoPathArr
{
    if (!_videoPathArr) {
        _videoPathArr = [[NSMutableArray alloc] init];
    }
    return _videoPathArr;
}

-(NSString *)checkSaveFileDirectory
{
    NSString * directory = [NSTemporaryDirectory() stringByAppendingString:@"BKImagePicker"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL exist = [fileManager fileExistsAtPath:directory isDirectory:&isDir];
    if (!(isDir && exist)) {
        [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directory;
}

-(NSString*)writeFilePath
{
    if (!_writeFilePath) {
        NSInteger dateSp = [[NSDate date] timeIntervalSince1970];
        _writeFilePath = [NSString stringWithFormat:@"%@/Temp%ld.mp4",[self checkSaveFileDirectory],dateSp];
    }
    return _writeFilePath;
}

-(NSDictionary*)settingVideoCompression
{
    //写入视频大小
    NSInteger numPixels = self.previewView.bk_width * self.previewView.bk_height;
    //每像素比特
    CGFloat bitsPerPixel = 8;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    // 码率和帧率设置
    NSDictionary * compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                              AVVideoExpectedSourceFrameRateKey : @(30),
                                              AVVideoMaxKeyFrameIntervalKey : @(30),
                                              AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel };
    
    //视频属性
    NSDictionary * videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                                 AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                                 AVVideoWidthKey : @(self.previewView.bk_width * [UIScreen mainScreen].scale),
                                                 AVVideoHeightKey : @(self.previewView.bk_height * [UIScreen mainScreen].scale),
                                                 AVVideoCompressionPropertiesKey : compressionProperties };
    
    return videoCompressionSettings;
}

-(NSDictionary*)settingAudioCompression
{
    // 音频设置
    NSDictionary * audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
                                                 AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                                 AVNumberOfChannelsKey : @(1),
                                                 AVSampleRateKey : @(22050) };
    
    return audioCompressionSettings;
}

-(GPUImageMovieWriter*)movieWriter
{
    if (!_movieWriter) {
        
        CGSize movieSize = CGSizeMake(self.previewView.bk_width * [UIScreen mainScreen].scale, self.previewView.bk_height * [UIScreen mainScreen].scale);
        
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:[NSURL fileURLWithPath:self.writeFilePath] size:movieSize fileType:AVFileTypeMPEG4 outputSettings:[self settingVideoCompression]];
        [_movieWriter setHasAudioTrack:YES audioSettings:[self settingAudioCompression]];
        _movieWriter.encodingLiveVideo = YES;
        _movieWriter.assetWriter.movieFragmentInterval = kCMTimeInvalid;
        _movieWriter.shouldPassthroughAudio = YES;
        _movieWriter.delegate = self;
    }
    return _movieWriter;
}

-(void)startWriteMovie
{
    self.previewVideoPath = nil;
    
    if ([self.videoCamera.targets containsObject:self.beautyFilter]) {
        [self.beautyFilter addTarget:self.movieWriter];
    }else {
        [self.videoCamera addTarget:self.movieWriter];
    }
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    [self.movieWriter startRecording];
}

-(void)stopWriteMovie
{
    [self.movieWriter finishRecordingWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.videoCamera.targets containsObject:self.beautyFilter]) {
                [self.beautyFilter removeTarget:self.movieWriter];
            }else {
                [self.videoCamera removeTarget:self.movieWriter];
            }
            self.videoCamera.audioEncodingTarget = nil;
            
            if ([self.videoPathArr count] == 0) {
                self.firstWriteMovieImage = [self firstImageForVideo:[NSURL fileURLWithPath:self.writeFilePath]];
            }
            [self.videoPathArr addObject:self.writeFilePath];
            
            self.writeFilePath = nil;
            self.movieWriter = nil;
        });
    }];
}

-(void)finishWriteMovie
{
    if ([self.previewVideoPath length] > 0) {
        if ([self.delegate respondsToSelector:@selector(finishRecordedVideo:firstFrameImage:)]) {
            [self.delegate finishRecordedVideo:self.previewVideoPath firstFrameImage:self.firstWriteMovieImage];
        }
    }else{
        [self synthesisVideoComplete:^(NSString *videoUrlPath) {
            if ([self.delegate respondsToSelector:@selector(finishRecordedVideo:firstFrameImage:)]) {
                [self.delegate finishRecordedVideo:videoUrlPath firstFrameImage:self.firstWriteMovieImage];
            }
        }];
    }
}

#pragma mark - GPUImageMovieWriterDelegate

- (void)movieRecordingFailedWithError:(NSError*)error
{
//    NSLog(@"视频写入失败:%@",error.description);
    
    if ([self.videoCamera.targets containsObject:self.beautyFilter]) {
        [self.beautyFilter removeTarget:self.movieWriter];
    }else {
        [self.videoCamera removeTarget:self.movieWriter];
    }
    self.videoCamera.audioEncodingTarget = nil;
    self.writeFilePath = nil;
    self.movieWriter = nil;
    
    if ([self.delegate respondsToSelector:@selector(recordingFailure:)]) {
        [self.delegate recordingFailure:error];
    }
}

#pragma mark - 视频合成

-(void)synthesisVideoComplete:(void (^)(NSString * videoUrlPath))complete
{
    [self.currentVC.view bk_showLoadLayer];
    
    NSMutableArray * assertArr = [NSMutableArray array];
    for (NSString * fileURLStr in self.videoPathArr) {
        AVAsset * asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:fileURLStr]];
        if (!asset) {
            continue;
        }
        [assertArr addObject:asset];
    }
    if ([assertArr count] == 0) {
        [self.currentVC.view bk_showRemind:BKRecordedVideoWasNotFoundRemind];
        [self.currentVC.view bk_hideLoadLayer];
        return;
    }
    
    // 组成
    AVMutableComposition * mixComposition = [AVMutableComposition composition];
    
    //合成音频轨道
    AVMutableCompositionTrack * audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //合成视频轨道
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    Float64 startTime = 0.0f;
    NSError * error;
    for (int i = 0; i < [assertArr count] ; i++) {
        
        AVAsset * asset = [assertArr objectAtIndex:i];
        
        CMTime duration;
        if (i == 0) {
            duration = CMTimeMakeWithSeconds(0, asset.duration.timescale);
        }else{
            duration = CMTimeMakeWithSeconds(startTime, asset.duration.timescale);
        }
        
        //GPUImage录制视频时第一帧和最后一帧有时候是黑屏 所以把视频的第一帧和最后一帧删除
        //为了多视频合成看起来更顺滑 所以删除每个视频的前两帧和最后两帧
        //1秒30帧
        CMTime aFrameSecond = CMTimeMake(2, 30);
        //去除视频第一帧和最后一帧
        CMTime recordTime = CMTimeSubtract(asset.duration, CMTimeMake(4, 30));
        //音频采集通道
        AVAssetTrack * audioAssetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //把音频插入到 AVMutableCompositionTrack
        [audioTrack insertTimeRange:CMTimeRangeMake(aFrameSecond, recordTime)
                            ofTrack:audioAssetTrack
                             atTime:duration
                              error:nil];
        
        //视频采集通道
        AVAssetTrack * videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        //把视频轨道插入到 AVMutableCompositionTrack
        [videoTrack insertTimeRange:CMTimeRangeMake(aFrameSecond, recordTime)
                            ofTrack:videoAssetTrack
                             atTime:duration
                              error:&error];
        
        if (error) {
//            break;
            continue;
        }
        
        startTime += CMTimeGetSeconds(recordTime);
    }
    
    if (startTime == 0.0) {
        [self.currentVC.view bk_showRemind:BKVideoSynthesisFailedRemind];
        [self.currentVC.view bk_hideLoadLayer];
        return;
    }
    
    NSInteger dateSp = [[NSDate date] timeIntervalSince1970];
    NSString * lastFilePath = [NSString stringWithFormat:@"%@/Result%ld.mp4",[self checkSaveFileDirectory],dateSp];
    
    //合成 并且压缩 质量AVAssetExportPresetMediumQuality//质量AVAssetExportPresetMediumQuality
    AVAssetExportSession * session = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    session.outputURL = [NSURL fileURLWithPath:lastFilePath];
    session.outputFileType = AVFileTypeMPEG4;
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //如果转换成功
            if (session.status == AVAssetExportSessionStatusCompleted) {
                if (complete) {
                    complete(lastFilePath);
                }
            }else{
                [self.currentVC.view bk_showRemind:BKVideoSynthesisFailedRemind];
            }
            [self.currentVC.view bk_hideLoadLayer];
        });
    }];
}

#pragma mark - 获取视频的第一帧

- (UIImage*)firstImageForVideo:(NSURL *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];

    AVAssetImageGenerator * assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;

    NSError * error = nil;
    CGImageRef imageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(0, 30) actualTime:NULL error:&error];
    if (error) {
        return nil;
    }

    UIImage * image = imageRef?[[UIImage alloc]initWithCGImage:imageRef]:nil;

    return image;
}

#pragma mark - 设置最初焦距捕捉点

/**
 切换摄像头聚焦点切为中心点
 */
-(void)setOriginalFocus
{
    //取摄像头坐标中心
    CGPoint cameraPoint = CGPointMake(0.5, 0.5);
//    切换摄像头默认不限聚焦框 若想显示解开下一行注释
//    [self setFocusCursorWithPoint:CGPointMake(self.previewView.bk_width * cameraPoint.x, self.previewView.bk_height * cameraPoint.y) isDisPlaySun:NO];
    //聚焦一次效果不佳 第二次连续聚焦
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposureMode:AVCaptureExposureModeContinuousAutoExposure atPoint:cameraPoint];
}

#pragma mark - 改变录制属性

/**
 设置聚焦光标位置

 @param point 光标位置
 @param isDisPlaySun 是否显示太阳
 */
-(void)setFocusCursorWithPoint:(CGPoint)point isDisPlaySun:(BOOL)isDisPlaySun
{
    if (self.focusCursorTimer) {
        [[BKTimer sharedManager] bk_removeTimer:self.focusCursorTimer];

        [self.focusView removeFromSuperview];
        self.focusView = nil;
    }

    if (isDisPlaySun) {
        self.focusView = [[BKCameraFocusRectangle alloc]initWithPoint:point sunLevel:self.sunLevel];
    }else{
        self.focusView = [[BKCameraFocusRectangle alloc]initWithPoint:point];
    }
    [self.currentVC.view insertSubview:self.focusView aboveSubview:_previewView];
    [UIView animateWithDuration:0.3 animations:^{
        self.focusView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    }];

    [self resetFocusCursorTimer];
}

-(void)resetFocusCursorTimer
{
    if (self.focusCursorTimer) {
        [[BKTimer sharedManager] bk_removeTimer:self.focusCursorTimer];
    }
    
    self.focusCursorTimer = [[BKTimer sharedManager] bk_setupTimerWithTimeInterval:1 totalTime:2 handler:^(BKTimerModel *timerModel) {
        if (timerModel.lastTime == 0) {
            [self.focusView removeFromSuperview];
            self.focusView = nil;
        }
    }];
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
    AVCaptureDevice * captureDevice = [self.videoCamera inputCamera];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        if (propertyChange) {
            propertyChange(captureDevice);
        }
        [captureDevice unlockForConfiguration];
    }else{
        [self.currentVC.view bk_showRemind:BKSettingDevicePropertiesFailedRemind];
    }
}

@end
