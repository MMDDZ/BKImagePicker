//
//  BKImageManageModel.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <Foundation/Foundation.h>
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

@interface BKImageManageModel : NSObject

#pragma mark - 图库+拍照

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
 预定裁剪大小宽高比
 */
@property (nonatomic,assign) CGFloat clipSize_width_height_ratio;

#pragma mark - 录制视频



@end
