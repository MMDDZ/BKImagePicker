//
//  BKTool.h
//  BKImagePicker
//
//  Created by iMac on 16/10/19.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BKTool : NSObject

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

@end
