//
//  BKImagePicker.m
//  BKImagePicker
//
//  Created by BIKE on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePicker.h"
#import <Photos/Photos.h>
#import "BKPhotoAlbumListViewController.h"
#import "BKImagePickerViewController.h"
#import "BKImageTakePhotoViewController.h"
#import "BKImageModel.h"

@interface BKImagePicker ()

@end

@implementation BKImagePicker

static BKImagePicker * sharedManagerInstance = nil;
+ (instancetype)sharedManager
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    
    return sharedManagerInstance;
}

/**
 初始化选项数据
 */
-(void)resetOptionData
{
    [BKTool sharedManager].isHaveOriginal = NO;
    [BKTool sharedManager].max_select = 0;
    [BKTool sharedManager].selectImageArray = @[].mutableCopy;
    [BKTool sharedManager].isOriginal = NO;
    [BKTool sharedManager].photoType = BKPhotoTypeDefault;
    [BKTool sharedManager].clipSize_width_height_ratio = 0;
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
    [BKTool sharedManager].clipSize_width_height_ratio = ratio;
    
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
            
            UIViewController * lastVC = [[BKTool sharedManager] getCurrentVC];
            
            BKImageTakePhotoViewController * vc = [[BKImageTakePhotoViewController alloc]init];
            BKImageNavViewController * nav = [[BKImageNavViewController alloc]initWithRootViewController:vc];
            [lastVC presentViewController:nav animated:YES completion:nil];
            
            __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:BKFinishTakePhotoNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                
                for (BKImageModel * model in [BKTool sharedManager].selectImageArray) {
                    if (complete) {
                        if ([BKTool sharedManager].isOriginal) {
                            complete([UIImage imageWithData:model.originalImageData], model.originalImageData);
                        }else{
                            complete([UIImage imageWithData:model.thumbImageData], model.thumbImageData);
                        }
                    }
                }
                
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
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
                    
                    [[BKTool sharedManager] presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有权限访问您的相机\n在“设置-隐私-相机”中开启即可查看",app_Name] actionTitleArr:@[@"取消",@"去设置"] actionMethod:^(NSInteger index) {
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
            
            [[BKTool sharedManager] presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有访问相机的权限",app_Name] actionTitleArr:@[@"确认"] actionMethod:^(NSInteger index) {
                
            }];
        }
            break;
        case AVAuthorizationStatusDenied:
        {
            if (handler) {
                handler(NO);
            }
            
            [[BKTool sharedManager] presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有权限访问您的相机\n在“设置-隐私-相机”中开启即可查看",app_Name] actionTitleArr:@[@"取消",@"去设置"] actionMethod:^(NSInteger index) {
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
    
    [BKTool sharedManager].isHaveOriginal = isHaveOriginal;
    [BKTool sharedManager].max_select = maxSelect>999?999:maxSelect;
    [BKTool sharedManager].photoType = photoType;
    
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
    
    [BKTool sharedManager].isHaveOriginal = NO;
    [BKTool sharedManager].max_select = 1;
    [BKTool sharedManager].photoType = BKPhotoTypeImage;
    [BKTool sharedManager].clipSize_width_height_ratio = ratio;
    
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
            
            UIViewController * lastVC = [[BKTool sharedManager] getCurrentVC];
            
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
            
            BKPhotoAlbumListViewController * imageClassVC = [[BKPhotoAlbumListViewController alloc]init];
            
            BKImagePickerViewController * imageVC = [[BKImagePickerViewController alloc]init];
            
            imageClassVC.title = @"相册";
            imageVC.title = albumName;
            
            __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:BKFinishSelectImageNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                
                if ([[BKTool sharedManager].selectImageArray count] == 1) {
                    BKImageModel * model = [[BKTool sharedManager].selectImageArray firstObject];
                    if (model.photoType != BKSelectPhotoTypeVideo) {
                        if (complete) {
                            if ([BKTool sharedManager].isOriginal) {
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
                    for (BKImageModel * model in [BKTool sharedManager].selectImageArray) {
                        if (complete) {
                            if ([BKTool sharedManager].isOriginal) {
                                complete([UIImage imageWithData:model.originalImageData], model.originalImageData, model.url, model.photoType);
                            }else{
                                complete([UIImage imageWithData:model.thumbImageData], model.thumbImageData, model.url, model.photoType);
                            }
                        }
                    }
                }
                
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
            }];
            
            BKImageNavViewController * nav = [[BKImageNavViewController alloc]initWithRootViewController:imageClassVC];
            [nav pushViewController:imageVC animated:NO];
            nav.customTransition.backVC = imageClassVC;
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
                    
                    [[BKTool sharedManager] presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有权限访问您的相册\n在“设置-隐私-照片”中开启即可查看",app_Name] actionTitleArr:@[@"确认",@"去设置"] actionMethod:^(NSInteger index) {
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
            
            [[BKTool sharedManager] presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有访问相册的权限",app_Name] actionTitleArr:@[@"确认"] actionMethod:^(NSInteger index) {
                
            }];
        }
            break;
        case PHAuthorizationStatusDenied:
        {
            if (handler) {
                handler(NO);
            }
            
            [[BKTool sharedManager] presentAlert:@"提示" message:[NSString stringWithFormat:@"%@没有权限访问您的相册\n在“设置-隐私-照片”中开启即可查看",app_Name] actionTitleArr:@[@"确认",@"去设置"] actionMethod:^(NSInteger index) {
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
            // 存储图片到"相机胶卷"
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (complete) {
                            complete(nil,success);
                        }
                    });
                    return;
                }
                
                PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                
                // 把相机胶卷图片保存到自己创建的相册中
                PHAssetCollection *collection = [self collection];
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
            }];
            
        }
    }];
}

/**
 获取保存图片相册
 
 @return 保存图片相册
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



@end
