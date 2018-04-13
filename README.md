# BKImagePicker

## 相册
    [[BKImagePicker sharedManager] showPhotoAlbumWithTypePhoto:(BKPhotoType) maxSelect:(NSInteger) isHaveOriginal:(BOOL) complete:^(UIImage *image, NSData *data, NSURL *url, BKSelectPhotoType selectPhotoType) {
        NSLog(@"image:%@, dataLength:%ld, url:%@, selectPhotoType:%ld",image,[data length],url,selectPhotoType);
    }];

## 拍照
    [[BKImagePicker sharedManager] takePhotoWithComplete:^(UIImage *image, NSData *data) {
        NSLog(@"image:%@, dataLength:%ld",image,[data length]);
    }];
