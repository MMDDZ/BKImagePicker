//
//  BKEditImageViewController.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageViewController.h"
#import "BKTool.h"
#import "BKImagePicker.h"
#import "BKEditImagePreviewCollectionViewFlowLayout.h"
#import "BKEditImagePreviewCollectionViewCell.h"
#import "BKEditImageBgView.h"
#import "BKEditImageDrawView.h"
#import "BKEditImageDrawModel.h"
#import "BKEditImageBottomView.h"
#import "BKEditImageWriteView.h"
#import "BKEditImageClipView.h"
#import "BKImageModel.h"
#import <pthread.h>

@interface BKEditImageViewController ()<BKEditImageDrawViewDelegate,UITextViewDelegate,BKEditImageWriteViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UIImage * currentEditImage;//当前编辑的图片
@property (nonatomic,assign) NSInteger currentEditIndex;//当前编辑的图片index

@property (nonatomic,strong) UICollectionView * previewCollectionView;

@property (nonatomic,strong) BKEditImageBgView * editImageBgView;//修改图片背景
@property (nonatomic,strong) UIPanGestureRecognizer * editImageBgPanGesture;//修改图片背景移动手势
@property (nonatomic,strong) NSTimer * drawTimer;//倒计时定时器

@property (nonatomic,strong) UIImageView * editImageView;//要修改的图片
@property (nonatomic,strong) UIImage * mosaicImage;//全图马赛克处理
@property (nonatomic,assign) BOOL isSuccessMosaicFlag;//是否成功马赛克处理
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

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _currentEditImage = [self.editImageArr firstObject];
    _currentEditIndex = 0;

    [self initTopNav];
    [self initBottomNav];

    [self editImageView];
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
    
    self.rightImageView.image = [[BKTool sharedManager] editImageWithImageName:@"save"];
    
    if ([_editImageArr count] > 1) {
        [self.topNavView addSubview:self.previewCollectionView];
    }
}

-(void)leftNavBtnAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightNavBtnAction:(UIButton *)button
{
    UIWindow * window = [[UIApplication sharedApplication].delegate window];
    
    if (!window.userInteractionEnabled) {
        return;
    }
    window.userInteractionEnabled = NO;
    
    [[BKTool sharedManager] showLoadInView:window];
    
    [self createNewImageWithFrame:CGRectZero editImageRotation:BKEditImageRotationPortrait complete:^(UIImage *resultImage) {
        
        UIImage * saveImage = [self reCreateImage:resultImage];
        
        if (saveImage) {
            
            [[BKImagePicker sharedManager] saveImage:saveImage complete:^(PHAsset *asset, BOOL success) {
                [[BKTool sharedManager] hideLoad];
                window.userInteractionEnabled = YES;
                
                if (!success) {
                    [[BKTool sharedManager] showRemind:@"图片保存失败"];
                }else{
                    [[BKTool sharedManager] showRemind:@"图片保存成功"];
                }
            }];
        }
    }];
}

/**
 根据图片是否含有透明度重新生成新图片

 @param image 旧图片
 @return 新图片
 */
-(UIImage*)reCreateImage:(UIImage*)image
{
    CGImageRef editImageRef = image.CGImage;
    BOOL hasAlpha = [[BKTool sharedManager] checkHaveAlphaWithImageRef:editImageRef];
    
    NSData * imageData;
    NSString * path;
    if (hasAlpha) {//如果图片含有 alpha 保存本地生成新图片 （否则图片保存相册 alpha 会消失）
        imageData = UIImagePNGRepresentation(image);
        path = [NSString stringWithFormat:@"%@%.0f.png",NSTemporaryDirectory(),[[NSDate date] timeIntervalSince1970]];
    }else{
//        imageData = UIImageJPEGRepresentation(image, 1);
//        path = [NSString stringWithFormat:@"%@%.0f.jpg",NSTemporaryDirectory(),[[NSDate date] timeIntervalSince1970]];
        return image;
    }
    BOOL saveflag = [imageData writeToFile:path atomically:YES];
    
    if (saveflag) {
        return [UIImage imageWithContentsOfFile:path];
    }else{
        return image;
    }
}

#pragma mark - 生成图片

-(void)createNewImageWithFrame:(CGRect)frame editImageRotation:(BKEditImageRotation)rotation complete:(void (^)(UIImage * resultImage))complete
{
    CGPoint contentOffset = _editImageBgView.contentOffset;
    CGFloat zoomScale = _editImageBgView.zoomScale;
    
    _editImageBgView.zoomScale = 1;
    _editImageBgView.contentOffset = CGPointZero;
    
    if (_clipView) {
        [_clipView hiddenSelfAuxiliaryUI];
    }
    
    CGImageRef editImageRef = self.currentEditImage.CGImage;
    BOOL hasAlpha = [[BKTool sharedManager] checkHaveAlphaWithImageRef:editImageRef];
    
    CGFloat scale = self.currentEditImage.size.width / self.view.bk_width;
    
    UIGraphicsBeginImageContextWithOptions(self.editImageBgView.contentView.frame.size, hasAlpha?NO:YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.editImageBgView.contentView.layer renderInContext:context];
    __block UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.editImageBgView.contentView.layer.contents = nil;
    
    self.editImageBgView.zoomScale = zoomScale;
    self.editImageBgView.contentOffset = contentOffset;
    
    if (_clipView) {
        [_clipView showSelfAuxiliaryUI];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!CGRectEqualToRect(frame, CGRectZero)) {
            CGRect clipRect = CGRectMake(frame.origin.x * scale,
                                         frame.origin.y * scale,
                                         frame.size.width * scale,
                                         frame.size.height * scale);
            
            CGImageRef newImageRef = CGImageCreateWithImageInRect(image.CGImage, clipRect);
            image = [UIImage imageWithCGImage:newImageRef];
            CGImageRelease(newImageRef);
        }else{
            CGRect rect = CGRectMake(0, 0, image.size.width * image.scale, image.size.height * image.scale);
            
            CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
            image = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
        
        UIImage * resultImage = [self rotationImage:image editRotation:rotation hasAlpha:hasAlpha];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(resultImage);
            }
        });
    });
}

/**
 旋转图片

 @param image 图片
 @param rotation 角度
 @param hasAlpha 是否有透明度
 @return 图片
 */
-(UIImage *)rotationImage:(UIImage*)image editRotation:(BKEditImageRotation)rotation hasAlpha:(BOOL)hasAlpha
{
    long double rotate = 0.0;
    CGRect rect = CGRectZero;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (rotation) {
        case BKEditImageRotationLandscapeLeft:
        {
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = - rect.size.width;
            scaleY = rect.size.width / rect.size.height;
            scaleX = rect.size.height / rect.size.width;
        }
            break;
        case BKEditImageRotationLandscapeRight:
        {
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = - rect.size.height;
            translateY = 0;
            scaleY = rect.size.width / rect.size.height;
            scaleX = rect.size.height / rect.size.width;
        }
            break;
        case BKEditImageRotationUpsideDown:
        {
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = - rect.size.width;
            translateY = - rect.size.height;
        }
            break;
        default:
        {
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
        }
            break;
    }
    
    UIGraphicsBeginImageContextWithOptions(rect.size, hasAlpha?NO:YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    CGContextScaleCTM(context, scaleX, scaleY);
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

#pragma mark - UICollectionView

-(UICollectionView*)previewCollectionView
{
    if (!_previewCollectionView) {
        
        BKEditImagePreviewCollectionViewFlowLayout * layout = [[BKEditImagePreviewCollectionViewFlowLayout alloc]init];
        
        _previewCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(80, BK_SYSTEM_STATUSBAR_HEIGHT, self.topNavView.bk_width - 160, BK_SYSTEM_NAV_UI_HEIGHT) collectionViewLayout:layout];
        _previewCollectionView.delegate = self;
        _previewCollectionView.dataSource = self;
        _previewCollectionView.backgroundColor = [UIColor clearColor];
        _previewCollectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _previewCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_previewCollectionView registerClass:[BKEditImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:@"BKEditImagePreviewCollectionViewCell"];
    }
    return _previewCollectionView;
}

#pragma mark - UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_editImageArr count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKEditImagePreviewCollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"BKEditImagePreviewCollectionViewCell" forIndexPath:indexPath];
    
    if (_currentEditIndex == indexPath.item) {
        cell.selectColorView.hidden = NO;
    }else{
        cell.selectColorView.hidden = YES;
    }
    
    UIImage * currentImage = _editImageArr[indexPath.item];
    cell.showImageView.image = currentImage;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self createNewImageWithFrame:CGRectZero editImageRotation:BKEditImageRotationPortrait complete:^(UIImage *resultImage) {
        
        NSMutableArray * editImageArr = [NSMutableArray arrayWithArray:self.editImageArr];
        [editImageArr replaceObjectAtIndex:self.currentEditIndex withObject:resultImage];
        self.editImageArr = [editImageArr copy];
        
        self.currentEditIndex = indexPath.item;
        [self.previewCollectionView reloadData];
        
        self.currentEditImage = self.editImageArr[self.currentEditIndex];
        
        [self.bottomView cancelEditOperation];
        [self removeEditImageTemplate];
        [self editImageView];
    }];
}

#pragma mark - initBottomNav

-(void)initBottomNav
{
    self.bottomNavViewHeight = BK_SYSTEM_TABBAR_HEIGHT;
    [self.bottomNavView addSubview:self.bottomView];
}

#pragma mark - 发送

-(void)sendPhoto
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [[BKTool sharedManager] showLoadInView:window];
    
    [self createNewImageWithFrame:CGRectZero editImageRotation:BKEditImageRotationPortrait complete:^(UIImage *resultImage) {
        
        NSMutableArray * editImageArr = [NSMutableArray arrayWithArray:self.editImageArr];
        [editImageArr replaceObjectAtIndex:self.currentEditIndex withObject:resultImage];
        self.editImageArr = [editImageArr copy];
        
        dispatch_queue_t queue = dispatch_queue_create("save_lock", NULL);
        
        pthread_mutexattr_t attr;
        pthread_mutexattr_init(&attr);
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL);
        
        __block pthread_mutex_t mutex;
        pthread_mutex_init(&mutex, &attr);
        
        __block NSMutableArray * resultArr = [NSMutableArray array];
        for (UIImage * editImage in self.editImageArr) {
            dispatch_async(queue, ^{
                
                pthread_mutex_lock(&mutex);
                
                [[BKImagePicker sharedManager] saveImage:[self reCreateImage:editImage] complete:^(PHAsset *asset, BOOL success) {
                    
                    pthread_mutex_unlock(&mutex);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!success) {
                            [[BKTool sharedManager] showRemind:@"图片发送失败"];
                            pthread_mutex_destroy(&mutex);
                        }else{
                            [[BKTool sharedManager] getOriginalImageDataSizeWithAsset:asset complete:^(NSData *originalImageData, NSURL *url) {
                                BKImageModel * imageModel = [[BKImageModel alloc]init];
                                imageModel.originalImageData = originalImageData;
                                imageModel.url = url;
                                imageModel.thumbImageData = [[BKTool sharedManager] compressImageData:originalImageData];
                                [resultArr addObject:imageModel];
                                
                                if ([resultArr count] == [editImageArr count]) {
                                    [[BKTool sharedManager] hideLoad];
                                    pthread_mutex_destroy(&mutex);
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:nil];
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                }
                            }];
                        }
                    });
                }];
                
            });
        }
    }];
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
                    
                    strongSelf.topNavView.alpha = 0;
                    strongSelf.bottomNavView.alpha = 0;
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
        [_bottomView setSendBtnAction:^{
            BK_STRONG_SELF(self);
            [strongSelf sendPhoto];
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
        CGFloat scale = _currentEditImage.size.width / self.view.bk_width;
        _editImageBgView.maximumZoomScale = scale<2?2:scale;
        
        [self.view insertSubview:_editImageBgView atIndex:0];
        
        UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editImageBgTapRecognizer:)];
        [_editImageBgView addGestureRecognizer:tapRecognizer];
        
        _editImageBgPanGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(editImageBgPanGesture:)];
        _editImageBgPanGesture.delegate = self;
        _editImageBgPanGesture.maximumNumberOfTouches = 1;
        [_editImageBgView addGestureRecognizer:_editImageBgPanGesture];
        
        BK_WEAK_SELF(self);
        [_editImageBgView setWillChangeZoomScaleAction:^{
            BK_STRONG_SELF(self);
            if (strongSelf.bottomView.selectEditType == BKEditImageSelectEditTypeClip) {
                [strongSelf.clipView willChangeBgScrollViewZoomScale];
            }
        }];
        [_editImageBgView setSlideBgScrollViewAction:^{
            BK_STRONG_SELF(self);
            if (strongSelf.bottomView.selectEditType == BKEditImageSelectEditTypeClip) {
                [strongSelf.clipView slideBgScrollView];
            }
        }];
        [_editImageBgView setEndChangeZoomScaleAction:^{
            BK_STRONG_SELF(self);
            if (strongSelf.bottomView.selectEditType == BKEditImageSelectEditTypeClip) {
                [strongSelf.clipView endChangeBgScrollViewZoomScale];
            }
        }];
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
    if (self.bottomView.selectEditType == BKEditImageSelectEditTypeClip) {
        return;
    }
    
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

-(UIImageView*)editImageView
{
    if (!_editImageView) {
        _editImageView = [[UIImageView alloc]initWithFrame:self.editImageBgView.contentView.bounds];
        
        _currentEditImage = [_currentEditImage editImageOrientation];
        _editImageView.image = _currentEditImage;
        
        [self.editImageBgView.contentView addSubview:_editImageView];
        
        //延迟0.5秒 优化切换速度
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.isSuccessMosaicFlag) {
                return;
            }
            self.isSuccessMosaicFlag = YES;
            
            //全图做马赛克处理 添加在图片图层上
            CALayer * imageLayer = [CALayer layer];
            imageLayer.frame = self.editImageView.bounds;
            imageLayer.contents = (id)self.mosaicImage.CGImage;
            [self.editImageView.layer addSublayer:imageLayer];
            //添加遮罩shapeLayer
            [self.editImageView.layer addSublayer:self.mosaicImageShapeLayer];
            imageLayer.mask = self.mosaicImageShapeLayer;
        });
    }
    return _editImageView;
}

#pragma mark - 算imageView 的 rect

-(CGRect)calculataImageRect
{
    CGRect targetFrame = CGRectZero;
    
    targetFrame.size.width = self.view.frame.size.width;
    if (_currentEditImage) {
        CGFloat scale = _currentEditImage.size.width / targetFrame.size.width;
        targetFrame.size.height = _currentEditImage.size.height/scale;
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
        CIImage *ciImage = [CIImage imageWithCGImage:_currentEditImage.CGImage];
        //生成马赛克
        CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
        [filter setValue:ciImage forKey:kCIInputImageKey];
        //马赛克像素大小
        [filter setValue:@(50) forKey:kCIInputScaleKey];
        CIImage *outImage = [filter valueForKey:kCIOutputImageKey];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:outImage fromRect:CGRectMake(0, 0, _currentEditImage.size.width, _currentEditImage.size.height)];
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
                    
                    strongSelf.bottomNavView.alpha = 1;
                    [UIView animateWithDuration:0.2 animations:^{
                        strongSelf.topNavView.alpha = 1;
                        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                    }];
                    
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
                    strongSelf.topNavView.alpha = 0;
                    strongSelf.bottomNavView.alpha = 0;
                    
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
                    strongSelf.topNavView.alpha = 1;
                    strongSelf.bottomNavView.alpha = 1;
                    
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

-(CGPoint)settingWriteViewPosition:(BKEditImageWriteView *)writeView
{
    CGFloat offset_x = (_editImageBgView.contentOffset.x - (_editImageBgView.contentSize.width - self.view.bk_width) / 2) / _editImageBgView.zoomScale;
    CGFloat offset_y = (_editImageBgView.contentOffset.y - (_editImageBgView.contentSize.height - self.view.bk_height) / 2) / _editImageBgView.zoomScale;
    
    CGFloat x = (_editImageBgView.contentView.bk_width / _editImageBgView.zoomScale - writeView.bk_width) / 2 + offset_x;
    CGFloat y = (_editImageBgView.contentView.bk_height / _editImageBgView.zoomScale - writeView.bk_height) / 2 + offset_y;
    
    return CGPointMake(x, y);
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
        deleteImageView.image = [[BKTool sharedManager] editImageWithImageName:@"delete_write"];
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
            
            if (!strongSelf.view.userInteractionEnabled) {
                return;
            }
            strongSelf.view.userInteractionEnabled = NO;
            
            [strongSelf removeClipView];
            
            strongSelf.editImageBgView.clipsToBounds = YES;
            strongSelf.editImageBgView.minimumZoomScale = 1;
            
            [UIView animateWithDuration:0.2 animations:^{
                strongSelf.editImageBgView.transform = CGAffineTransformIdentity;
                strongSelf.editImageBgView.frame = strongSelf.view.bounds;
                strongSelf.editImageBgView.contentInset = UIEdgeInsetsZero;
                [strongSelf.editImageBgView setZoomScale:1 animated:NO];
            } completion:^(BOOL finished) {
                strongSelf.view.userInteractionEnabled = YES;
            }];
        }];
        [_clipView setFinishAction:^(CGRect clipFrame, BKEditImageRotation rotation) {
            BK_STRONG_SELF(self);
            
            if (!strongSelf.view.userInteractionEnabled) {
                return;
            }
            strongSelf.view.userInteractionEnabled = NO;
            
            [strongSelf.clipView removeFromSuperview];
            
            [strongSelf resetEditImageWithClipFrame:clipFrame rotation:rotation];
        }];
    }
    return _clipView;
}

-(void)removeClipView
{
    [_clipView removeFromSuperview];
    [_clipView removeSelfAuxiliaryUI];
    _clipView = nil;
    
    [self.bottomView cancelEditOperation];
    
    self.topNavView.alpha = 1;
    self.bottomNavView.alpha = 1;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

-(void)removeEditImageTemplate
{
    [_editImageBgView removeFromSuperview];
    _editImageBgView = nil;
    _editImageBgPanGesture = nil;
    [_drawTimer invalidate];
    _drawTimer = nil;
    [_editImageView removeFromSuperview];
    _editImageView = nil;
    _mosaicImage = nil;
    _isSuccessMosaicFlag = NO;
    [_mosaicImageShapeLayer removeFromSuperlayer];
    _mosaicImageShapeLayer = nil;
    [_drawView removeFromSuperview];
    _drawView = nil;
    [_writeTextView removeFromSuperview];
    _writeTextView = nil;
    [_writeViewArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
        obj = nil;
    }];
    [_bottomDeleteWriteView removeFromSuperview];
    _bottomDeleteWriteView = nil;
}

-(void)resetEditImageWithClipFrame:(CGRect)clipFrame rotation:(BKEditImageRotation)rotation
{
    CGRect frame = [_editImageBgView.contentView convertRect:clipFrame toView:self.view];
    
    [self createNewImageWithFrame:clipFrame editImageRotation:rotation complete:^(UIImage *resultImage) {
        
        self.currentEditImage = resultImage;
        
        NSMutableArray * editImageArr = [NSMutableArray arrayWithArray:self.editImageArr];
        [editImageArr replaceObjectAtIndex:self.currentEditIndex withObject:self.currentEditImage];
        self.editImageArr = [editImageArr copy];
        
        [self.previewCollectionView reloadData];
        
        [self removeEditImageTemplate];
        
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:frame];
        imageView.image = self.currentEditImage;
        [self.view insertSubview:imageView atIndex:0];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            imageView.frame = [self calculataImageRect];
            
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            
            [self removeClipView];
            [self editImageView];
            
            self.view.userInteractionEnabled = YES;
        }];
    }];
}

@end
