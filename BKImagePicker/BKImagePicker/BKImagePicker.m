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

+(UIViewController *)vc
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    UIViewController * vc;
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        vc = nextResponder;
    }else {
        vc = window.rootViewController;
    }
    
    return vc;
}

-(void)takePhoto
{
    NSLog(@"1");
}

+(void)showPhotoAlbumWithTypePhoto:(BKPhotoType)photoType maxSelect:(NSInteger)maxSelect complete:(void (^)(NSArray * imageArray))complete
{
    [self checkAllowVisitPhotoAlbumHandler:^(BOOL handleFlag) {
        if (handleFlag) {
            BKImageClassViewController * imageClassVC = [[BKImageClassViewController alloc]init];
            imageClassVC.max_select = maxSelect;
            BKImagePickerViewController * imageVC = [[BKImagePickerViewController alloc]init];
            imageVC.max_select = maxSelect;
            
            NSDictionary * info_dic = [[NSBundle mainBundle] infoDictionary];
            NSString * info_language = info_dic[@"CFBundleDevelopmentRegion"];
            if ([info_language rangeOfString:@"zh"].location != NSNotFound) {
                imageClassVC.title = @"相册";
                imageVC.title = @"相机胶卷";
            }else{
                imageClassVC.title = @"Albums";
                imageVC.title = @"Camera Roll";
            }
            
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:imageClassVC];
            [nav pushViewController:imageVC animated:NO];
            [self.vc presentViewController:nav animated:YES completion:nil];
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
                    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if (handler) {
                            handler(NO);
                        }
                    }];
                    [alert addAction:ok];
                    [self.vc presentViewController:alert animated:YES completion:nil];
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"此应用程序没有访问相册的权限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (handler) {
                    handler(NO);
                }
            }];
            [alert addAction:ok];
            [self.vc presentViewController:alert animated:YES completion:nil];
        }
            break;
        case PHAuthorizationStatusDenied:
        {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"此应用程序没有权限访问您的相册\n在“设置-隐私-照片”中开启即可查看" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (handler) {
                    handler(NO);
                }
            }];
            [alert addAction:ok];
            [self.vc presentViewController:alert animated:YES completion:nil];
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
