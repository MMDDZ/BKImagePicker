//
//  BKTool.m
//  BKImagePicker
//
//  Created by BIKE on 16/10/19.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKTool.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

NSString * const BKFinishTakePhotoNotification = @"BKFinishTakePhotoNotification";//拍照完成通知
NSString * const BKFinishSelectImageNotification = @"BKFinishSelectImageNotification";//选择完成通知

float const BKAlbumImagesSpacing = 1;//相簿图片间距
float const BKExampleImagesSpacing = 10;//查看的大图图片间距
float const BKCheckExampleImageAnimateTime = 0.5;//查看大图图片过场动画时间
float const BKCheckExampleGifAndVideoAnimateTime = 0.3;//查看Gif、Video过场动画时间
float const BKThumbImageCompressSizeMultiplier = 0.5;//图片长宽压缩比例 (小于1会把图片的长宽缩小)

@interface BKTool()

@property (nonatomic,copy) NSString * imagePath;//图片路径

@property (nonatomic,strong) PHCachingImageManager * cachingImageManager;//图片缓存管理者

@end

@implementation BKTool

-(NSMutableArray*)selectImageArray
{
    if (!_selectImageArray) {
        _selectImageArray = [NSMutableArray array];
    }
    return _selectImageArray;
}

-(PHCachingImageManager*)cachingImageManager
{
    if (!_cachingImageManager) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

+(instancetype)sharedManager
{
    static BKTool * shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[BKTool alloc]init];
    });
    return shareInstance;
}

#pragma mark - 获取当前屏幕显示的viewcontroller

-(UIViewController *)getCurrentVC
{
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    UIViewController *parent = rootVC;
    
    while ((parent = rootVC.presentedViewController) != nil ) {
        rootVC = parent;
    }
    
    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }
    
    return rootVC; 
}

#pragma mark - 弹框提示

-(void)presentAlert:(NSString*)title message:(NSString*)message actionTitleArr:(NSArray*)actionTitleArr actionMethod:(void (^)(NSInteger index))actionMethod
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSString * title in actionTitleArr) {
        
        NSInteger style;
        if ([title isEqualToString:@"取消"]) {
            style = UIAlertActionStyleCancel;
        }else{
            style = UIAlertActionStyleDefault;
        }
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
            if (actionMethod) {
                actionMethod([actionTitleArr indexOfObject:title]);
            }
        }];
        [alert addAction:action];
    }
    [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 提示

/**
 提示
 
 @param text 文本
 */
-(void)showRemind:(NSString*)text
{
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    
    UIView * bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    bgView.layer.cornerRadius = 8.0f;
    bgView.clipsToBounds = YES;
    [window addSubview:bgView];
    
    UILabel * remindLab = [[UILabel alloc]init];
    remindLab.textColor = [UIColor whiteColor];
    CGFloat fontSize = 13.0 * window.bounds.size.width/320.0f;
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    remindLab.font = font;
    remindLab.textAlignment = NSTextAlignmentCenter;
    remindLab.numberOfLines = 0;
    remindLab.backgroundColor = [UIColor clearColor];
    remindLab.text = text;
    [bgView addSubview:remindLab];
    
    CGFloat width = [self sizeWithString:text UIHeight:window.bounds.size.height font:font].width;
    if (width > window.bounds.size.width/4.0*3.0f) {
        width = window.bounds.size.width/4.0*3.0f;
    }
    CGFloat height = [self sizeWithString:text UIWidth:width font:font].height;
    
    bgView.bounds = CGRectMake(0, 0, width+30, height+30);
    bgView.layer.position = CGPointMake(window.bounds.size.width/2.0f, window.bounds.size.height/2.0f);
    
    remindLab.bounds = CGRectMake(0, 0, width, height);
    remindLab.layer.position = CGPointMake(bgView.bounds.size.width/2.0f, bgView.bounds.size.height/2.0f);
    
    [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [bgView removeFromSuperview];
    }];
}

#pragma mark - 文本大小

-(CGSize)sizeWithString:(NSString *)string UIWidth:(CGFloat)width font:(UIFont*)font
{
    if (!string || !font) {
        return CGSizeZero;
    }
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                       options: NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: font}
                                       context:nil];
    
    return rect.size;
}

-(CGSize)sizeWithString:(NSString *)string UIHeight:(CGFloat)height font:(UIFont*)font
{
    if (!string || !font) {
        return CGSizeZero;
    }
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                       options: NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil];
    
    return rect.size;
}

#pragma mark - Loading

/**
 查找view中是否存在loadLayer

 @param view 显示loading的视图
 @return loadLayer
 */
-(CALayer*)findLoadLayerInView:(UIView*)view
{
    __block CALayer * loadLayer = nil;
    [[view.layer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"loadLayer"]) {
            loadLayer = obj;
            *stop = YES;
        }
    }];
    return loadLayer;
}

/**
 加载Loading

 @param view 显示loading的视图
 @return loadLayer
 */
-(CALayer*)showLoadInView:(UIView*)view
{
    [self hideLoadInView:view];
    
    CGFloat scale = BK_SCREENW / 320.0f;
    CGFloat prepare_layer_width = view.bounds.size.width/4.0f;
    CGFloat min_layer_width = 60 * scale;
    
    CGFloat loadLayer_width = prepare_layer_width < min_layer_width ? min_layer_width : prepare_layer_width;
    
    CALayer * loadLayer = [CALayer layer];
    loadLayer.bounds = CGRectMake(0, 0, loadLayer_width, loadLayer_width);
    loadLayer.position = CGPointMake(view.bk_width/2, view.bk_height/2);
    loadLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75f].CGColor;
    loadLayer.cornerRadius = loadLayer.bounds.size.width/10.0f;
    loadLayer.masksToBounds = YES;
    loadLayer.name = @"loadLayer";
    [view.layer addSublayer:loadLayer];
    
    NSTimeInterval beginTime = CACurrentMediaTime();
    
    for (int i = 0; i < 2; i++) {
        CALayer * circle = [CALayer layer];
        circle.bounds = CGRectMake(0, 0, loadLayer.bounds.size.width/2.0f, loadLayer.bounds.size.height/2.0f);
        circle.position = CGPointMake(loadLayer.bounds.size.width/2.0f, loadLayer.bounds.size.height/2.0f);
        circle.backgroundColor = [UIColor whiteColor].CGColor;
        circle.opacity = 0.6;
        circle.cornerRadius = CGRectGetHeight(circle.bounds) * 0.5;
        circle.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
        circle.name = @"loadCircleLayer";
        
        CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        animation.removedOnCompletion = NO;
        animation.repeatCount = MAXFLOAT;
        animation.duration = 1.5;
        animation.beginTime = beginTime - (0.75 * i);
        animation.keyTimes = @[@(0.0), @(0.5), @(1.0)];
        
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
        animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 0.0)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)]];
        
        [loadLayer addSublayer:circle];
        [circle addAnimation:animation forKey:@"loading_admin"];
    }
    
    return loadLayer;
}

/**
 加载Loading 带下载进度
 
 @param view 显示loading的视图
 @param progress 进度
 */
-(void)showLoadInView:(UIView*)view downLoadProgress:(CGFloat)progress
{
    CALayer * loadLayer = [self findLoadLayerInView:view];
    if (!loadLayer) {
        
        loadLayer = [self showLoadInView:view];
        [self createProgressTextLayerInSupperLayer:loadLayer downLoadProgress:progress];
        
    }else{
        
        __block BOOL isFindFlag = NO;
        [[loadLayer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name isEqualToString:@"loadTextLayer"]) {
                CATextLayer * textLayer = (CATextLayer*)obj;
                textLayer.string = [NSString stringWithFormat:@"iCloud同步\n%.0f%%",progress*100];
                isFindFlag = YES;
                *stop = YES;
            }
        }];
        
        if (isFindFlag == NO) {
            [self createProgressTextLayerInSupperLayer:loadLayer downLoadProgress:progress];
        }
    }
}

-(void)createProgressTextLayerInSupperLayer:(CALayer*)supperLayer downLoadProgress:(CGFloat)progress
{
    CGFloat scale = BK_SCREENW / 320.0f;
    
    UIFont * font = [UIFont systemFontOfSize:10.0 * scale];
    NSString * string = [NSString stringWithFormat:@"iCloud同步\n%.0f%%",progress*100];
    
    CGFloat height = [[BKTool sharedManager] sizeWithString:string UIWidth:supperLayer.frame.size.width font:font].height;
    
    CATextLayer * textLayer = [CATextLayer layer];
    textLayer.bounds = CGRectMake(0, 0, supperLayer.frame.size.width, height);
    textLayer.position = CGPointMake(supperLayer.frame.size.width/2, supperLayer.frame.size.height/2);
    textLayer.string = string;
    textLayer.wrapped = YES;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.foregroundColor = BKNavGrayTitleColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.name = @"loadTextLayer";
    [supperLayer addSublayer:textLayer];
    
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
}

/**
 隐藏Loading

 @param view 显示loading的视图
 */
-(void)hideLoadInView:(UIView*)view
{
    CALayer * loadLayer = [self findLoadLayerInView:view];
    if (!loadLayer) {
        return;
    }
    
    [[loadLayer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"loadCircleLayer"]) {
            [obj removeAnimationForKey:@"loading_admin"];
        }
    }];
    [loadLayer removeFromSuperlayer];
    loadLayer = nil;
}

#pragma mark - 图片路径

-(NSString*)imagePath
{
    if (!_imagePath) {
        NSString * imageBundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        _imagePath = [NSString stringWithFormat:@"%@",imageBundlePath];
    }
    return _imagePath;
}

/**
 基础模块图片
 
 @param imageName 图片名称
 @return 图片
 */
-(UIImage*)imageWithImageName:(NSString*)imageName
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.imagePath,imageName]];
}


/**
 编辑模块图片
 
 @param imageName 图片名称
 @return 图片
 */
-(UIImage*)editImageWithImageName:(NSString*)imageName
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/EditImage/%@",self.imagePath,imageName]];
}

/**
 拍照模块图片
 
 @param imageName 图片名称
 @return 图片
 */
-(UIImage*)takePhotoImageWithImageName:(NSString*)imageName
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/TakePhoto/%@",self.imagePath,imageName]];
}

#pragma mark - 压缩图片

/**
 压缩图片
 
 @param imageData 原图data
 @return 缩略图data
 */
-(NSData *)compressImageData:(NSData *)imageData
{
    if (!imageData) {
        return nil;
    }
       
    NSData * newImageData = [self compressImageWithData:imageData];
    return newImageData;
}

-(NSData *)compressImageWithData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    //创建 CGImageSourceRef
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data,
                                                               (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceShouldCache: @NO});
    if (!imageSource) {
        return nil;
    }
    
    CFStringRef imageSourceContainerType = CGImageSourceGetType(imageSource);
    //检测是否是GIF
    BOOL isGIFData = UTTypeConformsTo(imageSourceContainerType, kUTTypeGIF);
    //检测是否是PNG
    BOOL isPNGData = UTTypeConformsTo(imageSourceContainerType, kUTTypePNG);
   
    //图片数量
    size_t imageCount = CGImageSourceGetCount(imageSource);
    //保存图片地址
    NSString * saveImagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f.%@",[[NSDate date] timeIntervalSince1970],(isGIFData?@"gif":(isPNGData?@"png":@"jpg"))]];
    //创建图片写入
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:saveImagePath], isGIFData?kUTTypeGIF:(isPNGData?kUTTypePNG:kUTTypeJPEG), imageCount, NULL);
    //获取原图片属性
    NSDictionary * imageProperties = (__bridge NSDictionary *) CGImageSourceCopyProperties(imageSource, NULL);
    
    //遍历图片所有帧
    for (size_t i = 0; i < (isGIFData?imageCount:1); i++) {
        @autoreleasepool {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (imageRef) {
                //获取某一帧图片属性
                NSDictionary * frameProperties =
                (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
                
                CGImageRef compressImageRef = [self compressImageRef:imageRef];
                //写入图片
                CGImageDestinationAddImage(destinationRef, compressImageRef, (CFDictionaryRef)frameProperties);
                //写入图片属性
                CGImageDestinationSetProperties(destinationRef, (CFDictionaryRef)imageProperties);
                
                CGImageRelease(compressImageRef);
            }
            
            CGImageRelease(imageRef);
        }
    }
    //结束图片写入
    CGImageDestinationFinalize(destinationRef);
    
    CFRelease(destinationRef);
    CFRelease(imageSource);

    NSData * animatedImageData = [NSData dataWithContentsOfFile:saveImagePath];
    
    return animatedImageData;
}

//YYImage压缩图片方法
-(CGImageRef)compressImageRef:(CGImageRef)imageRef
{
    if (!imageRef) {
        return nil;
    }
    
    size_t width = floor(CGImageGetWidth(imageRef) * BKThumbImageCompressSizeMultiplier);
    size_t height = floor(CGImageGetHeight(imageRef) * BKThumbImageCompressSizeMultiplier);
    if (width == 0 || height == 0) {
        return nil;
    }
    
    CGFloat target_max_width = BK_SCREENW * [UIScreen mainScreen].scale;
    if (width > target_max_width) {
        height = target_max_width / width * height;
        width = target_max_width;
    }
    
    BOOL hasAlpha = [self checkHaveAlphaWithImageRef:imageRef];
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);
    if (!context) {
        return nil;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    CFRelease(context);
    
    return newImageRef;
}

-(BOOL)checkHaveAlphaWithImageRef:(CGImageRef)imageRef
{
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    
    return hasAlpha;
}

#pragma mark - 获取图片

/**
 获取对应缩略图
 
 @param asset 相片
 @param complete 完成方法
 */
-(void)getThumbImageWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * thumbImage))complete
{
    PHImageRequestOptions * thumbImageOptions = [[PHImageRequestOptions alloc] init];
    thumbImageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    thumbImageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    thumbImageOptions.synchronous = NO;
    thumbImageOptions.networkAccessAllowed = YES;
    
    [[BKTool sharedManager].cachingImageManager requestImageForAsset:asset targetSize:CGSizeMake(BK_SCREENW/2.0f, BK_SCREENW/2.0f) contentMode:PHImageContentModeAspectFill options:thumbImageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result);
            }
        });
    }];
}

/**
 获取对应原图
 
 @param asset 相片
 @param complete 完成方法
 */
-(void)getOriginalImageWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * originalImage))complete
{
    PHImageRequestOptions * originalImageOptions = [[PHImageRequestOptions alloc] init];
    originalImageOptions.version = PHImageRequestOptionsVersionOriginal;
    originalImageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    originalImageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    originalImageOptions.synchronous = NO;
    originalImageOptions.networkAccessAllowed = YES;
    
    [[BKTool sharedManager].cachingImageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:originalImageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
        BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downImageloadFinined) {
            if(result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(result);
                    }
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(nil);
                }
            });
        }
    }];
}

/**
 获取对应原图data
 
 @param asset 相片
 @param progressHandler 下载进度返回
 @param complete 完成方法
 */
-(void)getOriginalImageDataWithAsset:(PHAsset*)asset progressHandler:(void (^)(double progress, NSError * error, PHImageRequestID imageRequestID))progressHandler complete:(void (^)(NSData * originalImageData, NSURL * url, PHImageRequestID imageRequestID))complete
{
    PHImageRequestOptions * originalImageOptions = [[PHImageRequestOptions alloc] init];
    originalImageOptions.version = PHImageRequestOptionsVersionOriginal;
    originalImageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    originalImageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    originalImageOptions.synchronous = NO;
    originalImageOptions.networkAccessAllowed = YES;
    [originalImageOptions setProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PHImageRequestID imageRequestID = [info[PHImageResultRequestIDKey] intValue];
            if (progressHandler) {
                progressHandler(progress, error, imageRequestID);
            }
        });
    }];
    
    __block PHImageRequestID imageRequestID = [[BKTool sharedManager].cachingImageManager requestImageDataForAsset:asset options:originalImageOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        NSURL * url = info[@"PHImageFileURLKey"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(imageData, url, imageRequestID);
            }
        });
    }];
}

/**
 获取视频

 @param asset 相片
 @param progressHandler 下载进度返回
 @param complete 完成方法
 */
-(void)getVideoDataWithAsset:(PHAsset*)asset progressHandler:(void (^)(double progress, NSError * error, PHImageRequestID imageRequestID))progressHandler complete:(void (^)(AVPlayerItem * playerItem, PHImageRequestID imageRequestID))complete
{
    PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc]init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [options setProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PHImageRequestID imageRequestID = [info[PHImageResultRequestIDKey] intValue];
            if (progressHandler) {
                progressHandler(progress,error,imageRequestID);
            }
        });
    }];
    
    __block PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        AVPlayerItem * playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(playerItem, imageRequestID);
            }
        });
    }];
}

@end
