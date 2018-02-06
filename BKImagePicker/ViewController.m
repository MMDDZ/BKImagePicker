//
//  ViewController.m
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
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
    button.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [button setTitle:@"选择" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:20];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

-(void)buttonClick
{
    [self showImagePickerView];
}

-(void)showImagePickerView
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BKImagePicker sharedManager] takePhotoWithComplete:^(UIImage *image, NSData *data) {
            
        }];
    }];
    [alert addAction:takePhoto];
    UIAlertAction * photoAlbum = [UIAlertAction actionWithTitle:@"从相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[BKImagePicker sharedManager] showPhotoAlbumWithTypePhoto:BKPhotoTypeDefault maxSelect:6 complete:^(UIImage * image, NSData * data, NSURL * url, BKSelectPhotoType selectPhotoType) {
            NSLog(@"%@ , %ld , %@ , %ld",image,[data length],url,selectPhotoType);
        }];
    }];
    [alert addAction:photoAlbum];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
