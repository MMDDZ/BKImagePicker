//
//  BKImageTakePhotoBtn.m
//  guoguanjuyanglao
//
//  Created by BIKE on 2017/12/21.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKImageTakePhotoBtn.h"
#import "BKTool.h"

typedef NS_ENUM(NSUInteger, BKShutterState) {
    BKShutterStateNormal = 0,
    BKShutterStateLongPress
};

@interface BKImageTakePhotoBtn()

@property (nonatomic,strong) UIView * middle_circle_whiteView;

@property (nonatomic,assign) BKShutterState shutterState;

@end

@implementation BKImageTakePhotoBtn

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UIView * bgView = [[UIView alloc]initWithFrame:self.bounds];
        bgView.clipsToBounds = YES;
        bgView.layer.cornerRadius = bgView.bk_height/2;
        bgView.userInteractionEnabled = NO;
        [self addSubview:bgView];
        
        UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView * circle_bgView = [[UIVisualEffectView alloc] initWithEffect:effect];
        circle_bgView.frame = self.bounds;
        [bgView addSubview:circle_bgView];
        
        _middle_circle_whiteView = [[UIView alloc]initWithFrame:CGRectMake(self.bk_width/8, self.bk_height/8, self.bk_width/4*3, self.bk_height/4*3)];
        _middle_circle_whiteView.clipsToBounds = YES;
        _middle_circle_whiteView.layer.cornerRadius = _middle_circle_whiteView.bk_height/2;
        _middle_circle_whiteView.backgroundColor = [UIColor whiteColor];
        _middle_circle_whiteView.userInteractionEnabled = NO;
        [self addSubview:_middle_circle_whiteView];
        
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(selfLongPress:)];
        longPress.minimumPressDuration = 0.01;
        [self addGestureRecognizer:longPress];
        
    }
    return self;
}

#pragma mark - 长按快门按钮

-(void)selfLongPress:(UILongPressGestureRecognizer*)longPress
{
    //记录上一次手势的位置
    static CGPoint startPoint;
    
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan:
        {
            _shutterState = BKShutterStateLongPress;
            
            startPoint = [longPress locationInView:self];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat tranX = [longPress locationOfTouch:0 inView:self].x - startPoint.x;
            CGFloat tranY = [longPress locationOfTouch:0 inView:self].y - startPoint.y;
            
            if (fabs(tranX) > self.bk_width || fabs(tranY) > self.bk_height) {
                _shutterState = BKShutterStateNormal;
            }else{
                _shutterState = BKShutterStateLongPress;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (_shutterState == BKShutterStateLongPress) {
                [self tapShutterAction];
            }
            
            _shutterState = BKShutterStateNormal;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            _shutterState = BKShutterStateNormal;
        }
            break;
        default:
            break;
    }
    
    [self settingShutterState:_shutterState];
}

-(void)settingShutterState:(BKShutterState)state
{
    [UIView animateWithDuration:0.1 animations:^{
        if (state == BKShutterStateNormal) {
            self.middle_circle_whiteView.transform = CGAffineTransformIdentity;
        }else if (state == BKShutterStateLongPress) {
            self.middle_circle_whiteView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }
    }];
}

-(void)tapShutterAction
{
    if (self.shutterAction) {
        self.shutterAction();
    }
}

@end
