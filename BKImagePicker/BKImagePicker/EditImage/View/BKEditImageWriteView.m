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
    
    CGFloat width = [[BKTool sharedManager] sizeWithString:_writeString UIHeight:MAXFLOAT font:_writeFont?_writeFont:[UIFont systemFontOfSize:20]].width + 40;
    if (width > BK_SCREENW - 40) {
        width = BK_SCREENW - 40;
        CGFloat height = [[BKTool sharedManager] sizeWithString:_writeString UIWidth:width font:_writeFont?_writeFont:[UIFont systemFontOfSize:20]].height + 40;
        self.frame = CGRectMake((BK_SCREENW - width)/2, (BK_SCREENH - height)/2, width, height);
    }else {
        self.frame = CGRectMake((BK_SCREENW - width)/2, (BK_SCREENH - 60)/2, width, 60);
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
    
    NSDictionary * attributes = @{NSFontAttributeName:_writeFont?_writeFont:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:_writeColor?_writeColor:[UIColor redColor]};
    [self.writeString drawWithRect:self.bounds options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    
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
    
}

-(void)panGesture:(UIPanGestureRecognizer*)panGesture
{
    CGPoint translation = [panGesture translationInView:[UIApplication sharedApplication].keyWindow];
    
    self.bk_centerX = self.bk_centerX + translation.x/2;
    self.bk_centerY = self.bk_centerY + translation.y/2;
    
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
}

-(void)rotationGesture:(UIRotationGestureRecognizer*)rotationGesture
{
    self.rotation = self.rotation + rotationGesture.rotation/2;
    [self resetTransform];
    rotationGesture.rotation = 0;
}

-(void)pinchGesture:(UIPinchGestureRecognizer*)pinchGesture
{
    _scale = _scale + (pinchGesture.scale - 1)/2;
    if (_scale > 5) {
        _scale = 5;
    }else if (_scale < 0.5) {
        _scale = 0.5;
    }
    [self resetTransform];
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
