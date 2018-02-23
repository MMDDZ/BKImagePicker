//
//  BKEditImageBottomView.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageBottomView.h"
#import "BKImagePickerConst.h"

@interface BKEditImageBottomView()

@property (nonatomic,strong) UIView * firstLevelView;
@property (nonatomic,weak) UIButton * selectFirstLevelBtn;

@property (nonatomic,strong) UIView * drawTypeView;
@property (nonatomic,weak) UIButton * selectDrawTypeBtn;

@property (nonatomic,strong) UIView * paintingView;
@property (nonatomic,weak) UIButton * selectPaintingBtn;
@property (nonatomic,strong) NSArray * colorArr;

@end

@implementation BKEditImageBottomView
@synthesize selectEditType = _selectEditType;
@synthesize selectPaintingType = _selectPaintingType;
@synthesize selectPaintingColor = _selectPaintingColor;

#pragma mark - init

-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, BK_SCREENW, BK_SYSTEM_TABBAR_UI_HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        UIImage * masaike = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/EditImage/masaike.png"]];
        self.colorArr = @[[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor],[UIColor blackColor],[UIColor whiteColor],[UIColor lightGrayColor],masaike];
        
        [self addSubview:self.firstLevelView];
        [self addSubview:self.drawTypeView];
        [self addSubview:self.paintingView];
    }
    return self;
}

#pragma mark - firstLevelView

-(UIView*)firstLevelView
{
    if (!_firstLevelView) {
        
        _firstLevelView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, BK_SYSTEM_TABBAR_UI_HEIGHT)];
        _firstLevelView.backgroundColor = [UIColor clearColor];
        
        UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _firstLevelView.bk_width/5*4 - 6, _firstLevelView.bk_height)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [_firstLevelView addSubview:scrollView];
        
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        NSArray * imageArr_n = @[[bundlePath stringByAppendingString:@"/EditImage/draw_n.png"],[bundlePath stringByAppendingString:@"/EditImage/write_n.png"],[bundlePath stringByAppendingString:@"/EditImage/clip_n.png"],[bundlePath stringByAppendingString:@"/EditImage/rotation_n.png"]];
        NSArray * imageArr_s = @[[bundlePath stringByAppendingString:@"/EditImage/draw_s.png"],[bundlePath stringByAppendingString:@"/EditImage/write_s.png"],[bundlePath stringByAppendingString:@"/EditImage/clip_s.png"],[bundlePath stringByAppendingString:@"/EditImage/rotation_s.png"]];
        
        __block UIView * lastView;
        [imageArr_n enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, scrollView.bk_height);
            [button addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = (idx+1)*100;
            [scrollView addSubview:button];
            
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((button.bk_width - 20)/2, (button.bk_height - 20)/2, 20, 20)];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = [UIImage imageWithContentsOfFile:obj];
            imageView.tag = button.tag+1;
            [button addSubview:imageView];
            
            lastView = button;
        }];
        scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), scrollView.bk_height);
        
        UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(_firstLevelView.bk_width/5*4, (_firstLevelView.bk_height - 37)/2, _firstLevelView.bk_width/5-6, 37);
        [sendBtn setTitle:@"确认" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn setBackgroundColor:BKHighlightColor];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        sendBtn.layer.cornerRadius = 4;
        sendBtn.clipsToBounds = YES;
        [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_firstLevelView addSubview:sendBtn];
        
        UIImageView * line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _firstLevelView.bk_width, BK_ONE_PIXEL)];
        line.backgroundColor = BKLineColor;
        [_firstLevelView addSubview:line];
    }
    return _firstLevelView;
}

-(void)editBtnClick:(UIButton*)button
{
    if (self.selectFirstLevelBtn == button) {
        return;
    }
    
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
    NSArray * imageArr_n = @[[bundlePath stringByAppendingString:@"/EditImage/draw_n.png"],[bundlePath stringByAppendingString:@"/EditImage/write_n.png"],[bundlePath stringByAppendingString:@"/EditImage/clip_n.png"],[bundlePath stringByAppendingString:@"/EditImage/rotation_n.png"]];
    NSArray * imageArr_s = @[[bundlePath stringByAppendingString:@"/EditImage/draw_s.png"],[bundlePath stringByAppendingString:@"/EditImage/write_s.png"],[bundlePath stringByAppendingString:@"/EditImage/clip_s.png"],[bundlePath stringByAppendingString:@"/EditImage/rotation_s.png"]];
    
    if (_selectFirstLevelBtn) {
        UIImageView * oldImageView = (UIImageView*)[self.selectFirstLevelBtn viewWithTag:self.selectFirstLevelBtn.tag+1];
        oldImageView.image = [UIImage imageWithContentsOfFile:imageArr_n[self.selectFirstLevelBtn.tag/100-1]];
    }
    self.selectFirstLevelBtn = button;
    UIImageView * imageView = (UIImageView*)[self.selectFirstLevelBtn viewWithTag:self.selectFirstLevelBtn.tag+1];
    imageView.image = [UIImage imageWithContentsOfFile:imageArr_s[self.selectFirstLevelBtn.tag/100-1]];
    
    switch (button.tag/100-1) {
        case 0:
        {
            _selectEditType = BKEditImageSelectEditTypeDrawLine;
            _selectPaintingType = BKEditImageSelectPaintingTypeColor;
            _selectPaintingColor = self.colorArr[0];
            
            _paintingView.bk_y = 0;
            _paintingView.alpha = 1;
            _drawTypeView.bk_y = CGRectGetMaxY(_paintingView.frame);
            _drawTypeView.alpha = 1;
            _firstLevelView.bk_y = CGRectGetMaxY(_drawTypeView.frame);
            self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
            
            if (self.selectTypeAction) {
                self.selectTypeAction();
            }
        }
            break;
        case 1:
        {
            _selectEditType = BKEditImageSelectEditTypeWrite;
            _selectPaintingType = BKEditImageSelectPaintingTypeColor;
            _selectPaintingColor = self.colorArr[0];
            
            _paintingView.bk_y = 0;
            _paintingView.alpha = 1;
            _drawTypeView.alpha = 0;
            _firstLevelView.bk_y = CGRectGetMaxY(_paintingView.frame);
            self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
            
            if (self.selectTypeAction) {
                self.selectTypeAction();
            }
        }
            break;
        case 2:
        {
            _selectEditType = BKEditImageSelectEditTypeClip;
            
            _paintingView.alpha = 0;
            _drawTypeView.alpha = 0;
            _firstLevelView.bk_y = 0;
            self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
            
            if (self.selectTypeAction) {
                self.selectTypeAction();
            }
        }
            break;
        case 3:
        {
            _selectEditType = BKEditImageSelectEditTypeRotation;
            
            _paintingView.alpha = 0;
            _drawTypeView.alpha = 0;
            _firstLevelView.bk_y = 0;
            self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
            
            if (self.selectTypeAction) {
                self.selectTypeAction();
            }
        }
            break;
        default:
            break;
    }
}

-(void)sendBtnClick
{
    if (self.sendBtnAction) {
        self.sendBtnAction();
    }
}

#pragma mark - drawTypeView

-(UIView*)drawTypeView
{
    if (!_drawTypeView) {
        _drawTypeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, 40)];
        _drawTypeView.backgroundColor = [UIColor clearColor];
        _drawTypeView.alpha = 0;
        
        UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _drawTypeView.bk_width, _drawTypeView.bk_height)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [_drawTypeView addSubview:scrollView];
        
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        NSArray * imageArr_n = @[[bundlePath stringByAppendingString:@"/EditImage/line_n.png"],[bundlePath stringByAppendingString:@"/EditImage/circle_n.png"],[bundlePath stringByAppendingString:@"/EditImage/rounded_rectangle_n.png"],[bundlePath stringByAppendingString:@"/EditImage/arrow_n.png"]];
        NSArray * imageArr_s = @[[bundlePath stringByAppendingString:@"/EditImage/line_s.png"],[bundlePath stringByAppendingString:@"/EditImage/circle_s.png"],[bundlePath stringByAppendingString:@"/EditImage/rounded_rectangle_s.png"],[bundlePath stringByAppendingString:@"/EditImage/arrow_s.png"]];
        
        __block UIView * lastView;
        [imageArr_n enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, scrollView.bk_height);
            [button addTarget:self action:@selector(selectDrawTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = (idx+1)*100;
            [scrollView addSubview:button];
            
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((button.bk_width - 20)/2, (button.bk_height - 20)/2, 20, 20)];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = [UIImage imageWithContentsOfFile:obj];
            imageView.tag = button.tag+1;
            [button addSubview:imageView];
            
            lastView = button;
        }];
        scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), scrollView.bk_height);
        
        UIImageView * line2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _drawTypeView.bk_width, BK_ONE_PIXEL)];
        line2.backgroundColor = BKLineColor;
        [_drawTypeView addSubview:line2];
    }
    return _drawTypeView;
}

-(void)selectDrawTypeBtnClick:(UIButton*)button
{
    if (self.selectDrawTypeBtn == button) {
        return;
    }
    
    NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
    NSArray * imageArr_n = @[[bundlePath stringByAppendingString:@"/EditImage/line_n.png"],[bundlePath stringByAppendingString:@"/EditImage/circle_n.png"],[bundlePath stringByAppendingString:@"/EditImage/rounded_rectangle_n.png"],[bundlePath stringByAppendingString:@"/EditImage/arrow_n.png"]];
    NSArray * imageArr_s = @[[bundlePath stringByAppendingString:@"/EditImage/line_s.png"],[bundlePath stringByAppendingString:@"/EditImage/circle_s.png"],[bundlePath stringByAppendingString:@"/EditImage/rounded_rectangle_s.png"],[bundlePath stringByAppendingString:@"/EditImage/arrow_s.png"]];
    
    if (_selectDrawTypeBtn) {
        UIImageView * oldImageView = (UIImageView*)[self.selectDrawTypeBtn viewWithTag:self.selectDrawTypeBtn.tag+1];
        oldImageView.image = [UIImage imageWithContentsOfFile:imageArr_n[self.selectDrawTypeBtn.tag/100-1]];
    }
    self.selectDrawTypeBtn = button;
    UIImageView * imageView = (UIImageView*)[self.selectDrawTypeBtn viewWithTag:self.selectDrawTypeBtn.tag+1];
    imageView.image = [UIImage imageWithContentsOfFile:imageArr_s[self.selectDrawTypeBtn.tag/100-1]];
}

#pragma mark - paintingView

-(UIView*)paintingView
{
    if (!_paintingView) {
        _paintingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, 40)];
        _paintingView.backgroundColor = [UIColor clearColor];
        _paintingView.alpha = 0;
        
        UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _paintingView.bk_width/5*4 - 6, _paintingView.bk_height)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [_paintingView addSubview:scrollView];
        
        __block UIView * lastView;
        [self.colorArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, scrollView.bk_height);
            [button addTarget:self action:@selector(selectPaintingTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = (idx+1)*100;
            [scrollView addSubview:button];
            
            UIImageView * imageBgView = [[UIImageView alloc]initWithFrame:CGRectMake((button.bk_width - 25)/2, (button.bk_height - 25)/2, 25, 25)];
            imageBgView.tag = button.tag+1;
            imageBgView.clipsToBounds = YES;
            imageBgView.layer.cornerRadius = 6;
            [button addSubview:imageBgView];
            
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((button.bk_width - 20)/2, (button.bk_height - 20)/2, 20, 20)];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            if ([obj isKindOfClass:[UIColor class]]) {
                imageView.backgroundColor = obj;
            }else if ([obj isKindOfClass:[UIImage class]]){
                imageView.image = obj;
            }
            imageView.layer.cornerRadius = 4;
            [button addSubview:imageView];
            
            lastView = button;
        }];
        scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), scrollView.bk_height);
        
        UIButton * revocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        revocationBtn.frame = CGRectMake(CGRectGetMaxX(scrollView.frame), 0, _paintingView.bk_width - CGRectGetMaxX(scrollView.frame), _paintingView.bk_height);
        [revocationBtn addTarget:self action:@selector(revocationBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_paintingView addSubview:revocationBtn];
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(revocationBtn.bk_x, 0, BK_ONE_PIXEL, _paintingView.bk_height)];
        line.backgroundColor = BKLineColor;
        [_paintingView addSubview:line];
        
    }
    return _paintingView;
}

-(void)selectPaintingTypeBtnClick:(UIButton*)button
{
    if (self.selectPaintingBtn == button) {
        return;
    }
    
    if (_selectPaintingBtn) {
        UIImageView * oldImageBgView = (UIImageView*)[self.selectPaintingBtn viewWithTag:self.selectPaintingBtn.tag+1];
        oldImageBgView.backgroundColor = [UIColor clearColor];
    }
    self.selectPaintingBtn = button;
    UIImageView * imageBgView = (UIImageView*)[self.selectPaintingBtn viewWithTag:self.selectPaintingBtn.tag+1];
    imageBgView.backgroundColor = BKHighlightColor;
}

-(void)revocationBtnClick
{
    
}

@end
