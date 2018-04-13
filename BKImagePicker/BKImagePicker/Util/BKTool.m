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

NSString * const BKFinishSelectImageNotification = @"BKFinishSelectImageNotification";//选择完成通知

float const BKAlbumImagesSpacing = 1;//相簿图片间距
float const BKExampleImagesSpacing = 10;//查看的大图图片间距
float const BKCheckExampleImageAnimateTime = 0.5;//查看大图图片过场动画时间
float const BKCheckExampleGifAndVideoAnimateTime = 0.3;//查看Gif、Video过场动画时间
float const BKThumbImageCompressSizeMultiplier = 0.5;//图片压缩比例

@interface BKTool()

@property (nonatomic,strong) CALayer * loadLayer;//加载layer

@property (nonatomic,copy) NSString * imagePath;//图片路径

@property (nonatomic,strong) PHCachingImageManager * cachingImageManager;//图片缓存管理者
@property (nonatomic,strong) PHImageRequestOptions * thumbImageOptions;//缩略图请求选项
@property (nonatomic,strong) PHImageRequestOptions * originalImageOptions;//原图请求选项

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
 加载Loading
 
 @param view 加载Loading
 */
-(void)showLoadInView:(UIView*)view
{
    if (self.loadLayer) {
        [self hideLoad];
    }
    
    CALayer * loadLayer = [CALayer layer];
    loadLayer.bounds = CGRectMake(0, 0, view.bounds.size.width/4.0f, view.bounds.size.width/4.0f);
    loadLayer.position = view.center;
    loadLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75f].CGColor;
    loadLayer.cornerRadius = loadLayer.bounds.size.width/10.0f;
    loadLayer.masksToBounds = YES;
    [view.layer addSublayer:loadLayer];
    
    self.loadLayer = loadLayer;
    
    NSTimeInterval beginTime = CACurrentMediaTime();
    
    for (int i = 0; i < 2; i++) {
        CALayer * circle = [CALayer layer];
        circle.bounds = CGRectMake(0, 0, loadLayer.bounds.size.width/2.0f, loadLayer.bounds.size.height/2.0f);
        circle.position = CGPointMake(loadLayer.bounds.size.width/2.0f, loadLayer.bounds.size.height/2.0f);
        circle.backgroundColor = [UIColor whiteColor].CGColor;
        circle.opacity = 0.6;
        circle.cornerRadius = CGRectGetHeight(circle.bounds) * 0.5;
        circle.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
        
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
}

/**
 隐藏Loading
 */
-(void)hideLoad
{
    [[self.loadLayer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeAnimationForKey:@"loading_admin"];
    }];
    [self.loadLayer removeFromSuperlayer];
    self.loadLayer = nil;
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
    
    if (imageData.length < 200*1024) {
        return imageData;
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

-(PHImageRequestOptions*)thumbImageOptions
{
    if (!_thumbImageOptions) {
        _thumbImageOptions = [[PHImageRequestOptions alloc] init];
        _thumbImageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        _thumbImageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _thumbImageOptions.synchronous = NO;
        _thumbImageOptions.networkAccessAllowed = YES;
    }
    return _thumbImageOptions;
}

/**
 获取对应缩略图
 
 @param asset 相簿
 @param complete 完成方法
 */
-(void)getThumbImageSizeWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * thumbImage))complete
{
    [[BKTool sharedManager].cachingImageManager requestImageForAsset:asset targetSize:CGSizeMake(BK_SCREENW/2.0f, BK_SCREENW/2.0f) contentMode:PHImageContentModeDefault options:self.thumbImageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
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
        }
    }];
}

-(PHImageRequestOptions*)originalImageOptions
{
    if (!_originalImageOptions) {
        _originalImageOptions = [[PHImageRequestOptions alloc] init];
        _originalImageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        _originalImageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        _originalImageOptions.synchronous = NO;
        _originalImageOptions.networkAccessAllowed = YES;
    }
    return _originalImageOptions;
}

/**
 获取对应原图
 
 @param asset 相簿
 @param complete 完成方法
 */
-(void)getOriginalImageSizeWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * originalImage))complete
{
    [[BKTool sharedManager].cachingImageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:self.originalImageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
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
        }
    }];
}

/**
 获取对应原图data
 
 @param asset 相簿
 @param complete 完成方法
 */
-(void)getOriginalImageDataSizeWithAsset:(PHAsset*)asset complete:(void (^)(NSData * originalImageData,NSURL * url))complete
{
    [[BKTool sharedManager].cachingImageManager requestImageDataForAsset:asset options:self.originalImageOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        NSURL * url = info[@"PHImageFileURLKey"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(imageData,url);
            }
        });
    }];
}

@end
