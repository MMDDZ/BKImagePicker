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

@interface BKImagePicker ()

@end

@implementation BKImagePicker

-(void)takePhoto
{
    NSLog(@"1");
}

/**
 相册
 
 @param photoType 相册类型
 @param maxSelect 最大选择数 (最大999)
 @param complete  选择图片/GIF/视频
 */
+(void)showPhotoAlbumWithTypePhoto:(BKPhotoType)photoType maxSelect:(NSInteger)maxSelect complete:(void (^)(id result , BKSelectPhotoType selectPhotoType))complete
{
    [self checkAllowVisitPhotoAlbumHandler:^(BOOL handleFlag) {
        if (handleFlag) {
            BKImageClassViewController * imageClassVC = [[BKImageClassViewController alloc]init];
            imageClassVC.max_select = maxSelect>999?999:maxSelect;
            imageClassVC.photoType = photoType;
            imageClassVC.finishSelectOption = ^(id result , BKSelectPhotoType selectPhotoType){
                if (complete) {
                    complete(result,selectPhotoType);
                }
            };
            BKImagePickerViewController * imageVC = [[BKImagePickerViewController alloc]init];
            imageVC.max_select = maxSelect>999?999:maxSelect;
            imageVC.photoType = photoType;
            imageVC.finishSelectOption = ^(id result , BKSelectPhotoType selectPhotoType){
                if (complete) {
                    complete(result,selectPhotoType);
                }
            };
            
            imageClassVC.title = @"相册";
            imageVC.title = @"相机胶卷";
            
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:imageClassVC];
            nav.navigationBarHidden = YES;
            [nav pushViewController:imageVC animated:NO];
            [[BKTool locationVC] presentViewController:nav animated:YES completion:nil];
        }
    }];
}

/**
 检测是否允许调用相册

 @param handler 检测结果
 */
+(void)checkAllowVisitPhotoAlbumHandler:(void (^)(BOOL handleFlag))handler
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    if (handler) {
                        handler(YES);
                    }
                }else{
                    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"此应用程序没有权限访问您的相册\n在“设置-隐私-照片”中开启即可查看" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if (handler) {
                            handler(NO);
                        }
                    }];
                    [alert addAction:ok];
                    [[BKTool locationVC] presentViewController:alert animated:YES completion:nil];
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"此应用程序没有访问相册的权限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (handler) {
                    handler(NO);
                }
            }];
            [alert addAction:ok];
            [[BKTool locationVC] presentViewController:alert animated:YES completion:nil];
        }
            break;
        case PHAuthorizationStatusDenied:
        {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"此应用程序没有权限访问您的相册\n在“设置-隐私-照片”中开启即可查看" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (handler) {
                    handler(NO);
                }
            }];
            [alert addAction:ok];
            [[BKTool locationVC] presentViewController:alert animated:YES completion:nil];
        }
            break;
        case PHAuthorizationStatusAuthorized:
        {
            if (handler) {
                handler(YES);
            }
        }
            break;
        default:
            break;
    }
}

@end
