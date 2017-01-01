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

+(UIViewController *)locationVC;

+(void)showRemind:(NSString*)text;

+(void)showLoadInView:(UIView*)view;

+(void)hideLoad;

+(UIImage *)compressImage:(UIImage *)image;

@end
