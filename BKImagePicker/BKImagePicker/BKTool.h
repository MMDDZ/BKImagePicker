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
