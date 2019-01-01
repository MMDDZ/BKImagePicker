//
//  BKImagePicker.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImagePicker.h"
#import "BKNavigationController.h"
#import "BKImagePickerMacro.h"
#import "BKImagePickerConstant.h"
#import "BKImageModel.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "BKImageAlbumListViewController.h"
#import "BKImagePickerViewController.h"
#import "BKCameraViewController.h"

@interface BKImagePicker ()

@property (nonatomic,strong) PHCachingImageManager * cachingImageManager;//图片缓存管理者

@property (nonatomic,strong) id observer;//通知观察者

@end

@implementation BKImagePicker

+ (instancetype)sharedManager
{
    static BKImagePicker * sharedManagerInstance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[BKImagePicker alloc] init];
    });
    
    return sharedManagerInstance;
}

/**
 初始化选项数据
 */
-(void)resetOptionData
{
    if (!self.imageManageModel) {
        self.imageManageModel = [[BKImageManageModel alloc] init];
    }
    self.imageManageModel.isHaveOriginal = NO;
    self.imageManageModel.max_select = 0;
    self.imageManageModel.selectImageArray = @[].mutableCopy;
    self.imageManageModel.isOriginal = NO;
    self.imageManageModel.photoType = BKPhotoTypeDefault;
    self.imageManageModel.clipSize_width_height_ratio = 0;
}

#pragma mark - 拍照

/**
 拍照
 
 @param complete 图片
 */
-(void)takePhotoWithComplete:(void (^)(UIImage * image, NSData * data))complete
{
    //初始化数据
    [self resetOptionData];
    
    [self skipTakePhotoVCWithComplete:^(UIImage *image, NSData *data) {
        if (complete) {
            complete(image,data);
        }
    }];
}

/**
 拍照 + 裁剪
 
 @param ratio 预定裁剪大小宽高比
 @param complete 图片
 */
-(void)takePhotoWithImageClipSizeWidthToHeightRatio:(CGFloat)ratio complete:(void (^)(UIImage *, NSData *))complete
{
    //初始化数据
    [self resetOptionData];
    self.imageManageModel.clipSize_width_height_ratio = ratio;
    
    [self skipTakePhotoVCWithComplete:^(UIImage *image, NSData *data) {
        if (complete) {
            complete(image,data);
        }
    }];
}

/**
 跳转拍照界面
 
 @param complete 完成方法
 */
-(void)skipTakePhotoVCWithComplete:(void (^)(UIImage * image, NSData * data))complete
{
    [self checkAllowVisitCameraHandler:^(BOOL handleFlag) {
        if (handleFlag) {
            
            UIViewController * lastVC = [self getCurrentVC];
            
            BKCameraViewController * vc = [[BKCameraViewController alloc]init];
            vc.cameraType = BKCameraTypeTakePhoto;
            BKNavigationController * nav = [[BKNavigationController alloc]initWithRootViewController:vc];
            [lastVC presentViewController:nav animated:YES completion:nil];
            
            self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:BKFinishTakePhotoNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                
                for (BKImageModel * model in self.imageManageModel.selectImageArray) {
                    if (complete) {
                        if (self.imageManageModel.isOriginal) {
                            complete([UIImage imageWithData:model.originalImageData], model.originalImageData);
                        }else{
                            complete([UIImage imageWithData:model.thumbImageData], model.thumbImageData);
                        }
                    }
                }
                
                [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
            }];
        }
    }];
}

/**
 录制视频 最大时间设置在常量文件里
 
 @param complete 录制完成
 */
-(void)recordVideoComplete:(void (^)(UIImage * image, NSData * data, NSURL * url))complete
{
    //初始化数据
    [self resetOptionData];
    
    [self checkAllowVisitCameraHandler:^(BOOL handleFlag) {
        if (handleFlag) {
            
            UIViewController * lastVC = [self getCurrentVC];
            
            BKCameraViewController * vc = [[BKCameraViewController alloc]init];
            vc.cameraType = BKCameraTypeRecordVideo;
            BKNavigationController * nav = [[BKNavigationController alloc]initWithRootViewController:vc];
            [lastVC presentViewController:nav animated:YES completion:nil];
            
            self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:BKFinishRecordVideoNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                
                BKImageModel * model = [self.imageManageModel.selectImageArray firstObject];
                if (complete) {
                    complete([UIImage imageWithData:model.originalImageData],[NSData dataWithContentsOfURL:model.url], model.url);
                }
                
                [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
            }];
        }
    }];
}

/**
 检测是否允许调用相机
 
 @param handler 检测结果
 */
- (void)checkAllowVisitCameraHandler:(void (^)(BOOL handleFlag))handler
{
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString * app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (handler) {
                            handler(YES);
                        }
                    });
                }else{
                    if (handler) {
                        handler(NO);
                    }
                    
                    [self bk_presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有权限访问您的相机\n在“设置-隐私-相机”中开启即可查看",app_Name] actionTitleArr:@[@"取消",@"去设置"] actionMethod:^(NSInteger index) {
                        if (index == 1) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    }];
                }
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        {
            if (handler) {
                handler(NO);
            }
            
            [self bk_presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有访问相机的权限",app_Name] actionTitleArr:@[@"确认"] actionMethod:^(NSInteger index) {
                
            }];
        }
            break;
        case AVAuthorizationStatusDenied:
        {
            if (handler) {
                handler(NO);
            }
            
            [self bk_presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有权限访问您的相机\n在“设置-隐私-相机”中开启即可查看",app_Name] actionTitleArr:@[@"取消",@"去设置"] actionMethod:^(NSInteger index) {
                if (index == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
        }
            break;
        case AVAuthorizationStatusAuthorized:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(YES);
                }
            });
        }
            break;
        default:
            break;
    }
}

#pragma mark - 相册

/**
 相册
 
 @param photoType 相册类型
 @param maxSelect 最大选择数 (最大999)
 @param isHaveOriginal 是否有原图选项
 @param complete  选择图片/GIF/视频
 */
-(void)showPhotoAlbumWithTypePhoto:(BKPhotoType)photoType maxSelect:(NSInteger)maxSelect isHaveOriginal:(BOOL)isHaveOriginal complete:(void (^)(UIImage * image, NSData * data, NSURL * url, BKSelectPhotoType selectPhotoType))complete
{
    //初始化数据
    [self resetOptionData];
    
    self.imageManageModel.isHaveOriginal = isHaveOriginal;
    self.imageManageModel.max_select = maxSelect>999?999:maxSelect;
    self.imageManageModel.photoType = photoType;
    
    [self skipPhotoAlbumVCWithComplete:^(UIImage *image, NSData *data, NSURL *url, BKSelectPhotoType selectPhotoType) {
        if (complete) {
            complete(image,data,url,selectPhotoType);
        }
    }];
}

/**
 相册 + 裁剪
 最大选择数:1 没有原图选项 只有图片选择（没有gif）
 
 @param ratio 预定裁剪大小宽高比
 @param complete 图片
 */
-(void)showPhotoAlbumWithImageClipSizeWidthToHeightRatio:(CGFloat)ratio complete:(void (^)(UIImage *, NSData *))complete
{
    //初始化数据
    [self resetOptionData];
    
    self.imageManageModel.isHaveOriginal = NO;
    self.imageManageModel.max_select = 1;
    self.imageManageModel.photoType = BKPhotoTypeImage;
    self.imageManageModel.clipSize_width_height_ratio = ratio;
    
    [self skipPhotoAlbumVCWithComplete:^(UIImage *image, NSData *data, NSURL *url, BKSelectPhotoType selectPhotoType) {
        if (complete) {
            complete(image,data);
        }
    }];
}

-(void)skipPhotoAlbumVCWithComplete:(void (^)(UIImage * image, NSData * data, NSURL * url, BKSelectPhotoType selectPhotoType))complete
{
    [self checkAllowVisitPhotoAlbumHandler:^(BOOL handleFlag) {
        if (handleFlag) {
            
            UIViewController * lastVC = [self getCurrentVC];
            
            __block NSString * albumName = @"";
            //系统的相簿
            PHFetchResult * smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            [smartAlbums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PHAssetCollection *collection = obj;
                
                // 获取所有资源的集合按照创建时间倒序排列
                PHFetchOptions * fetchOptions = [[PHFetchOptions alloc] init];
                fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d || mediaType = %d",PHAssetMediaTypeImage,PHAssetMediaTypeVideo];
                
                PHFetchResult<PHAsset *> *assets  = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
                
                if ([assets count] > 0) {
                    albumName = collection.localizedTitle;
                    *stop = YES;
                }
            }];
            
            BKImageAlbumListViewController * imageClassVC = [[BKImageAlbumListViewController alloc]init];
            
            BKImagePickerViewController * imageVC = [[BKImagePickerViewController alloc]init];
            
            imageClassVC.title = @"相册";
            imageVC.title = albumName;
            
            self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:BKFinishSelectImageNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                
                if ([self.imageManageModel.selectImageArray count] == 1) {
                    BKImageModel * model = [self.imageManageModel.selectImageArray firstObject];
                    if (model.photoType != BKSelectPhotoTypeVideo) {
                        if (complete) {
                            if (self.imageManageModel.isOriginal) {
                                complete([UIImage imageWithData:model.originalImageData], model.originalImageData, model.url, model.photoType);
                            }else{
                                complete([UIImage imageWithData:model.thumbImageData], model.thumbImageData, model.url, model.photoType);
                            }
                        }
                    }else{
                        if (complete) {
                            complete([UIImage imageWithData:model.originalImageData], [NSData dataWithContentsOfURL:model.url], model.url, model.photoType);
                        }
                    }
                }else{
                    for (BKImageModel * model in self.imageManageModel.selectImageArray) {
                        if (complete) {
                            if (self.imageManageModel.isOriginal) {
                                complete([UIImage imageWithData:model.originalImageData], model.originalImageData, model.url, model.photoType);
                            }else{
                                complete([UIImage imageWithData:model.thumbImageData], model.thumbImageData, model.url, model.photoType);
                            }
                        }
                    }
                }
                
                [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
            }];
            
            BKNavigationController * nav = [[BKNavigationController alloc]initWithRootViewController:imageClassVC];
            [nav pushViewController:imageVC animated:NO];
            nav.popVC = imageClassVC;
            [lastVC presentViewController:nav animated:YES completion:nil];
        }
    }];
}

/**
 检测是否允许调用相册
 
 @param handler 检测结果
 */
-(void)checkAllowVisitPhotoAlbumHandler:(void (^)(BOOL handleFlag))handler
{
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString * app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (handler) {
                            handler(YES);
                        }
                    });
                }else{
                    if (handler) {
                        handler(NO);
                    }
                    
                    [self bk_presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有权限访问您的相册\n在“设置-隐私-照片”中开启即可查看",app_Name] actionTitleArr:@[@"确认",@"去设置"] actionMethod:^(NSInteger index) {
                        if (index == 1) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    }];
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        {
            if (handler) {
                handler(NO);
            }
            
            [self bk_presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有访问相册的权限",app_Name] actionTitleArr:@[@"确认"] actionMethod:^(NSInteger index) {
                
            }];
        }
            break;
        case PHAuthorizationStatusDenied:
        {
            if (handler) {
                handler(NO);
            }
            
            [self bk_presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有权限访问您的相册\n在“设置-隐私-照片”中开启即可查看",app_Name] actionTitleArr:@[@"确认",@"去设置"] actionMethod:^(NSInteger index) {
                if (index == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(YES);
                }
            });
        }
            break;
        default:
            break;
    }
}

#pragma mark - 保存图片

/**
 保存图片
 
 @param image 图片
 @param complete 保存完成方法
 */
- (void)saveImage:(UIImage*)image complete:(void (^)(PHAsset * asset,BOOL success))complete
{
    [self checkAllowVisitPhotoAlbumHandler:^(BOOL handleFlag) {
        if (handleFlag) {
            
            __block NSString *assetId = nil;
            //存储图片到"相机胶卷"
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                assetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (complete) {
                            complete(nil,success);
                        }
                    });
                    return;
                }
                
                //把相机胶卷图片保存到自己创建的相册中
                //图片
                PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                //自己的相册
                PHAssetCollection *collection = [self collection];
                //转移
                [self asset:asset transferToCsCollection:collection complete:^(PHAsset *asset, BOOL success) {
                    if (complete) {
                        complete(asset,success);
                    }
                }];
            }];
            
        }
    }];
}

/**
 保存视频

 @param videoPath 本地视频路径
 @param complete 保存完成方法
 */
-(void)saveVideo:(NSString*)videoPath complete:(void (^)(PHAsset * asset,BOOL success))complete
{
    [self checkAllowVisitPhotoAlbumHandler:^(BOOL handleFlag) {
        if (handleFlag) {
            
            __block NSString *assetId = nil;
            //存储视频到"相机胶卷"
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                assetId = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:videoPath]].placeholderForCreatedAsset.localIdentifier;
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (complete) {
                            complete(nil,success);
                        }
                    });
                    return;
                }
                
                //把相机胶卷视频保存到自己创建的相册中
                //视频
                PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                //自己的相册
                PHAssetCollection * collection = [self collection];
                //转移
                [self asset:asset transferToCsCollection:collection complete:^(PHAsset *asset, BOOL success) {
                    if (complete) {
                        complete(asset,success);
                    }
                }];
            }];
        }
    }];
}

/**
 把资源转移到特定的相册中

 @param asset 资源
 @param collection 相册
 @param complete 完成方法
 */
-(void)asset:(PHAsset *)asset transferToCsCollection:(PHAssetCollection *)collection complete:(void (^)(PHAsset * asset,BOOL success))complete
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest * request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
        [request addAssets:@[asset]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(asset,success);
            }
        });
    }];
}

/**
 获取保存图片、视频相册
 
 @return 保存图片、视频相册
 */
- (PHAssetCollection *)collection
{
    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString * app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
    // 先获得之前创建过的相册
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:app_Name]) {
            return collection;
        }
    }
    
    // 如果相册不存在,就创建新的相册(文件夹)
    __block NSString *collectionId = nil; // __block修改block外部的变量的值
    // 这个方法会在相册创建完毕后才会返回
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:app_Name].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}

#pragma mark - 获取图片

-(PHCachingImageManager*)cachingImageManager
{
    if (!_cachingImageManager) {
        _cachingImageManager = [[PHCachingImageManager alloc] init];
    }
    return _cachingImageManager;
}

/**
 获取对应缩略图
 
 @param asset 相片
 @param complete 完成方法
 */
-(void)getThumbImageWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * thumbImage))complete
{
    PHImageRequestOptions * thumbImageOptions = [[PHImageRequestOptions alloc] init];
    thumbImageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
    thumbImageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    thumbImageOptions.synchronous = NO;
    thumbImageOptions.networkAccessAllowed = YES;
    
    [self.cachingImageManager requestImageForAsset:asset targetSize:CGSizeMake(BK_SCREENW/2.0f, BK_SCREENW/2.0f) contentMode:PHImageContentModeAspectFill options:thumbImageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(result);
            }
        });
    }];
}

/**
 获取对应原图
 
 @param asset 相片
 @param complete 完成方法
 */
-(void)getOriginalImageWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * originalImage))complete
{
    PHImageRequestOptions * originalImageOptions = [[PHImageRequestOptions alloc] init];
    originalImageOptions.version = PHImageRequestOptionsVersionOriginal;
    originalImageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    originalImageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    originalImageOptions.synchronous = NO;
    originalImageOptions.networkAccessAllowed = YES;
    
    [self.cachingImageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:originalImageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
        BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downImageloadFinined) {
            if(result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(result);
                    }
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(nil);
                }
            });
        }
    }];
}

/**
 获取对应原图data
 
 @param asset 相片
 @param progressHandler 下载进度返回
 @param complete 完成方法
 */
-(void)getOriginalImageDataWithAsset:(PHAsset*)asset progressHandler:(void (^)(double progress, NSError * error, PHImageRequestID imageRequestID))progressHandler complete:(void (^)(NSData * originalImageData, NSURL * url, PHImageRequestID imageRequestID))complete
{
    PHImageRequestOptions * originalImageOptions = [[PHImageRequestOptions alloc] init];
    originalImageOptions.version = PHImageRequestOptionsVersionOriginal;
    originalImageOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    originalImageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    originalImageOptions.synchronous = NO;
    originalImageOptions.networkAccessAllowed = YES;
    [originalImageOptions setProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PHImageRequestID imageRequestID = [info[PHImageResultRequestIDKey] intValue];
            if (progressHandler) {
                progressHandler(progress, error, imageRequestID);
            }
        });
    }];
    
    __block PHImageRequestID imageRequestID = [self.cachingImageManager requestImageDataForAsset:asset options:originalImageOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        NSURL * url = info[@"PHImageFileURLKey"];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(imageData, url, imageRequestID);
            }
        });
    }];
}

/**
 获取视频
 
 @param asset 相片
 @param progressHandler 下载进度返回
 @param complete 完成方法
 */
-(void)getVideoDataWithAsset:(PHAsset*)asset progressHandler:(void (^)(double progress, NSError * error, PHImageRequestID imageRequestID))progressHandler complete:(void (^)(AVPlayerItem * playerItem, PHImageRequestID imageRequestID))complete
{
    PHVideoRequestOptions * options = [[PHVideoRequestOptions alloc]init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [options setProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            PHImageRequestID imageRequestID = [info[PHImageResultRequestIDKey] intValue];
            if (progressHandler) {
                progressHandler(progress,error,imageRequestID);
            }
        });
    }];
    
    __block PHImageRequestID imageRequestID = [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        AVPlayerItem * playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(playerItem, imageRequestID);
            }
        });
    }];
}

#pragma mark - 压缩图片

/**
 压缩图片
 
 @param imageData 原图data
 @return 缩略图data
 */
-(NSData *)compressImageData:(NSData *)imageData
{
    if (!imageData) {
        return nil;
    }
    
    NSData * newImageData = [self compressImageWithData:imageData];
    return newImageData;
}

-(NSData *)compressImageWithData:(NSData *)data
{
    if (!data) {
        return nil;
    }
    //创建 CGImageSourceRef
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data,
                                                               (__bridge CFDictionaryRef)@{(NSString *)kCGImageSourceShouldCache: @NO});
    if (!imageSource) {
        return nil;
    }
    
    CFStringRef imageSourceContainerType = CGImageSourceGetType(imageSource);
    //检测是否是GIF
    BOOL isGIFData = UTTypeConformsTo(imageSourceContainerType, kUTTypeGIF);
    //检测是否是PNG
    BOOL isPNGData = UTTypeConformsTo(imageSourceContainerType, kUTTypePNG);
    
    //图片数量
    size_t imageCount = CGImageSourceGetCount(imageSource);
    //保存图片地址
    NSString * saveImagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%.0f.%@",[[NSDate date] timeIntervalSince1970],(isGIFData?@"gif":(isPNGData?@"png":@"jpg"))]];
    //创建图片写入
    CGImageDestinationRef destinationRef = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:saveImagePath], isGIFData?kUTTypeGIF:(isPNGData?kUTTypePNG:kUTTypeJPEG), imageCount, NULL);
    //获取原图片属性
    NSDictionary * imageProperties = (__bridge NSDictionary *) CGImageSourceCopyProperties(imageSource, NULL);
    
    //遍历图片所有帧
    for (size_t i = 0; i < (isGIFData?imageCount:1); i++) {
        @autoreleasepool {
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
            if (imageRef) {
                //获取某一帧图片属性
                NSDictionary * frameProperties =
                (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(imageSource, i, NULL);
                
                CGImageRef compressImageRef = [self compressImageRef:imageRef];
                //写入图片
                CGImageDestinationAddImage(destinationRef, compressImageRef, (CFDictionaryRef)frameProperties);
                //写入图片属性
                CGImageDestinationSetProperties(destinationRef, (CFDictionaryRef)imageProperties);
                
                CGImageRelease(compressImageRef);
            }
            
            CGImageRelease(imageRef);
        }
    }
    //结束图片写入
    CGImageDestinationFinalize(destinationRef);
    
    CFRelease(destinationRef);
    CFRelease(imageSource);
    
    NSData * animatedImageData = [NSData dataWithContentsOfFile:saveImagePath];
    
    return animatedImageData;
}

//YYImage压缩图片方法
-(CGImageRef)compressImageRef:(CGImageRef)imageRef
{
    if (!imageRef) {
        return nil;
    }
    
    size_t width = floor(CGImageGetWidth(imageRef) * BKThumbImageCompressSizeMultiplier);
    size_t height = floor(CGImageGetHeight(imageRef) * BKThumbImageCompressSizeMultiplier);
    if (width == 0 || height == 0) {
        return nil;
    }
    
    CGFloat target_max_width = BK_SCREENW * [UIScreen mainScreen].scale;
    if (width > target_max_width) {
        height = target_max_width / width * height;
        width = target_max_width;
    }
    
    BOOL hasAlpha = [self checkHaveAlphaWithImageRef:imageRef];
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
    bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);
    if (!context) {
        return nil;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    CFRelease(context);
    
    return newImageRef;
}

#pragma mark - 查看图片是否含有alpha

/**
 查看图片是否含有alpha
 
 @param imageRef imageRef
 @return 结果
 */
-(BOOL)checkHaveAlphaWithImageRef:(CGImageRef)imageRef
{
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
    
    BOOL hasAlpha = NO;
    if (alphaInfo == kCGImageAlphaPremultipliedLast ||
        alphaInfo == kCGImageAlphaPremultipliedFirst ||
        alphaInfo == kCGImageAlphaLast ||
        alphaInfo == kCGImageAlphaFirst) {
        hasAlpha = YES;
    }
    
    return hasAlpha;
}

#pragma mark - 获取当前屏幕显示的viewcontroller

-(UIViewController *)getCurrentVC
{
    UIViewController *rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    
    UIViewController *parent = rootVC;
    
    while ((parent = rootVC.presentedViewController) != nil ) {
        rootVC = parent;
    }
    
    while ([rootVC isKindOfClass:[UINavigationController class]]) {
        rootVC = [(UINavigationController *)rootVC topViewController];
    }
    
    return rootVC;
}

#pragma mark - 弹框提示

/**
 弹框
 
 @param title 标题
 @param message 内容
 @param actionTitleArr 按钮标题数组
 @param actionMethod 按钮标题数组对应点击事件
 */
-(void)bk_presentAlert:(NSString*)title message:(NSString*)message actionTitleArr:(NSArray*)actionTitleArr actionMethod:(void (^)(NSInteger index))actionMethod
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    for (NSString * title in actionTitleArr) {
        
        NSInteger style;
        if ([title isEqualToString:@"取消"]) {
            style = UIAlertActionStyleCancel;
        }else{
            style = UIAlertActionStyleDefault;
        }
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
            if (actionMethod) {
                actionMethod([actionTitleArr indexOfObject:title]);
            }
        }];
        [alert addAction:action];
    }
    [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
}

@end
