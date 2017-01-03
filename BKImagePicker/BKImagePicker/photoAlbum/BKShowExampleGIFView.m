//
//  BKShowExampleGIFView.m
//  BKImagePicker
//
//  Created by 毕珂 on 16/11/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKShowExampleGIFView.h"
#import "FLAnimatedImage.h"
#import "BKImagePickerConst.h"

@interface BKShowExampleGIFView()

@property (nonatomic ,strong) UIView * currentView;

@property (nonatomic ,strong) UIView * bottomView;

@property (nonatomic ,strong) PHAsset * asset;

@property (nonatomic ,strong) UIImage * selectImage;

@end

@implementation BKShowExampleGIFView

-(UIView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bk_height - 64, self.bk_width, 64)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.5];
        
        UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.frame = CGRectMake(10, 0, 64, 64);
        [back setBackgroundColor:[UIColor clearColor]];
        [back setTitle:@"取消" forState:UIControlStateNormal];
        [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        back.titleLabel.font = [UIFont systemFontOfSize:16];
        [back addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:back];
        
        UIButton * select = [UIButton buttonWithType:UIButtonTypeCustom];
        select.frame = CGRectMake(self.bk_width - 64 - 10, 0, 64, 64);
        [select setBackgroundColor:[UIColor clearColor]];
        [select setTitle:@"选取" forState:UIControlStateNormal];
        [select setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        select.titleLabel.font = [UIFont systemFontOfSize:16];
        [select addTarget:self action:@selector(selectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:select];
    }
    return _bottomView;
}

-(void)backBtnClick
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    CGRect currentRect = self.currentView.frame;
    CGRect selfRect = self.frame;
    currentRect.origin.x = 0;
    selfRect.origin.x = self.bk_width;
    
    [UIView animateWithDuration:BKCheckExampleGifAndVideoAnimateTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.currentView.frame = currentRect;
        self.frame = selfRect;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

-(void)selectBtnClick
{
    if (self.finishSelectOption) {
        self.finishSelectOption(self.selectImage,BKSelectPhotoTypeGIF);
    }
}

-(instancetype)initWithAsset:(PHAsset*)asset
{
    self = [super initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    if (self) {
        
        self.asset = asset;
        
        self.backgroundColor = [UIColor blackColor];
        
        [self initGIFImageView];
    }
    return self;
}

-(void)initGIFImageView
{
    [self requestGIFImageHandler:^(UIImage * image , NSString * urlStr) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.selectImage = image;
            
            CGSize size = [FLAnimatedImage sizeForImage:image];
            FLAnimatedImage * gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:urlStr]];
            FLAnimatedImageView *gifImageView = [[FLAnimatedImageView alloc] init];
            gifImageView.animatedImage = gifImage;
            gifImageView.frame = CGRectMake((self.bk_width - size.width)/2.0f, (self.bk_height - size.height)/2.0f, size.width, size.height);
            [self addSubview:gifImageView];
            
            [self addSubview:[self bottomView]];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self animateShow];
            });
        });
    }];
}

-(void)requestGIFImageHandler:(void (^)(UIImage * image , NSString * urlStr))handler
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageForAsset:self.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
        BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downImageloadFinined) {
            if(result)
            {
                if (handler) {
                    handler(result,info[@"PHImageFileURLKey"]);
                }
            }
        }
    }];
}

-(void)showInVC:(UIViewController*)vc
{
    self.currentView = vc.navigationController.view;
    [[self.currentView superview] addSubview:self];
}

-(void)animateShow
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    CGRect currentRect = self.currentView.frame;
    CGRect selfRect = self.frame;
    currentRect.origin.x = -self.bk_width/2.0f;
    selfRect.origin.x = 0;
    
    [UIView animateWithDuration:BKCheckExampleGifAndVideoAnimateTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.currentView.frame = currentRect;
        self.frame = selfRect;
        
    } completion:^(BOOL finished) {
        
    }];
}

@end
