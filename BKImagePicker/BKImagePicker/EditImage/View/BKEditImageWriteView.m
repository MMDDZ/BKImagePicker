//
//  BKEditImageWriteView.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/23.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageWriteView.h"
#import "BKImagePickerMacro.h"
#import "NSString+BKImagePicker.h"
#import "UIView+BKImagePicker.h"
#import "NSObject+BKImagePicker.h"

@interface BKEditImageWriteView()<UIGestureRecognizerDelegate>

@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;

@property (nonatomic,assign) CGFloat scale;
@property (nonatomic,assign) CGFloat rotation;

@end

@implementation BKEditImageWriteView

#pragma mark - writeString

-(void)setWriteString:(NSString *)writeString
{
    _writeString = writeString;
    if ([_writeString length] == 0) {
        return;
    }
    
    _width = [_writeString bk_calculateSizeWithUIHeight:MAXFLOAT font:[UIFont systemFontOfSize:50]].width + 20;
    if (_width > (BK_SCREENW - 20)*2) {
        _width = (BK_SCREENW - 20)*2;
    }
    
    _height = [_writeString bk_calculateSizeWithUIWidth:_width font:[UIFont systemFontOfSize:50]].height + 20;
    
    self.transform = CGAffineTransformIdentity;
    
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        self.frame = CGRectMake(0, 0, _width, _height);
        if ([self.delegate respondsToSelector:@selector(settingWriteViewPosition:)]) {
            CGPoint position = [self.delegate settingWriteViewPosition:self];
            self.bk_x = position.x;
            self.bk_y = position.y;
        }
    }else{
        
        CGPoint center = self.center;
        
        self.bk_width = _width;
        self.bk_height = _height;
        self.center = center;
    }
    
    [self setNeedsDisplay];
}

#pragma mark - init

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = BKClearColor;
        [self addGesture];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = BKClearColor;
        [self addGesture];
    }
    return self;
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:50],NSForegroundColorAttributeName:_writeColor?_writeColor:BKRedColor};
    [self.writeString drawWithRect:CGRectMake(10, 10, self.bk_width - 20, self.bk_height - 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    [self resetTransform];
}

#pragma mark - 手势

-(void)addGesture
{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    tapGesture.bk_strTag = @"tap";
    [self addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    UIRotationGestureRecognizer * rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGesture:)];
    rotationGesture.delegate = self;
    [self addGestureRecognizer:rotationGesture];
    
    _scale = 0.5;
    
    UIPinchGestureRecognizer * pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];
}

-(void)tapGesture:(UITapGestureRecognizer*)tapGesture
{
    if (self.reeditAction) {
        self.reeditAction(self);
    }
}

-(void)panGesture:(UIPanGestureRecognizer*)panGesture
{
    CGPoint translation = [panGesture translationInView:[UIApplication sharedApplication].keyWindow];
    
    CGFloat nowImageZoomScale = 0;
    if ([self.delegate respondsToSelector:@selector(getNowImageZoomScale)]) {
        nowImageZoomScale = [self.delegate getNowImageZoomScale];
        if (nowImageZoomScale == 0) {
            nowImageZoomScale = 1;
        }
    }
    
    self.bk_centerX = self.bk_centerX + translation.x/2/nowImageZoomScale;
    self.bk_centerY = self.bk_centerY + translation.y/2/nowImageZoomScale;
    
    if (self.moveWriteAction) {
        self.moveWriteAction(self,panGesture);
    }
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateFailed || panGesture.state == UIGestureRecognizerStateCancelled) {
        self.layer.borderWidth = 0;
        self.layer.borderColor = nil;
    }else{
        self.layer.borderWidth = 1/_scale;
        self.layer.borderColor = BKEditImageTextFrameColor.CGColor;
    }
    
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
}

-(void)rotationGesture:(UIRotationGestureRecognizer*)rotationGesture
{
    self.rotation = self.rotation + rotationGesture.rotation/2;
    [self resetTransform];
    
    if (rotationGesture.state == UIGestureRecognizerStateEnded || rotationGesture.state == UIGestureRecognizerStateFailed || rotationGesture.state == UIGestureRecognizerStateCancelled) {
        self.layer.borderWidth = 0;
        self.layer.borderColor = nil;
    }else{
        self.layer.borderWidth = 1/_scale;
        self.layer.borderColor = BKEditImageTextFrameColor.CGColor;
    }
    
    rotationGesture.rotation = 0;
}

-(void)pinchGesture:(UIPinchGestureRecognizer*)pinchGesture
{
    _scale = _scale + (pinchGesture.scale - 1)/2;
    if (_scale > 1.5) {
        _scale = 1.5;
    }else if (_scale < 0.15) {
        _scale = 0.15;
    }
    [self resetTransform];
    
    if (pinchGesture.state == UIGestureRecognizerStateEnded || pinchGesture.state == UIGestureRecognizerStateFailed || pinchGesture.state == UIGestureRecognizerStateCancelled) {
        self.layer.borderWidth = 0;
        self.layer.borderColor = nil;
    }else{
        self.layer.borderWidth = 1/_scale;
        self.layer.borderColor = BKEditImageTextFrameColor.CGColor;
    }
    
    pinchGesture.scale = 1;
}

-(void)resetTransform
{
    self.transform = CGAffineTransformIdentity;
    self.transform = CGAffineTransformMakeRotation(self.rotation);
    self.transform = CGAffineTransformScale(self.transform, _scale, _scale);
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]] || [otherGestureRecognizer.bk_strTag isEqualToString:@"tap"]) {
        otherGestureRecognizer.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            otherGestureRecognizer.enabled = YES;
        });
    }
    return YES;
}

@end
