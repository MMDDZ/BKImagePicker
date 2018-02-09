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
@property (nonatomic,strong) UIImageView * line1;
@property (nonatomic,weak) UIButton * selectFirstLevelBtn;

@property (nonatomic,strong) UIView * drawTypeView;
@property (nonatomic,strong) UIImageView * line2;
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
        UIImage * masaike = [UIImage imageWithContentsOfFile:[bundlePath stringByAppendingString:@"/masaike.png"]];
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
        
        UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _firstLevelView.bk_width/4*3 - 6, _firstLevelView.bk_height)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsVerticalScrollIndicator = NO;
        [_firstLevelView addSubview:scrollView];
        
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        NSArray * imageArr_n = @[[bundlePath stringByAppendingString:@"/draw_n.png"],[bundlePath stringByAppendingString:@"/write_n.png"],[bundlePath stringByAppendingString:@"/rotation_n.png"],[bundlePath stringByAppendingString:@"/clip_n.png"]];
        NSArray * imageArr_s = @[[bundlePath stringByAppendingString:@"/draw_s.png"],[bundlePath stringByAppendingString:@"/write_s.png"],[bundlePath stringByAppendingString:@"/rotation_s.png"],[bundlePath stringByAppendingString:@"/clip_s.png"]];
        
        __block UIView * lastView;
        [imageArr_n enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, scrollView.bk_height);
            [button setImage:[UIImage imageWithContentsOfFile:obj] forState:UIControlStateNormal];
            [button setImage:[UIImage imageWithContentsOfFile:imageArr_s[idx]] forState:UIControlStateHighlighted];
            [button setImage:[UIImage imageWithContentsOfFile:imageArr_s[idx]] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = idx;
            [scrollView addSubview:button];
            
            lastView = button;
        }];
        scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), scrollView.bk_height);
        
        UIButton * sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(_firstLevelView.bk_width/4*3, (_firstLevelView.bk_height - 37)/2, _firstLevelView.bk_width/4-6, 37);
        [sendBtn setTitle:@"确认" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn setBackgroundColor:BKNavHighlightTitleColor];
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        sendBtn.layer.cornerRadius = 4;
        sendBtn.clipsToBounds = YES;
        [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_firstLevelView addSubview:sendBtn];
        
        _line1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _firstLevelView.bk_width, BK_ONE_PIXEL)];
        _line1.backgroundColor = BKLineColor;
        _line1.alpha = 0;
        [_firstLevelView addSubview:_line1];
    }
    return _firstLevelView;
}

-(void)editBtnClick:(UIButton*)button
{
    if (self.selectFirstLevelBtn == button) {
        return;
    }
    
    self.selectFirstLevelBtn.selected = NO;
    self.selectFirstLevelBtn = button;
    self.selectFirstLevelBtn.selected = YES;
    
    switch (button.tag) {
        case 0:
        {
            _selectEditType = BKEditImageSelectEditTypeDrawLine;
            _selectPaintingType = BKEditImageSelectPaintingTypeColor;
            _selectPaintingColor = self.colorArr[0];
            
            _paintingView.bk_y = 0;
            _paintingView.alpha = 1;
            _drawTypeView.bk_y = CGRectGetMaxY(_paintingView.frame);
            _drawTypeView.alpha = 1;
            _line2.alpha = 1;
            _firstLevelView.bk_y = CGRectGetMaxY(_drawTypeView.frame);
            _line1.alpha = 1;
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
            _line2.alpha = 0;
            _firstLevelView.bk_y = CGRectGetMaxY(_paintingView.frame);
            _line1.alpha = 1;
            self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
            
            if (self.selectTypeAction) {
                self.selectTypeAction();
            }
        }
            break;
        case 2:
        {
            _selectEditType = BKEditImageSelectEditTypeRotation;
            
            _paintingView.alpha = 0;
            _drawTypeView.alpha = 0;
            _line2.alpha = 0;
            _firstLevelView.bk_y = 0;
            _line1.alpha = 0;
            self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
            
            if (self.selectTypeAction) {
                self.selectTypeAction();
            }
        }
            break;
        case 3:
        {
            _selectEditType = BKEditImageSelectEditTypeClip;
            
            _paintingView.alpha = 0;
            _drawTypeView.alpha = 0;
            _firstLevelView.bk_y = 0;
            _line1.alpha = 0;
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
        [_drawTypeView addSubview:scrollView];
        
        NSString * bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        NSArray * imageArr_n = @[[bundlePath stringByAppendingString:@"/draw_n.png"],[bundlePath stringByAppendingString:@"/write_n.png"],[bundlePath stringByAppendingString:@"/rotation_n.png"],[bundlePath stringByAppendingString:@"/clip_n.png"]];
        NSArray * imageArr_s = @[[bundlePath stringByAppendingString:@"/draw_s.png"],[bundlePath stringByAppendingString:@"/write_s.png"],[bundlePath stringByAppendingString:@"/rotation_s.png"],[bundlePath stringByAppendingString:@"/clip_s.png"]];
        
        __block UIView * lastView;
        [imageArr_n enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, scrollView.bk_height);
            [button setImage:[UIImage imageWithContentsOfFile:obj] forState:UIControlStateNormal];
            [button setImage:[UIImage imageWithContentsOfFile:imageArr_s[idx]] forState:UIControlStateHighlighted];
            [button setImage:[UIImage imageWithContentsOfFile:imageArr_s[idx]] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(selectDrawTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = idx;
            [scrollView addSubview:button];
            
            lastView = button;
        }];
        scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), scrollView.bk_height);
        
        _line2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _drawTypeView.bk_width, BK_ONE_PIXEL)];
        _line2.backgroundColor = BKLineColor;
        _line2.alpha = 0;
        [_drawTypeView addSubview:_line2];
    }
    return _drawTypeView;
}

-(void)selectDrawTypeBtnClick:(UIButton*)button
{
    if (self.selectDrawTypeBtn == button) {
        return;
    }
    
    self.selectDrawTypeBtn.selected = NO;
    self.selectDrawTypeBtn = button;
    self.selectDrawTypeBtn.selected = YES;
}

#pragma mark - paintingView

-(UIView*)paintingView
{
    if (!_paintingView) {
        _paintingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, 40)];
        _paintingView.backgroundColor = [UIColor clearColor];
        _paintingView.alpha = 0;
        
        UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _paintingView.bk_width, _paintingView.bk_height)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsVerticalScrollIndicator = NO;
        [_paintingView addSubview:scrollView];
        
        __block UIView * lastView;
        [self.colorArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, scrollView.bk_height);
            
            [button addTarget:self action:@selector(selectDrawTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = idx;
            [scrollView addSubview:button];
            
            lastView = button;
        }];
        scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), scrollView.bk_height);
    }
    return _paintingView;
}

@end
