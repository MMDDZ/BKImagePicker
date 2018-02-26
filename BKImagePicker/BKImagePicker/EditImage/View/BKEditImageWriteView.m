//
//  BKEditImageWriteView.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/23.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageWriteView.h"
#import "BKImagePickerConst.h"

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
    
    _width = [[BKTool sharedManager] sizeWithString:_writeString UIHeight:MAXFLOAT font:[UIFont systemFontOfSize:30]].width + 20;
    if (_width > BK_SCREENW - 20) {
        _width = BK_SCREENW - 20;
    }
    
    _height = [[BKTool sharedManager] sizeWithString:_writeString UIWidth:_width font:[UIFont systemFontOfSize:30]].height + 20;
    
    self.transform = CGAffineTransformIdentity;
    
    if (CGRectEqualToRect(self.frame, CGRectZero)) {
        self.frame = CGRectMake((BK_SCREENW - _width)/2, (BK_SCREENH - _width)/2, _width, _height);
    }else{
        self.bk_width = _width;
        self.bk_height = _height;
    }
    
    [self setNeedsDisplay];
}

#pragma mark - init

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGesture];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addGesture];
    }
    return self;
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:30],NSForegroundColorAttributeName:_writeColor?_writeColor:[UIColor redColor]};
    [self.writeString drawWithRect:CGRectMake(10, 10, self.bk_width - 20, self.bk_height - 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    [self resetTransform];
}

#pragma mark - 手势

-(void)addGesture
{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesture:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    UIRotationGestureRecognizer * rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGesture:)];
    rotationGesture.delegate = self;
    [self addGestureRecognizer:rotationGesture];
    
    _scale = 1;
    
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
    
    self.bk_centerX = self.bk_centerX + translation.x/2;
    self.bk_centerY = self.bk_centerY + translation.y/2;
    
    if (self.moveWriteAction) {
        self.moveWriteAction(self,panGesture);
    }
    
    if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateFailed || panGesture.state == UIGestureRecognizerStateCancelled) {
        self.layer.borderWidth = 0;
        self.layer.borderColor = nil;
    }else{
        self.layer.borderWidth = 1/_scale;
        self.layer.borderColor = BKHighlightColor.CGColor;
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
        self.layer.borderColor = BKHighlightColor.CGColor;
    }
    
    rotationGesture.rotation = 0;
}

-(void)pinchGesture:(UIPinchGestureRecognizer*)pinchGesture
{
    _scale = _scale + (pinchGesture.scale - 1)/2;
    if (_scale > 2.5) {
        _scale = 2.5;
    }else if (_scale < 0.5) {
        _scale = 0.5;
    }
    [self resetTransform];
    
    if (pinchGesture.state == UIGestureRecognizerStateEnded || pinchGesture.state == UIGestureRecognizerStateFailed || pinchGesture.state == UIGestureRecognizerStateCancelled) {
        self.layer.borderWidth = 0;
        self.layer.borderColor = nil;
    }else{
        self.layer.borderWidth = 1/_scale;
        self.layer.borderColor = BKHighlightColor.CGColor;
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
    return YES;
}

@end
