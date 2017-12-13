//
//  BKTool.m
//  BKImagePicker
//
//  Created by iMac on 16/10/19.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKTool.h"
#import "BKImagePickerConst.h"

@interface BKTool()

@property (nonatomic,strong) CALayer * loadLayer;

@end

@implementation BKTool

+(instancetype)sharedManager
{
    static BKTool * shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[BKTool alloc]init];
    });
    return shareInstance;
}

/**
 所在VC
 
 @return VC
 */
-(UIViewController *)locationVC
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

-(CGSize)sizeWithString:(NSString *)string UIWidth:(CGFloat)width font:(UIFont*)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                       options: NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: font}
                                       context:nil];
    
    return rect.size;
}

-(CGSize)sizeWithString:(NSString *)string UIHeight:(CGFloat)height font:(UIFont*)font
{
    CGRect rect = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                       options: NSStringDrawingUsesFontLeading  |NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName:font}
                                       context:nil];
    
    return rect.size;
}

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
    
    NSData * lastImageData = [self calculateSizeAndCreateImageData:imageData];
    while (lastImageData.length > 200*1024) {
        lastImageData = [self calculateSizeAndCreateImageData:lastImageData];
    }
    
    return lastImageData;
}

-(NSData*)calculateSizeAndCreateImageData:(NSData*)imageData
{
    UIImage * image = [UIImage imageWithData:imageData];
    UIImage *newImage;
    
    if (image.size.width > image.size.height) {
        if (image.size.width < 1000) {
            newImage = image;
        }else{
            newImage = [self compressImage:image];
        }
    }else{
        if (image.size.height < 1500) {
            newImage = image;
        }else{
            newImage = [self compressImage:image];
        }
    }
    
    NSData * newImageData = UIImageJPEGRepresentation(newImage, BKThumbImageCompressSizeMultiplier);
    return newImageData;
}

-(UIImage*)compressImage:(UIImage*)image
{
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    
    float width = imageWidth*BKThumbImageCompressSizeMultiplier;
    float height = imageHeight*BKThumbImageCompressSizeMultiplier;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width , height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
