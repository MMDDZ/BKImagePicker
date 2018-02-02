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

/**
 单例
 
 @return BKImagePicker
 */
+(instancetype)sharedManager;

/**
 所在VC

 @return VC
 */
-(UIViewController *)locationVC;

/**
 弹框
 
 @param title 标题
 @param message 内容
 @param actionTitleArr 按钮标题数组
 @param actionMethod 按钮标题数组对应点击事件
 */
-(void)presentAlert:(NSString*)title message:(NSString*)message actionTitleArr:(NSArray*)actionTitleArr actionMethod:(void (^)(NSInteger index))actionMethod;

/**
 提示

 @param text 文本
 */
-(void)showRemind:(NSString*)text;

/**
 加载Loading

 @param view 加载Loading
 */
-(void)showLoadInView:(UIView*)view;

/**
 隐藏Loading
 */
-(void)hideLoad;

/**
 压缩图片

 @param imageData 原图data
 @return 缩略图data
 */
-(NSData *)compressImageData:(NSData *)imageData;

@end
