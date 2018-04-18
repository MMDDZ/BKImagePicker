//
//  ViewController.m
//  BKImagePicker
//
//  Created by BIKE on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "ViewController.h"
#import "BKImagePicker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, self.view.frame.size.height/4, self.view.frame.size.width, self.view.frame.size.height/4);
    [button setTitle:@"选择" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:20];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton * clip_button = [UIButton buttonWithType:UIButtonTypeCustom];
    clip_button.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, self.view.frame.size.height/4);
    [clip_button setTitle:@"裁剪选择" forState:UIControlStateNormal];
    [clip_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    clip_button.titleLabel.font = [UIFont systemFontOfSize:20];
    [clip_button addTarget:self action:@selector(clipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clip_button];
}

-(void)buttonClick
{
    [self showImagePickerView];
}

-(void)clipButtonClick
{
    [self showClipImagePickerView];
}

-(void)showImagePickerView
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BKImagePicker sharedManager] takePhotoWithComplete:^(UIImage *image, NSData *data) {
            NSLog(@"image:%@, dataLength:%ld",image,[data length]);
        }];
    }];
    [alert addAction:takePhoto];
    UIAlertAction * photoAlbum = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[BKImagePicker sharedManager] showPhotoAlbumWithTypePhoto:BKPhotoTypeDefault maxSelect:6 isHaveOriginal:YES complete:^(UIImage *image, NSData *data, NSURL *url, BKSelectPhotoType selectPhotoType) {
            NSLog(@"image:%@, dataLength:%ld, url:%@, selectPhotoType:%ld",image,[data length],url,selectPhotoType);
        }];
    }];
    [alert addAction:photoAlbum];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showClipImagePickerView
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BKImagePicker sharedManager] takePhotoWithImageClipSizeWidthToHeightRatio:1 complete:^(UIImage *image, NSData *data) {
            NSLog(@"image:%@, dataLength:%ld",image,[data length]);
        }];
    }];
    [alert addAction:takePhoto];
    UIAlertAction * photoAlbum = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[BKImagePicker sharedManager] showPhotoAlbumWithImageClipSizeWidthToHeightRatio:1 complete:^(UIImage *image, NSData *data) {
            NSLog(@"image:%@, dataLength:%ld",image,[data length]);
            [self showExampleImageWithImage:image];
        }];
    }];
    [alert addAction:photoAlbum];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)showExampleImageWithImage:(UIImage*)image
{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [self.view addSubview:imageView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imageView removeFromSuperview];
    });
}

@end
