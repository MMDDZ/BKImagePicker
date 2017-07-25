//
//  BKImageCropView.m
//  BKImagePicker
//
//  Created by 兆林 on 2017/7/24.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKImageCropView.h"
#import "BKImagePickerConst.h"

@interface BKImageCropView()

@property (nonatomic,strong) UIImage * editImage;
@property (nonatomic,strong) UIImageView * editImageView;

@end

@implementation BKImageCropView

-(instancetype)initWithImage:(UIImage*)editImage
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        self.editImage = editImage;
        
        [self addSubview:self.editImageView];
        
        //yes 为宽大于高  no 为高大于宽
        __block BOOL flag = YES;
        if (self.editImage.size.width < self.editImage.size.height) {
            flag = NO;
        }
        [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
           
            self.editImage = [self rotationImage:self.editImage orientation:UIImageOrientationLeft];
            
            CGFloat scale = 1;
            if (flag) {
                scale = _editImageView.bk_height/_editImageView.bk_width;
            }else{
                scale = _editImageView.bk_width/_editImageView.bk_height;
            }
            
            flag = !flag;
            
            [UIView animateWithDuration:0.3 animations:^{
                _editImageView.transform = CGAffineTransformScale(_editImageView.transform, scale, scale);
                _editImageView.transform = CGAffineTransformRotate (_editImageView.transform, - M_PI_2);
            }completion:^(BOOL finished) {
                _editImageView.transform = CGAffineTransformMakeRotation(0);
                _editImageView.transform = CGAffineTransformMakeScale(1, 1);
                _editImageView.image = self.editImage;
            }];
            
        }];
        
    }
    return self;
}

#pragma mark - 图片

-(UIImageView*)editImageView
{
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 30, UISCREEN_WIDTH - 20, UISCREEN_HEIGHT - 140)];
        _editImageView.image = _editImage;
        _editImageView.clipsToBounds = YES;
        _editImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _editImageView;
}

-(UIImage *)rotationImage:(UIImage *)image orientation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate =M_PI_2;
            rect =CGRectMake(0,0,image.size.height, image.size.width);
            translateX=0;
            translateY= -rect.size.width;
            scaleY =rect.size.width/rect.size.height;
            scaleX =rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate =3 *M_PI_2;
            rect =CGRectMake(0,0,image.size.height, image.size.width);
            translateX= -rect.size.height;
            translateY=0;
            scaleY =rect.size.width/rect.size.height;
            scaleX =rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate =M_PI;
            rect =CGRectMake(0,0,image.size.width, image.size.height);
            translateX= -rect.size.width;
            translateY= -rect.size.height;
            break;
        default:
            rotate =0.0;
            rect =CGRectMake(0,0,image.size.width, image.size.height);
            translateX=0;
            translateY=0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX,translateY);
    
    CGContextScaleCTM(context, scaleX,scaleY);
    
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return newImage;
}

@end
