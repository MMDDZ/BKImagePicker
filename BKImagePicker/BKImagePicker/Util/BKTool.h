//
//  BKTool.h
//  BKImagePicker
//
//  Created by BIKE on 16/10/19.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "BKImageNavViewController.h"

#import "UIView+BKImagePicker.h"
#import "NSObject+BKImagePicker.h"
#import "UIImage+BKImagePicker.h"
#import "UIBezierPath+BKImagePicker.h"

typedef NS_ENUM(NSInteger,BKPhotoType) {
    BKPhotoTypeDefault = 0,
    BKPhotoTypeImageAndGif,
    BKPhotoTypeImageAndVideo,
    BKPhotoTypeImage
};

typedef NS_ENUM(NSInteger,BKSelectPhotoType) {
    BKSelectPhotoTypeImage = 0,
    BKSelectPhotoTypeGIF,
    BKSelectPhotoTypeVideo,
};

#define BK_RGBA(R,G,B,A) [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:A]
#define BK_HEX_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//导航背景颜色
#define BKNavBackgroundColor [UIColor colorWithWhite:1 alpha:0.8]
//导航字体默认颜色
#define BKNavGrayTitleColor [UIColor colorWithWhite:0.5 alpha:1]
//所有线的颜色
#define BKLineColor [UIColor colorWithWhite:0.85 alpha:1]
//选择按钮默认颜色
#define BKSelectNormalColor [UIColor colorWithWhite:0.2 alpha:0.5]
//高亮颜色
#define BKHighlightColor BK_HEX_RGB(0x2D96FA)
//发送按钮默认颜色
#define BKNavSendGrayBackgroundColor [UIColor colorWithWhite:0.8 alpha:1]

#define BK_SCREENW [UIScreen mainScreen].bounds.size.width
#define BK_SCREENH [UIScreen mainScreen].bounds.size.height

#define BK_POINTS_FROM_PIXELS(__PIXELS) (__PIXELS / [[UIScreen mainScreen] scale])
#define BK_ONE_PIXEL BK_POINTS_FROM_PIXELS(1.0)

#define BK_WEAK_SELF(obj) __weak typeof(obj) weakSelf = obj;
#define BK_STRONG_SELF(obj) __strong typeof(obj) strongSelf = weakSelf;

#define BK_IPONEX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define BK_SYSTEM_STATUSBAR_HEIGHT (BK_IPONEX ? 44.f : 20.f)
#define BK_SYSTEM_NAV_HEIGHT BK_SYSTEM_STATUSBAR_HEIGHT + 44.f
#define BK_SYSTEM_NAV_UI_HEIGHT 44.f
#define BK_SYSTEM_TABBAR_HEIGHT (BK_IPONEX ? 83.f : 49.f)
#define BK_SYSTEM_TABBAR_UI_HEIGHT 49.f

UIKIT_EXTERN NSString * const BKFinishTakePhotoNotification;
UIKIT_EXTERN NSString * const BKFinishSelectImageNotification;

UIKIT_EXTERN const float BKAlbumImagesSpacing;
UIKIT_EXTERN const float BKExampleImagesSpacing;
UIKIT_EXTERN const float BKCheckExampleImageAnimateTime;
UIKIT_EXTERN const float BKCheckExampleGifAndVideoAnimateTime;
UIKIT_EXTERN const float BKThumbImageCompressSizeMultiplier;

@interface BKTool : NSObject

/**
 是否有原图按钮
 */
@property (nonatomic,assign) BOOL isHaveOriginal;
/**
 最大选取量
 */
@property (nonatomic,assign) NSInteger max_select;
/**
 选取的数组
 */
@property (nonatomic,strong) NSMutableArray * selectImageArray;
/**
 是否选择原图
 */
@property (nonatomic,assign) BOOL isOriginal;
/**
 相册显示类型
 */
@property (nonatomic,assign) BKPhotoType photoType;
/**
 预定裁剪大小宽高比
 */
@property (nonatomic,assign) CGFloat clipSize_width_height_ratio;

/**
 单例

 @return BKTool
 */
+(instancetype)sharedManager;

#pragma mark - 获取当前屏幕显示的viewcontroller

/**
 所在VC

 @return VC
 */
-(UIViewController *)getCurrentVC;

#pragma mark - 弹框提示

/**
 弹框
 
 @param title 标题
 @param message 内容
 @param actionTitleArr 按钮标题数组
 @param actionMethod 按钮标题数组对应点击事件
 */
-(void)presentAlert:(NSString*)title message:(NSString*)message actionTitleArr:(NSArray*)actionTitleArr actionMethod:(void (^)(NSInteger index))actionMethod;

#pragma mark - 提示

/**
 提示

 @param text 文本
 */
-(void)showRemind:(NSString*)text;

#pragma mark - 文本大小

-(CGSize)sizeWithString:(NSString *)string UIWidth:(CGFloat)width font:(UIFont*)font;
-(CGSize)sizeWithString:(NSString *)string UIHeight:(CGFloat)height font:(UIFont*)font;

#pragma mark - Loading

/**
 查找view中是否存在loadLayer
 
 @param view 显示loading的视图
 @return loadLayer
 */
-(CALayer*)findLoadLayerInView:(UIView*)view;

/**
 加载Loading
 
 @param view 显示loading的视图
 @return loadLayer
 */
-(CALayer*)showLoadInView:(UIView*)view;

/**
 加载Loading 带下载进度
 
 @param view 显示loading的视图
 @param progress 进度
 */
-(void)showLoadInView:(UIView*)view downLoadProgress:(CGFloat)progress;

/**
 隐藏Loading
 
 @param view 显示loading的视图
 */
-(void)hideLoadInView:(UIView*)view;

#pragma mark - 图片路径

/**
 基础模块图片
 
 @param imageName 图片名称
 @return 图片
 */
-(UIImage*)imageWithImageName:(NSString*)imageName;

/**
 编辑模块图片
 
 @param imageName 图片名称
 @return 图片
 */
-(UIImage*)editImageWithImageName:(NSString*)imageName;

/**
 拍照模块图片
 
 @param imageName 图片名称
 @return 图片
 */
-(UIImage*)takePhotoImageWithImageName:(NSString*)imageName;

#pragma mark - 压缩图片

/**
 压缩图片

 @param imageData 原图data
 @return 缩略图data
 */
-(NSData *)compressImageData:(NSData *)imageData;

/**
 查看图片是否含有alpha

 @param imageRef imageRef
 @return 结果
 */
-(BOOL)checkHaveAlphaWithImageRef:(CGImageRef)imageRef;

#pragma mark - 获取图片

/**
 获取对应缩略图
 
 @param asset 相片
 @param complete 完成方法
 */
-(void)getThumbImageWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * thumbImage))complete;
/**
 获取对应原图
 
 @param asset 相片
 @param complete 完成方法
 */
-(void)getOriginalImageWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * originalImage))complete;
/**
 获取对应原图data
 
 @param asset 相片
 @param progressHandler 下载进度返回
 @param complete 完成方法
 */
-(void)getOriginalImageDataWithAsset:(PHAsset*)asset progressHandler:(void (^)(double progress, NSError * error, PHImageRequestID imageRequestID))progressHandler complete:(void (^)(NSData * originalImageData, NSURL * url, PHImageRequestID imageRequestID))complete;
/**
 获取视频
 
 @param asset 相片
 @param progressHandler 下载进度返回
 @param complete 完成方法
 */
-(void)getVideoDataWithAsset:(PHAsset*)asset progressHandler:(void (^)(double progress, NSError * error, PHImageRequestID imageRequestID))progressHandler complete:(void (^)(AVPlayerItem * playerItem, PHImageRequestID imageRequestID))complete;

@end
