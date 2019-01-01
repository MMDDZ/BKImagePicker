//
//  BKImageAlbumListModel.h
//  BKImagePicker
//
//  Created by BIKE on 2018/2/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BKImageAlbumListModel : NSObject

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
