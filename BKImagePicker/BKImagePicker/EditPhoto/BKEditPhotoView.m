//
//  BKEditPhotoView.m
//  BKImagePicker
//
//  Created by iMac on 17/1/18.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKEditPhotoView.h"
#import "BKEditGradientView.h"
#import "BKImagePickerConst.h"
#import <Photos/Photos.h>
#import "BKImagePicker.h"
#import "BKDrawView.h"
#import "BKSelectColorView.h"
#import "UIImage+BKOrientationExpand.h"

@interface BKEditPhotoView()<BKSelectColorViewDelegate,BKDrawViewDelegate>

@property (nonatomic,strong) BKEditGradientView * topView;
@property (nonatomic,strong) BKEditGradientView * bottomView;

@property (nonatomic,strong) UIButton * selectEditBtn;

/**
 要修改的图片
 */
@property (nonatomic,strong) UIImage * editImage;
@property (nonatomic,strong) UIImageView * editImageView;
/**
 全图马赛克处理
 */
@property (nonatomic,strong) UIImage * mosaicImage;
@property (nonatomic,strong) CIContext * context;

/**
 是否正在绘画中
 */
@property (nonatomic,assign) BOOL isDrawingFlag;
/**
 停止绘画后倒计时时间（5s）
 */
@property (nonatomic,assign) NSInteger afterDrawTime;
/**
 倒计时定时器
 */
@property (nonatomic,strong) NSTimer * drawTimer;

/**
 画图(包括线、圆角矩形、圆、箭头)
 */
@property (nonatomic,strong) BKDrawView * drawView;
/**
 颜色选取
 */
@property (nonatomic,strong) BKSelectColorView * selectColorView;

@end

@implementation BKEditPhotoView

#pragma mark - init

-(instancetype)initWithImage:(UIImage*)image
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        
        self.editImage = [image editImageOrientation];
        
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.editImageView];
        
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        
        [self addSubview:self.selectColorView];
        
        [self addObserver:self forKeyPath:@"isDrawingFlag" options:NSKeyValueObservingOptionNew context:nil];
        _drawTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(drawThingsTimer) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)drawThingsTimer
{
    self.afterDrawTime = self.afterDrawTime - 1;
    if (self.afterDrawTime == 0) {
        self.isDrawingFlag = NO;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"isDrawingFlag"]) {
        if ([change[@"new"] boolValue]) {
            
            [UIView animateWithDuration:0.25 animations:^{
                _topView.alpha = 0;
                _bottomView.alpha = 0;
                _selectColorView.alpha = 0;
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            }];
        }else{
            [UIView animateWithDuration:0.25 animations:^{
                _topView.alpha = 1;
                _bottomView.alpha = 1;
                _selectColorView.alpha = 1;
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            }];
        }
    }
}

-(void)cancelThings
{
    [self removeObserver:self forKeyPath:@"isDrawingFlag"];
    [_drawTimer invalidate];
    _drawTimer = nil;
}

-(UIImageView*)editImageView
{
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc]initWithFrame:[self calculataImageRect]];
        _editImageView.image = self.editImage;
    }
    return _editImageView;
}

#pragma mark - 算imageView 的 rect

-(CGRect)calculataImageRect
{
    CGRect imageRect = CGRectZero;
    
    CGFloat scale = self.editImage.size.width / self.bk_width;
    CGFloat height = self.editImage.size.height / scale;
    
    if (height > self.bk_height) {
        imageRect.size.height = self.bk_height;
        scale = self.editImage.size.height / self.bk_height;
        imageRect.size.width = self.editImage.size.width / scale;
        imageRect.origin.x = (self.bk_width - imageRect.size.width) / 2.0f;
        imageRect.origin.y = 0;
    }else{
        imageRect.size.height = height;
        imageRect.size.width = self.bk_width;
        imageRect.origin.x = 0;
        imageRect.origin.y = (self.bk_height - imageRect.size.height) / 2.0f;
    }
    
    return imageRect;
}

#pragma mark - topView

-(BKEditGradientView*)topView
{
    if (!_topView) {
        _topView = [[BKEditGradientView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, 64) topColor:[UIColor colorWithWhite:0.2 alpha:0.5] bottomColor:[UIColor colorWithWhite:0 alpha:0]];
        
        UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 20, 64, 44);
        [backBtn setTitle:@"取消" forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:backBtn];
        
        UIButton * saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        saveBtn.frame = CGRectMake(_topView.bk_width - 64, 20, 64, 40);
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        [saveBtn setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/save_n.png"]] forState:UIControlStateNormal];
        [saveBtn setImage:[UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/save_s.png"]] forState:UIControlStateHighlighted];
        [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:saveBtn];
    }
    return _topView;
}

-(void)backBtnClick
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self cancelThings];
    [self removeFromSuperview];
}

/**
 保存图片
 */
-(void)saveBtnClick
{
    [BKImagePicker saveImage:self.editImage];
}

#pragma mark - bottomView

-(BKEditGradientView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[BKEditGradientView alloc]initWithFrame:CGRectMake(0, self.bk_height - 64, self.bk_width, 64) topColor:[UIColor colorWithWhite:0 alpha:0] bottomColor:[UIColor colorWithWhite:0.2 alpha:0.5]];
        
        UIScrollView * itemsView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width/4*3 - 6, _bottomView.bk_height)];
        itemsView.backgroundColor = [UIColor clearColor];
        itemsView.showsVerticalScrollIndicator = NO;
        [_bottomView addSubview:itemsView];
        
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        NSArray * imageArr_n = @[[bundlePath stringByAppendingString:@"/draw_n.png"],[bundlePath stringByAppendingString:@"/rounded_rectangle_n.png"],[bundlePath stringByAppendingString:@"/circle_n.png"],[bundlePath stringByAppendingString:@"/arrow_n.png"],[bundlePath stringByAppendingString:@"/rotation_n.png"],[bundlePath stringByAppendingString:@"/write_n.png"],[bundlePath stringByAppendingString:@"/clip_n.png"],[bundlePath stringByAppendingString:@"/filter_n.png"]];
        NSArray * imageArr_s = @[[bundlePath stringByAppendingString:@"/draw_s.png"],[bundlePath stringByAppendingString:@"/rounded_rectangle_s.png"],[bundlePath stringByAppendingString:@"/circle_s.png"],[bundlePath stringByAppendingString:@"/arrow_s.png"],[bundlePath stringByAppendingString:@"/rotation_s.png"],[bundlePath stringByAppendingString:@"/write_s.png"],[bundlePath stringByAppendingString:@"/clip_s.png"],[bundlePath stringByAppendingString:@"/filter_s.png"]];
        
        __block UIView * lastView;
        [imageArr_n enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, 64);
            [button setImage:[UIImage imageWithContentsOfFile:obj] forState:UIControlStateNormal];
            [button setImage:[UIImage imageWithContentsOfFile:imageArr_s[idx]] forState:UIControlStateHighlighted];
            [button setImage:[UIImage imageWithContentsOfFile:imageArr_s[idx]] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = idx;
            [itemsView addSubview:button];
            
            if (idx == 0) {
                [self editBtnClick:button];
            }
            
            lastView = button;
        }];
        itemsView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), itemsView.bk_height);
        
        UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(self.bk_width/4*3, (_bottomView.bk_height - 37)/2, self.bk_width/4-6, 37);
        [sendBtn setTitle:@"确认" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn setBackgroundColor:BKNavHighlightTitleColor];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        sendBtn.layer.cornerRadius = 4;
        sendBtn.clipsToBounds = YES;
        [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:sendBtn];
    }
    return _bottomView;
}

#pragma mark - 底部按钮

-(void)editBtnClick:(UIButton*)button
{
    if (self.selectEditBtn == button) {
        return;
    }
    
    self.selectEditBtn.selected = NO;
    self.selectEditBtn = button;
    self.selectEditBtn.selected = YES;
    
    switch (button.tag) {
        case 0:
        {
            [self checkDrawViewExist];
            _drawView.drawType = BKDrawTypeLine;
        }
            break;
        case 1:
        {
            [self checkDrawViewExist];
            _drawView.drawType = BKDrawTypeRoundedRectangle;
        }
            break;
        case 2:
        {
            [self checkDrawViewExist];
            _drawView.drawType = BKDrawTypeCircle;
        }
            break;
        case 3:
        {
            [self checkDrawViewExist];
            _drawView.drawType = BKDrawTypeArrow;
        }
            break;
        default:
            break;
    }
}

-(void)checkDrawViewExist
{
    if (![[self subviews] containsObject:_drawView]) {
        [self insertSubview:self.drawView aboveSubview:self.editImageView];
    }
}

-(void)sendBtnClick
{
    
}

#pragma mark - 画画

-(BKDrawView*)drawView
{
    if (!_drawView) {
        _drawView = [[BKDrawView alloc]initWithFrame:self.editImageView.frame];
    }
    return _drawView;
}

#pragma mark - BKDrawViewDelegate

/**
 滑动中
 */
-(void)movedOption
{
    self.isDrawingFlag = YES;
    self.afterDrawTime = 5;
}

/**
 滑动结束
 */
-(void)moveEndOption
{
    if (self.isDrawingFlag) {
        self.afterDrawTime = 5;
    }else {
        self.isDrawingFlag = YES;
    }
}

-(CIContext*)context
{
    if (!_context) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

//#pragma mark - 马赛克图片
//
//-(void)getMosaicImage
//{
//    CIImage *ciImage = [CIImage imageWithCGImage:self.editImage.CGImage];
//    //生成马赛克
//    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
//    [filter setValue:ciImage forKey:kCIInputImageKey];
//    //马赛克像素大小
//    [filter setValue:@(50) forKey:kCIInputScaleKey];
//    CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
//
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CGImageRef cgImage = [context createCGImage:outImage fromRect:CGRectMake(0, 0, self.editImage.size.width, self.editImage.size.height)];
//    self.mosaicImage = [UIImage imageWithCGImage:cgImage];
//    CGImageRelease(cgImage);
//}

/**
 马赛克处理
 
 @param pointArr 点数组
 */
-(void)processingMosaicImageWithPathArr:(NSArray*)pointArr
{
//    CGFloat radius = 5;
//    CIImage * maskImage;
//    for (int i = 0; i < [pointArr count]; i++) {
//        CGPoint point = CGPointFromString([NSString stringWithFormat:@"%@",pointArr[i]]);
//        CIFilter * radialGradient = [CIFilter filterWithName:@"CIRadialGradient" withInputParameters:@{@"inputRadius0":@(radius), @"inputRadius1" : @(radius + 1), @"inputColor0" : [CIColor colorWithRed:0 green:1 blue:0 alpha:1], @"inputColor1" : [CIColor colorWithRed:0 green:0 blue:0 alpha:0], kCIInputCenterKey : [CIVector vectorWithX:point.x Y:point.y]}];
//        
//        CIImage * radialGradientOutputImage = [radialGradient.outputImage imageByCroppingToRect:<#(CGRect)#>];
//        if (!maskImage) {
//            maskImage = radialGradientOutputImage;
//        }else{
//            maskImage = [CIFilter filterWithName:@"CISourceOverCompositing" withInputParameters:@{kCIInputImageKey : radialGradientOutputImage, kCIInputBackgroundImageKey : maskImage}].outputImage;
//        }
//        
//        CIFilter * blendFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
//        [blendFilter setValue:fullPixellatedImage forKey:kCIInputImageKey];
//        [blendFilter setValue:inputImage forKey:kCIInputBackgroundImageKey];
//        [blendFilter setValue:maskImage forKey:kCIInputMaskImageKey];
//        
//        CIImage * blendOutputImage = blendFilter.outputImage;
//        CGImageRef * blendCGImage = [self.context createCGImage:blendOutputImage fromRect:blendOutputImage.extent];
//        self.mosaicImage = [UIImage imageWithCGImage:blendCGImage];
//    }
}

-(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image1.size);
    
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

#pragma mark - 选颜色

-(BKSelectColorView*)selectColorView
{
    if (!_selectColorView) {
        _selectColorView = [[BKSelectColorView alloc]initWithStartPosition:CGPointMake(UISCREEN_WIDTH - 40,  UISCREEN_HEIGHT - 64 - 250) delegate:self];
    }
    return _selectColorView;
}

#pragma mark - BKSelectColorViewDelegate

-(void)selectColor:(UIColor*)color orSelectType:(BKSelectType)selectType
{
    _drawView.selectColor = color;
    _drawView.selectType = selectType;
}

-(void)revocationAction
{
    [_drawView cleanFinallyDraw];
}

@end
