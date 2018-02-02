//
//  BKImagePicker.m
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePicker.h"
#import <Photos/Photos.h>
#import "BKImageClassViewController.h"
#import "BKImagePickerViewController.h"
#import "BKImageTakePhotoViewController.h"

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

#pragma mark - 拍照

-(void)takePhotoWithComplete:(void (^)(UIImage *, NSData *))complete
{
    [self checkAllowVisitCameraHandler:^(BOOL handleFlag) {
        if (handleFlag) {
            
            UIViewController * lastVC = [[BKTool sharedManager] locationVC];
            
            BKImageTakePhotoViewController * vc = [[BKImageTakePhotoViewController alloc]init];
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:vc];
            nav.navigationBarHidden = YES;
            [lastVC presentViewController:nav animated:YES completion:nil];
            
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
 @param complete  选择图片/GIF/视频
 */
-(void)showPhotoAlbumWithTypePhoto:(BKPhotoType)photoType maxSelect:(NSInteger)maxSelect complete:(void (^)(UIImage * image , NSData * data , NSURL * url , BKSelectPhotoType selectPhotoType))complete
{
    [self checkAllowVisitPhotoAlbumHandler:^(BOOL handleFlag) {
        if (handleFlag) {
            
            UIViewController * lastVC = [[BKTool sharedManager] locationVC];
            
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
            
            BKImageClassViewController * imageClassVC = [[BKImageClassViewController alloc]init];
            imageClassVC.max_select = maxSelect>999?999:maxSelect;
            imageClassVC.photoType = photoType;
          
            BKImagePickerViewController * imageVC = [[BKImagePickerViewController alloc]init];
            imageVC.max_select = maxSelect>999?999:maxSelect;
            imageVC.photoType = photoType;
          
            imageClassVC.title = @"相册";
            imageVC.title = albumName;
            
            __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:BKFinishSelectImageNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                
                NSDictionary * userInfo = note.userInfo;
                
                if ([userInfo[@"object"] isKindOfClass:[NSArray class]]) {
                    NSArray * selectImageArray = userInfo[@"object"];
                    BOOL isOriginal = [userInfo[@"isOriginal"] boolValue];
                    for (BKImageModel * model in selectImageArray) {
                        if (complete) {
                            if (isOriginal) {
                                complete([UIImage imageWithData:model.originalImageData], model.originalImageData, model.url, model.photoType);
                            }else{
                                complete([UIImage imageWithData:model.thumbImageData], model.thumbImageData, model.url, model.photoType);
                            }
                        }
                    }
                }else{
                    BKImageModel * model = userInfo[@"object"];
                    if (model.photoType != BKSelectPhotoTypeVideo) {
                        BOOL isOriginal = [userInfo[@"isOriginal"] boolValue];
                        if (complete) {
                            if (isOriginal) {
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
                }
                
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
            }];
            
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:imageClassVC];
            nav.navigationBarHidden = YES;
            [nav pushViewController:imageVC animated:NO];
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
 */
- (void)saveImage:(UIImage*)image
{
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    [[BKTool sharedManager] showLoadInView:window];
    
    [self checkAllowVisitPhotoAlbumHandler:^(BOOL handleFlag) {
        if (handleFlag) {
         
            __block NSString *assetId = nil;
            // 存储图片到"相机胶卷"
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[BKTool sharedManager] hideLoad];
                        [[BKTool sharedManager] showRemind:@"图片保存失败"];
                    });
                    return;
                }
                
                // 把相机胶卷图片保存到自己创建的相册中
                PHAssetCollection *collection = [self collection];
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                    
                    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                    [request addAssets:@[asset]];
                    
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[BKTool sharedManager] hideLoad];
                        
                        if (error) {
                            [[BKTool sharedManager] showRemind:@"图片保存失败"];
                            return;
                        }
                        
                        [[BKTool sharedManager] showRemind:@"保存成功"];
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
