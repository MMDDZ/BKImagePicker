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
    BKPhotoTypeImage,
    BKPhotoTypeVideo,
    BKPhotoTypeGIF,
    BKPhotoTypeGIFAndImage,
    BKPhotoTypeVideoAndImage,
    BKPhotoTypeVideoAndGIF
};

typedef NS_ENUM(NSInteger,BKSelectPhotoType) {
    BKSelectPhotoTypeImage = 0,
    BKSelectPhotoTypeGIF,
    BKSelectPhotoTypeVideo,
};

@interface BKImagePicker : NSObject

-(void)takePhoto;

+(void)showPhotoAlbumWithTypePhoto:(BKPhotoType)photoType maxSelect:(NSInteger)maxSelect complete:(void (^)(NSArray * imageArray , BKSelectPhotoType selectPhotoType))complete;

@end
