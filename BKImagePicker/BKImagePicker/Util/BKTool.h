//
//  BKTool.h
//  BKImagePicker
//
//  Created by iMac on 16/10/19.
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

//工具栏背景颜色
#define BKNavBackgroundColor [UIColor colorWithWhite:1 alpha:0.8]
//所有线的颜色
#define BKLineColor [UIColor colorWithWhite:0.85 alpha:1]
//高亮颜色
#define BKHighlightColor BK_HEX_RGB(0x2D96FA)
//导航字体默认颜色
#define BKNavGrayTitleColor [UIColor colorWithWhite:0.5 alpha:1]
//发送按钮默认颜色
#define BKNavSendGrayBackgroundColor [UIColor colorWithWhite:0.8 alpha:1]
//选择照片时 选择按钮默认颜色
#define BKSelectImageCircleNormalColor [UIColor colorWithWhite:0.2 alpha:0.5]

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
 加载Loading

 @param view 加载Loading
 */
-(void)showLoadInView:(UIView*)view;

/**
 隐藏Loading
 */
-(void)hideLoad;

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
 
 @param asset 相簿
 @param complete 完成方法
 */
-(void)getThumbImageSizeWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * thumbImage))complete;
/**
 获取对应原图
 
 @param asset 相簿
 @param complete 完成方法
 */
-(void)getOriginalImageSizeWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * originalImage))complete;
/**
 获取对应原图data
 
 @param asset 相簿
 @param complete 完成方法
 */
-(void)getOriginalImageDataSizeWithAsset:(PHAsset*)asset complete:(void (^)(NSData * originalImageData,NSURL * url))complete;

@end
