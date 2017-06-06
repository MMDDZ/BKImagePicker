//
//  BKImageClassModel.h
//  BKImagePicker
//
//  Created by 兆林 on 2017/6/6.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BKImageClassModel : NSObject

/**
 相册名字
 */
@property (nonatomic,copy) NSString * albumName;
/**
 相册图片数量
 */
@property (nonatomic,assign) NSInteger albumImageCount;
/**
 相册中第一张图片
 */
@property (nonatomic,strong) UIImage * albumFirstImage;

@end
