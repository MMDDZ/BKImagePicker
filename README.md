# BKImagePicker

## 相册
    [[BKImagePicker sharedManager] showPhotoAlbumWithTypePhoto:(BKPhotoType) maxSelect:(NSInteger) isHaveOriginal:(BOOL) complete:^(UIImage *image, NSData *data, NSURL *url, BKSelectPhotoType selectPhotoType) {
        NSLog(@"image:%@, dataLength:%ld, url:%@, selectPhotoType:%ld",image,[data length],url,selectPhotoType);
    }];

## 拍照
    [[BKImagePicker sharedManager] takePhotoWithComplete:^(UIImage *image, NSData *data) {
        NSLog(@"image:%@, dataLength:%ld",image,[data length]);
    }];
    
## 版本
    1.0 图库第一版完成
    1.1 图库优化加载iCloud图片
