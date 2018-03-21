//
//  BKEditImageViewController.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageViewController.h"
#import "BKImagePickerConst.h"
#import "BKImagePicker.h"
#import "BKEditImageBgView.h"
#import "BKEditImageDrawView.h"
#import "BKEditImageDrawModel.h"
#import "BKImageCropView.h"
#import "BKEditImageBottomView.h"
#import "BKEditImageWriteView.h"
#import "BKEditImageClipView.h"

@interface BKEditImageViewController ()<BKEditImageDrawViewDelegate,UITextViewDelegate,BKEditImageWriteViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,copy) NSString * imagePath;//图片路径

@property (nonatomic,strong) BKEditImageBgView * editImageBgView;//修改图片背景
@property (nonatomic,strong) UIPanGestureRecognizer * editImageBgPanGesture;//修改图片背景移动手势
@property (nonatomic,strong) NSTimer * drawTimer;//倒计时定时器

@property (nonatomic,strong) UIImageView * editImageView;//要修改的图片
@property (nonatomic,strong) UIImage * mosaicImage;//全图马赛克处理
@property (nonatomic,strong) CAShapeLayer * mosaicImageShapeLayer;

@property (nonatomic,strong) BKEditImageBottomView * bottomView;

@property (nonatomic,strong) BKEditImageDrawView * drawView;//画图(包括线、圆角矩形、圆、箭头)

@property (nonatomic,strong) UITextView * writeTextView;//写字view
@property (nonatomic,strong) BKEditImageWriteView * writeView;//显示字的view
@property (nonatomic,strong) NSMutableArray * writeViewArr;
@property (nonatomic,strong) UIView * bottomDeleteWriteView;

@property (nonatomic,strong) BKEditImageClipView * clipView;

@end

@implementation BKEditImageViewController

#pragma mark - 图片路径

-(NSString*)imagePath
{
    if (!_imagePath) {
        NSString * imageBundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        _imagePath = [NSString stringWithFormat:@"%@",imageBundlePath];
    }
    return _imagePath;
}

-(UIImage*)imageWithImageName:(NSString*)imageName
{
    return [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/EditImage/%@",self.imagePath,imageName]];
}

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initTopNav];
    [self initBottomNav];
    
    [self editImageView];
    [self drawView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    ((BKImageNavViewController*)self.navigationController).customTransition.enble = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    ((BKImageNavViewController*)self.navigationController).customTransition.enble = YES;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initTopNav

-(void)initTopNav
{
    self.leftImageView.image = nil;
    self.leftLab.text = @"取消";
    
    self.rightImageView.image = [self imageWithImageName:@"save"];
}

-(void)leftNavBtnAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)rightNavBtnAction:(UIButton *)button
{
    [[BKImagePicker sharedManager] saveImage:[self createNewImage]];
}

#pragma mark - 生成图片

-(UIImage*)createNewImage
{
    BOOL flag = [UIApplication sharedApplication].statusBarHidden;
    CGFloat alpha1 = self.topNavView.alpha;
    CGFloat alpha2 = self.bottomNavView.alpha;
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.topNavView.alpha = 0;
    self.bottomNavView.alpha = 0;
    
    _editImageView.image = nil;
    self.view.backgroundColor = [UIColor clearColor];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGRect rect = self.editImageView.frame;
    rect.origin.x = rect.origin.x * scale;
    rect.origin.y = rect.origin.y * scale;
    rect.size.width = rect.size.width * scale;
    rect.size.height = rect.size.height * scale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    image = [UIImage imageWithCGImage:imageRef];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(_editImage.size.width, _editImage.size.height), NO, 1);
    [_editImage drawInRect:CGRectMake(0, 0, _editImage.size.width, _editImage.size.height)];
    [image drawInRect:CGRectMake(0, 0, _editImage.size.width, _editImage.size.height)];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData * imageData = UIImagePNGRepresentation(resultImage);
    BOOL saveflag = [imageData writeToFile:[NSString stringWithFormat:@"%@/save.png",NSTemporaryDirectory()] atomically:YES];
    if (saveflag) {
        resultImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/save.png",NSTemporaryDirectory()]];
    }
    
    if (!flag) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    if (alpha1 != 0) {
        self.topNavView.alpha = alpha1;
    }
    if (alpha2 != 0) {
        self.bottomNavView.alpha = alpha1;
    }
    
    _editImageView.image = _editImage;
    self.view.backgroundColor = [UIColor blackColor];
    
    return resultImage;
}

#pragma mark - initBottomNav

-(void)initBottomNav
{
    self.bottomNavViewHeight = BK_SYSTEM_TABBAR_HEIGHT;
    [self.bottomNavView addSubview:self.bottomView];
}

#pragma mark - BKEditImageBottomView

-(BKEditImageBottomView*)bottomView
{
    if (!_bottomView) {
        _bottomView = [[BKEditImageBottomView alloc]init];
        BK_WEAK_SELF(self);
        [_bottomView setSelectTypeAction:^{
            BK_STRONG_SELF(self);
            
            switch (strongSelf.bottomView.selectEditType) {
                case BKEditImageSelectEditTypeDrawLine:
                {
                    strongSelf.bottomNavViewHeight = strongSelf.bottomView.bk_height + BK_SYSTEM_TABBAR_HEIGHT - BK_SYSTEM_TABBAR_UI_HEIGHT;
                    
                    strongSelf.drawView.drawType = BKEditImageSelectEditTypeDrawLine;
                    strongSelf.drawView.selectColor = strongSelf.bottomView.selectPaintingColor;
                    strongSelf.drawView.selectPaintingType = strongSelf.bottomView.selectPaintingType;
                }
                    break;
                case BKEditImageSelectEditTypeDrawCircle:
                {
                    strongSelf.bottomNavViewHeight = strongSelf.bottomView.bk_height + BK_SYSTEM_TABBAR_HEIGHT - BK_SYSTEM_TABBAR_UI_HEIGHT;
                    
                    strongSelf.drawView.drawType = BKEditImageSelectEditTypeDrawCircle;
                    strongSelf.drawView.selectColor = strongSelf.bottomView.selectPaintingColor;
                    strongSelf.drawView.selectPaintingType = strongSelf.bottomView.selectPaintingType;
                }
                    break;
                case BKEditImageSelectEditTypeDrawRoundedRectangle:
                {
                    strongSelf.bottomNavViewHeight = strongSelf.bottomView.bk_height + BK_SYSTEM_TABBAR_HEIGHT - BK_SYSTEM_TABBAR_UI_HEIGHT;
                    
                    strongSelf.drawView.drawType = BKEditImageSelectEditTypeDrawRoundedRectangle;
                    strongSelf.drawView.selectColor = strongSelf.bottomView.selectPaintingColor;
                    strongSelf.drawView.selectPaintingType = strongSelf.bottomView.selectPaintingType;
                }
                    break;
                case BKEditImageSelectEditTypeDrawArrow:
                {
                    strongSelf.bottomNavViewHeight = strongSelf.bottomView.bk_height + BK_SYSTEM_TABBAR_HEIGHT - BK_SYSTEM_TABBAR_UI_HEIGHT;
                    
                    strongSelf.drawView.drawType = BKEditImageSelectEditTypeDrawArrow;
                    strongSelf.drawView.selectColor = strongSelf.bottomView.selectPaintingColor;
                    strongSelf.drawView.selectPaintingType = strongSelf.bottomView.selectPaintingType;
                }
                    break;
                case BKEditImageSelectEditTypeWrite:
                {
                    strongSelf.writeTextView.textColor = strongSelf.bottomView.selectPaintingColor;
                    strongSelf.writeView.writeColor = strongSelf.writeTextView.textColor;
                    if (!strongSelf.writeTextView.isFirstResponder) {
                        [strongSelf.writeTextView becomeFirstResponder];
                    }
                }
                    break;
                case BKEditImageSelectEditTypeClip:
                {
                    strongSelf.bottomNavViewHeight = strongSelf.bottomView.bk_height + BK_SYSTEM_TABBAR_HEIGHT - BK_SYSTEM_TABBAR_UI_HEIGHT;
                    
                    strongSelf.topNavView.hidden = YES;
                    strongSelf.bottomNavView.hidden = YES;
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                    
                    [strongSelf.clipView showClipView];
                }
                    break;
                default:
                {
                    strongSelf.bottomNavViewHeight = strongSelf.bottomView.bk_height + BK_SYSTEM_TABBAR_HEIGHT - BK_SYSTEM_TABBAR_UI_HEIGHT;
                }
                    break;
            }
        }];
        [_bottomView setRevocationAction:^{
            BK_STRONG_SELF(self);
            [strongSelf.drawView cleanFinallyDraw];
        }];
    }
    return _bottomView;
}

#pragma mark - editImageBgView

-(BKEditImageBgView*)editImageBgView
{
    if (!_editImageBgView) {
        _editImageBgView = [[BKEditImageBgView alloc]initWithFrame:self.view.bounds];
        
        _editImageBgView.contentView.frame = [self calculataImageRect];
        _editImageBgView.contentSize = CGSizeMake(_editImageBgView.contentView.bk_width<self.view.bk_width?self.view.bk_width:_editImageBgView.contentView.bk_width, _editImageBgView.contentView.bk_height<self.view.bk_height?self.view.bk_height:_editImageBgView.contentView.bk_height);
        CGFloat scale = _editImage.size.width / self.view.bk_width;
        _editImageBgView.maximumZoomScale = scale<2?2:scale;
        
        [self.view insertSubview:_editImageBgView atIndex:0];
        
        UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editImageBgTapRecognizer:)];
        [_editImageBgView addGestureRecognizer:tapRecognizer];
        
        _editImageBgPanGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(editImageBgPanGesture:)];
        _editImageBgPanGesture.delegate = self;
        _editImageBgPanGesture.maximumNumberOfTouches = 1;
        [_editImageBgView addGestureRecognizer:_editImageBgPanGesture];
        
        BK_WEAK_SELF(self);
        [_editImageBgView setChangeZoomScaleAction:^{
            BK_STRONG_SELF(self);
            if (strongSelf.bottomView.selectEditType == BKEditImageSelectEditTypeClip) {
                [strongSelf.clipView changeBgScrollViewZoomScale];
            }
        }];
    }
    return _editImageBgView;
}

#pragma mark - 手势

-(void)editImageBgTapRecognizer:(UITapGestureRecognizer*)recognizer
{
    [_drawTimer invalidate];
    _drawTimer = nil;
    
    if (self.topNavView.alpha == 1) {
        [UIView animateWithDuration:0.2 animations:^{
            self.topNavView.alpha = 0;
            self.bottomNavView.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.topNavView.alpha = 1;
            self.bottomNavView.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }];
    }
}

-(void)editImageBgPanGesture:(UIPanGestureRecognizer*)panGesture
{
    if (self.bottomView.selectEditType == BKEditImageSelectEditTypeNone || self.bottomView.selectEditType == BKEditImageSelectEditTypeWrite || self.bottomView.selectEditType == BKEditImageSelectEditTypeClip) {
        return;
    }
    
    CGPoint point = [panGesture locationInView:self.editImageBgView.contentView];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.drawView.beginPoint = point;
            
            [_drawTimer invalidate];
            _drawTimer = nil;
            
            [self drawThingsTimer];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (self.drawView.beginPoint.x != point.x || self.drawView.beginPoint.y != point.y) {
                switch (self.drawView.drawType) {
                    case BKEditImageSelectEditTypeDrawLine:
                    {
                        [self.drawView drawLineWithPoint:point];
                    }
                        break;
                    case BKEditImageSelectEditTypeDrawCircle:
                    {
                        [self.drawView drawCircleWithBeginPoint:self.drawView.beginPoint endPoint:point];
                    }
                        break;
                    case BKEditImageSelectEditTypeDrawRoundedRectangle:
                    {
                        [self.drawView drawRoundedRectangleWithPoint:point];
                    }
                        break;
                    case BKEditImageSelectEditTypeDrawArrow:
                    {
                        [self.drawView drawArrowWithBeginPoint:self.drawView.beginPoint endPoint:point];
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if ([self.drawView.pointArray count] > 0) {
                
                BKEditImageDrawModel * model = [[BKEditImageDrawModel alloc]init];
                model.pointArray = [self.drawView.pointArray copy];
                model.selectColor = self.drawView.selectColor;
                model.selectPaintingType = self.drawView.selectPaintingType;
                model.drawType = self.drawView.drawType;
                
                [self.drawView.lineArray addObject:model];
                [self.drawView.pointArray removeAllObjects];
                
                if (!_drawTimer) {
                    [self drawTimer];
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        if (self.bottomView.selectEditType == BKEditImageSelectEditTypeDrawLine || self.bottomView.selectEditType == BKEditImageSelectEditTypeDrawCircle || self.bottomView.selectEditType == BKEditImageSelectEditTypeDrawRoundedRectangle || self.bottomView.selectEditType == BKEditImageSelectEditTypeDrawArrow) {
            otherGestureRecognizer.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                otherGestureRecognizer.enabled = YES;
            });
        }
    }
    return YES;
}

#pragma mark - drawTimer

-(NSTimer *)drawTimer
{
    if (!_drawTimer) {
        _drawTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(drawThingsTimer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_drawTimer forMode:NSRunLoopCommonModes];
    }
    return _drawTimer;
}

-(void)drawThingsTimer
{
    if (_editImageBgPanGesture.state == UIGestureRecognizerStatePossible || _editImageBgPanGesture.state == UIGestureRecognizerStateEnded || _editImageBgPanGesture.state == UIGestureRecognizerStateCancelled || _editImageBgPanGesture.state == UIGestureRecognizerStateFailed) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.topNavView.alpha = 1;
            self.bottomNavView.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }];
        
        [_drawTimer invalidate];
        _drawTimer = nil;
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.topNavView.alpha = 0;
            self.bottomNavView.alpha = 0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }];
    }
}

#pragma mark - 图片

-(void)setEditImage:(UIImage *)editImage
{
    //图片取正
    _editImage = [editImage editImageOrientation];
}

-(UIImageView*)editImageView
{
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc]initWithFrame:self.editImageBgView.contentView.bounds];
        _editImageView.image = self.editImage;
        [self.editImageBgView.contentView addSubview:_editImageView];
        
        //全图做马赛克处理 添加在图片图层上
        CALayer * imageLayer = [CALayer layer];
        imageLayer.frame = _editImageView.bounds;
        imageLayer.contents = (id)self.mosaicImage.CGImage;
        [_editImageView.layer addSublayer:imageLayer];
        //添加遮罩shapeLayer
        [_editImageView.layer addSublayer:self.mosaicImageShapeLayer];
        imageLayer.mask = self.mosaicImageShapeLayer;
    }
    return _editImageView;
}

#pragma mark - 算imageView 的 rect

-(CGRect)calculataImageRect
{
    CGRect targetFrame = CGRectZero;
    
    targetFrame.size.width = self.view.frame.size.width;
    if (_editImage) {
        CGFloat scale = _editImage.size.width / targetFrame.size.width;
        targetFrame.size.height = _editImage.size.height/scale;
        if (targetFrame.size.height < self.view.frame.size.height) {
            targetFrame.origin.y = (self.view.frame.size.height - targetFrame.size.height)/2;
        }
    }else{
        targetFrame.size.height = self.view.frame.size.width;
        targetFrame.origin.y = (self.view.frame.size.height - targetFrame.size.height)/2;
    }
    
    return targetFrame;
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

#pragma mark - BKEditImageDrawView

-(BKEditImageDrawView*)drawView
{
    if (!_drawView) {
        _drawView = [[BKEditImageDrawView alloc]initWithFrame:self.editImageView.frame];
        _drawView.delegate = self;
        [self.editImageBgView.contentView addSubview:_drawView];
    }
    return _drawView;
}

#pragma mark - BKEditImageDrawViewDelegate

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

#pragma mark - NSNotification

-(void)keyboardWillShow:(NSNotification*)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    
    self.bottomNavViewHeight = height + self.bottomView.bk_height + BK_SYSTEM_TABBAR_HEIGHT - BK_SYSTEM_TABBAR_UI_HEIGHT;
    self.writeTextView.bk_height = self.view.bk_height - self.bottomNavView.bk_height - CGRectGetMaxY(self.topNavView.frame);
    self.writeTextView.bk_y = CGRectGetMaxY(self.topNavView.frame);
    self.writeTextView.hidden = NO;
    
    [_bottomView keyboardWillShow:notification];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    self.bottomNavViewHeight = self.bottomView.bk_height + BK_SYSTEM_TABBAR_HEIGHT - BK_SYSTEM_TABBAR_UI_HEIGHT;
    self.writeTextView.bk_height = 0;
    self.writeTextView.bk_y = CGRectGetMinY(self.bottomNavView.frame);
    self.writeTextView.hidden = YES;
    
    [_bottomView keyboardWillHide:notification];
}

#pragma mark - WriteTextView

-(UITextView*)writeTextView
{
    if (!_writeTextView) {
        _writeTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.bottomNavView.frame), self.view.bk_width, 0)];
        _writeTextView.backgroundColor = BKNavBackgroundColor;
        _writeTextView.textColor = self.bottomView.selectPaintingColor;
        _writeTextView.font = [UIFont systemFontOfSize:20];
        _writeTextView.textContainerInset = UIEdgeInsetsMake(12, 8, 12, 8);
        _writeTextView.showsVerticalScrollIndicator = NO;
        _writeTextView.showsHorizontalScrollIndicator = NO;
        _writeTextView.delegate = self;
        [self.view addSubview:_writeTextView];
    }
    return _writeTextView;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == _writeTextView) {
        self.bottomView.isSaveEditWrite = YES;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == _writeTextView) {
        if (self.bottomView.isSaveEditWrite) {
            if (![[self.editImageBgView.contentView subviews] containsObject:self.writeView]) {
                [self.editImageBgView.contentView addSubview:self.writeView];
            }
            if (![self.writeViewArr containsObject:self.writeView]) {
                [self.writeViewArr addObject:self.writeView];
            }
            self.writeView.writeString = self.writeTextView.text;
        }
        
        self.writeView.hidden = NO;
        
        if ([self.writeView.writeString length] == 0) {
            [self.writeViewArr removeObject:self.writeView];
            [self.writeView removeFromSuperview];
        }
        
        self.writeView = nil;
        
        self.writeTextView.text = @"";
    }
}

#pragma mark - BKEditImageWriteView

-(NSMutableArray*)writeViewArr
{
    if (!_writeViewArr) {
        _writeViewArr = [NSMutableArray array];
    }
    return _writeViewArr;
}

static BOOL writeDeleteFlag = NO;
-(BKEditImageWriteView*)writeView
{
    if (!_writeView) {
        _writeView = [[BKEditImageWriteView alloc]init];
        _writeView.delegate = self;
        
        BK_WEAK_SELF(self);
        [_writeView setReeditAction:^(BKEditImageWriteView *writeView) {
            BK_STRONG_SELF(self);
            [strongSelf.writeViewArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj == writeView) {
                    
                    strongSelf.writeView = writeView;
                    strongSelf.writeView.hidden = YES;
                    
                    [strongSelf.bottomView reeditWriteWithWriteStringColor:strongSelf.writeView.writeColor];
                    
                    strongSelf.writeTextView.textColor = strongSelf.writeView.writeColor;
                    strongSelf.writeTextView.text = strongSelf.writeView.writeString;
                    if (!strongSelf.writeTextView.isFirstResponder) {
                        [strongSelf.writeTextView becomeFirstResponder];
                    }
                    
                    *stop = YES;
                }
            }];
        }];
        [_writeView setMoveWriteAction:^(BKEditImageWriteView *writeView, UIPanGestureRecognizer *panGesture) {
            BK_STRONG_SELF(self);
            
            switch (panGesture.state) {
                case UIGestureRecognizerStateBegan:
                {
                    [UIApplication sharedApplication].statusBarHidden = YES;
                    strongSelf.topNavView.hidden = YES;
                    strongSelf.bottomNavView.hidden = YES;
                    
                    strongSelf.editImageBgView.contentView.clipsToBounds = NO;
                    
                    [strongSelf.view addSubview:strongSelf.bottomDeleteWriteView];
                }
                    break;
                case UIGestureRecognizerStateChanged:
                {
                    CGPoint point = [panGesture locationInView:strongSelf.view];
                    if (CGRectContainsPoint(strongSelf.bottomDeleteWriteView.frame, point) || !CGRectIntersectsRect(strongSelf.editImageView.frame, writeView.frame)) {
                        strongSelf.bottomDeleteWriteView.backgroundColor = BK_HEX_RGB(0xff725c);
                        strongSelf.bottomDeleteWriteView.alpha = 0.5;
                        writeDeleteFlag = YES;
                    }else{
                        strongSelf.bottomDeleteWriteView.backgroundColor = BKHighlightColor;
                        strongSelf.bottomDeleteWriteView.alpha = 1;
                        writeDeleteFlag = NO;
                    }
                }
                    break;
                case UIGestureRecognizerStateEnded:
                case UIGestureRecognizerStateCancelled:
                case UIGestureRecognizerStateFailed:
                {
                    [UIApplication sharedApplication].statusBarHidden = NO;
                    strongSelf.topNavView.hidden = NO;
                    strongSelf.bottomNavView.hidden = NO;
                    
                    [strongSelf.bottomDeleteWriteView removeFromSuperview];
                    strongSelf.bottomDeleteWriteView = nil;
                    
                    strongSelf.editImageBgView.contentView.clipsToBounds = YES;
                    
                    if (writeDeleteFlag) {
                        [strongSelf.writeViewArr removeObject:writeView];
                        [writeView removeFromSuperview];
                    }
                }
                    break;
                default:
                    break;
            }
        }];
    }
    
    return _writeView;
}

#pragma mark - BKEditImageWriteViewDelegate

-(UIView*)getWriteViewSupperView
{
    return _editImageBgView.contentView;
}

-(CGFloat)getNowImageZoomScale
{
    return _editImageBgView.zoomScale;
}

#pragma mark - bottomDeleteWriteView

-(UIView*)bottomDeleteWriteView
{
    if (!_bottomDeleteWriteView) {
        _bottomDeleteWriteView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bk_height - 49, self.view.bk_width, 49)];
        _bottomDeleteWriteView.backgroundColor = BKHighlightColor;
        
        UIImageView * deleteImageView = [[UIImageView alloc]initWithFrame:CGRectMake((_bottomDeleteWriteView.bk_width - 30)/2, (_bottomDeleteWriteView.bk_height - 30)/2, 30, 30)];
        deleteImageView.image = [self imageWithImageName:@"delete_write"];
        deleteImageView.clipsToBounds = YES;
        deleteImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_bottomDeleteWriteView addSubview:deleteImageView];
    }
    return _bottomDeleteWriteView;
}

#pragma mark - BKEditImageClipView

-(BKEditImageClipView*)clipView
{
    if (!_clipView) {
        _clipView = [[BKEditImageClipView alloc]initWithFrame:self.view.bounds];
        _clipView.editImageBgView = _editImageBgView;
        [self.view addSubview:_clipView];
        
        BK_WEAK_SELF(self);
        [_clipView setBackAction:^{
            BK_STRONG_SELF(self);
            [strongSelf.clipView removeFromSuperview];
            strongSelf.clipView = nil;
            
            [strongSelf.bottomView endEditCrop];
            
            strongSelf.topNavView.hidden = NO;
            strongSelf.bottomNavView.hidden = NO;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            
            [strongSelf.editImageBgView setZoomScale:1 animated:YES];
        }];
        [_clipView setFinishAction:^{
            BK_STRONG_SELF(self);
        }];
    }
    return _clipView;
}

@end
