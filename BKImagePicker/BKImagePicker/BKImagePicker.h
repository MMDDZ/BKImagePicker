//
//  BKImagePicker.h
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@interface BKImagePicker : NSObject

-(void)takePhoto;

+(void)showPhotoAlbumWithTypePhoto:(BKPhotoType)photoType maxSelect:(NSInteger)maxSelect complete:(void (^)(NSArray * imageArray , BKSelectPhotoType selectPhotoType))complete;

/**
 检测是否允许调用相册
 
 @param handler 检测结果
 */
+(void)checkAllowVisitPhotoAlbumHandler:(void (^)(BOOL handleFlag))handler;

@end
