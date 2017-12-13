//
//  BKEditPhotoView.m
//  BKImagePicker
//
//  Created by iMac on 17/1/18.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKEditPhotoView.h"
#import "BKImagePickerConst.h"
#import <Photos/Photos.h>
#import "BKImagePicker.h"
#import "BKDrawView.h"
#import "BKSelectColorView.h"
#import "UIImage+BKOrientationExpand.h"
#import "BKDrawModel.h"
#import "BKImageCropView.h"

@interface BKEditPhotoView()<BKSelectColorViewDelegate,BKDrawViewDelegate>

/**
 要修改的图片
 */
@property (nonatomic,strong) UIImage * editImage;
@property (nonatomic,strong) UIImageView * editImageView;
/**
 全图马赛克处理
 */
@property (nonatomic,strong) UIImage * mosaicImage;
@property (nonatomic,strong) CAShapeLayer * mosaicImageShapeLayer;

/**
 画图(包括线、圆角矩形、圆、箭头)
 */
@property (nonatomic,strong) BKDrawView * drawView;

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


@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIView * bottomView;

@property (nonatomic,strong) UIButton * selectEditBtn;
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
        self.backgroundColor = [UIColor blackColor];
        
        [self addEditImage:image];
        [self addSubview:self.drawView];
        
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        
        [self addSubview:self.selectColorView];
        
        [self addObserver:self forKeyPath:@"isDrawingFlag" options:NSKeyValueObservingOptionNew context:nil];
        _drawTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(drawThingsTimer) userInfo:nil repeats:YES];
    }
    return self;
}

#pragma mark - NSTimer

-(void)drawThingsTimer
{
    self.afterDrawTime = self.afterDrawTime - 1;
    if (self.afterDrawTime == 0) {
        self.isDrawingFlag = NO;
    }
}

#pragma mark - KVO

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

#pragma mark - 马赛克图片

-(UIImage *)mosaicImage
{
    if (!_mosaicImage) {
        CIImage *ciImage = [CIImage imageWithCGImage:self.editImage.CGImage];
        //生成马赛克
        CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
        [filter setValue:ciImage forKey:kCIInputImageKey];
        //马赛克像素大小
        [filter setValue:@(50) forKey:kCIInputScaleKey];
        CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:outImage fromRect:CGRectMake(0, 0, self.editImage.size.width, self.editImage.size.height)];
        _mosaicImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
    }
    return _mosaicImage;
}

-(CAShapeLayer*)mosaicImageShapeLayer
{
    if (!_mosaicImageShapeLayer) {
        _mosaicImageShapeLayer = [CAShapeLayer layer];
        _mosaicImageShapeLayer.frame = self.editImageView.bounds;
        _mosaicImageShapeLayer.lineCap = kCALineCapRound;
        _mosaicImageShapeLayer.lineJoin = kCALineJoinRound;
        _mosaicImageShapeLayer.lineWidth = 20;
        _mosaicImageShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        _mosaicImageShapeLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _mosaicImageShapeLayer;
}

#pragma mark - 图片

-(void)addEditImage:(UIImage*)image
{
    //图片取正 添加在屏幕上
    self.editImage = [image editImageOrientation];
    [self addSubview:self.editImageView];
    //全图做马赛克处理 添加在图片图层上
    CALayer * imageLayer = [CALayer layer];
    imageLayer.frame = self.editImageView.bounds;
    imageLayer.contents = (id)self.mosaicImage.CGImage;
    [self.editImageView.layer addSublayer:imageLayer];
    //添加遮罩shapeLayer
    [self.editImageView.layer addSublayer:self.mosaicImageShapeLayer];
    imageLayer.mask = self.mosaicImageShapeLayer;
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

#pragma mark - 画画

-(BKDrawView*)drawView
{
    if (!_drawView) {
        _drawView = [[BKDrawView alloc]initWithFrame:self.editImageView.frame];
        _drawView.delegate = self;
    }
    return _drawView;
}

#pragma mark - BKDrawViewDelegate

/**
 画的马赛克轨迹
 
 @param pointArr 轨迹数组
 */
-(void)processingMosaicImageWithPathArr:(NSArray*)pointArr
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    if ([pointArr count] > 0) {
        for (int i = 0; i < [pointArr count]; i++) {
            
            NSArray * nextPointArr = pointArr[i];
            
            CGPoint startPoint = CGPointFromString([NSString stringWithFormat:@"%@",nextPointArr[0]]);
            CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
            
            for (int j = 0; j < [nextPointArr count]-1; j++) {
                CGPoint endPoint = CGPointFromString([NSString stringWithFormat:@"%@",nextPointArr[j+1]]);
                CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
            }
            
            CGMutablePathRef nextPath = CGPathCreateMutableCopy(path);
            self.mosaicImageShapeLayer.path = nextPath;
            
            CGPathRelease(nextPath);
        }
    }else{
        self.mosaicImageShapeLayer.path = nil;
    }
    
    CGPathRelease(path);
}

#pragma mark - 手势

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    point.x = point.x - self.editImageView.frame.origin.x;
    point.y = point.y - self.editImageView.frame.origin.y;
    self.drawView.beginPoint = point;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    point.x = point.x - self.editImageView.frame.origin.x;
    point.y = point.y - self.editImageView.frame.origin.y;
    
    if (self.drawView.beginPoint.x != point.x || self.drawView.beginPoint.y != point.y) {
        switch (self.drawView.drawType) {
            case BKDrawTypeLine:
            {
                [self.drawView drawLineWithPoint:point];
            }
                break;
            case BKDrawTypeRoundedRectangle:
            {
                [self.drawView drawRoundedRectangleWithPoint:point];
            }
                break;
            case BKDrawTypeCircle:
            {
                [self.drawView drawCircleWithBeginPoint:self.drawView.beginPoint endPoint:point];
            }
                break;
            case BKDrawTypeArrow:
            {
                [self.drawView drawArrowWithBeginPoint:self.drawView.beginPoint endPoint:point];
            }
                break;
            default:
                break;
        }
        
        [self movedOption];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.drawView.pointArray count] > 0) {
        
        BKDrawModel * model = [[BKDrawModel alloc]init];
        model.pointArray = [self.drawView.pointArray copy];
        model.selectColor = self.drawView.selectColor;
        model.selectType = self.drawView.selectType;
        model.drawType = self.drawView.drawType;
        
        [self.drawView.lineArray addObject:model];
        [self.drawView.pointArray removeAllObjects];
    }
    
    [self moveEndOption];
}

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

#pragma mark - 生成图片

-(UIImage*)createNewImage
{
    BOOL flag = [UIApplication sharedApplication].statusBarHidden;
    CGFloat alpha1 = _topView.alpha;
    CGFloat alpha2 = _bottomView.alpha;
    CGFloat alpha3 = _selectColorView.alpha;
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    _topView.alpha = 0;
    _bottomView.alpha = 0;
    _selectColorView.alpha = 0;
    
    _editImageView.image = nil;
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect rect = self.editImageView.frame;
    rect.origin.x = rect.origin.x * scale;
    rect.origin.y = rect.origin.y * scale;
    rect.size.width = rect.size.width * scale;
    rect.size.height = rect.size.height * scale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    image = [UIImage imageWithCGImage:imageRef];
    
    UIGraphicsBeginImageContext(CGSizeMake(_editImage.size.width, _editImage.size.height));
    [_editImage drawInRect:CGRectMake(0, 0, _editImage.size.width, _editImage.size.height)];
    [image drawInRect:CGRectMake(0, 0, _editImage.size.width, _editImage.size.height)];
    UIImage * reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!flag) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    if (alpha1 != 0) {
        _topView.alpha = alpha1;
    }
    if (alpha2 != 0) {
        _bottomView.alpha = alpha1;
    }
    if (alpha3 != 0) {
        _selectColorView.alpha = alpha1;
    }
    
    _editImageView.image = _editImage;
    self.backgroundColor = [UIColor blackColor];
    
    return reSizeImage;
}

#pragma mark - topView

-(UIView*)topView
{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, 64)];
        _topView.backgroundColor = BKNavBackgroundColor;
        
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

-(void)cancelThings
{
    [self removeObserver:self forKeyPath:@"isDrawingFlag"];
    [_drawTimer invalidate];
    _drawTimer = nil;
}

/**
 保存图片
 */
-(void)saveBtnClick
{
    [[BKImagePicker sharedManager] saveImage:[self createNewImage]];
}

#pragma mark - bottomView

-(UIView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bk_height - 49, self.bk_width, 49)];
        _bottomView.backgroundColor = BKNavBackgroundColor;
        
        UIScrollView * itemsView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width/4*3 - 6, _bottomView.bk_height)];
        itemsView.backgroundColor = [UIColor clearColor];
        itemsView.showsVerticalScrollIndicator = NO;
        [_bottomView addSubview:itemsView];
        
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        NSArray * imageArr_n = @[[bundlePath stringByAppendingString:@"/draw_n.png"],[bundlePath stringByAppendingString:@"/rounded_rectangle_n.png"],[bundlePath stringByAppendingString:@"/circle_n.png"],[bundlePath stringByAppendingString:@"/arrow_n.png"],[bundlePath stringByAppendingString:@"/rotation_n.png"],[bundlePath stringByAppendingString:@"/write_n.png"],[bundlePath stringByAppendingString:@"/clip_n.png"]];
        NSArray * imageArr_s = @[[bundlePath stringByAppendingString:@"/draw_s.png"],[bundlePath stringByAppendingString:@"/rounded_rectangle_s.png"],[bundlePath stringByAppendingString:@"/circle_s.png"],[bundlePath stringByAppendingString:@"/arrow_s.png"],[bundlePath stringByAppendingString:@"/rotation_s.png"],[bundlePath stringByAppendingString:@"/write_s.png"],[bundlePath stringByAppendingString:@"/clip_s.png"]];
        
        __block UIView * lastView;
        [imageArr_n enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, 49);
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
            _drawView.drawType = BKDrawTypeLine;
        }
            break;
        case 1:
        {
            _drawView.drawType = BKDrawTypeRoundedRectangle;
        }
            break;
        case 2:
        {
            _drawView.drawType = BKDrawTypeCircle;
        }
            break;
        case 3:
        {
            _drawView.drawType = BKDrawTypeArrow;
        }
            break;
        case 4:
        {
            UIImage * image = [self createNewImage];
            BKImageCropView * cropView = [[BKImageCropView alloc] initWithImage:image];
            [self addSubview:cropView];
        }
            break;
        default:
            break;
    }
}

-(void)sendBtnClick
{
    
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
        _selectColorView = [[BKSelectColorView alloc]initWithStartPosition:CGPointMake(SCREENW - 40,  SCREENH - 64 - 250) delegate:self];
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
