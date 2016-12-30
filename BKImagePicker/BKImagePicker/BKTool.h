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

+(void)showRemind:(NSString*)text;

+(void)showLoadInView:(UIView*)view;

+(void)hideLoad;

+(NSString*)adaptLanguage:(NSString*)str;

@end
