//
//  BKEditImageBottomView.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/9.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImageBottomView.h"
#import "BKTool.h"

@interface BKEditImageBottomView()

@property (nonatomic,strong) UIView * firstLevelView;
@property (nonatomic,strong) UIScrollView * firstLevelScrollView;
@property (nonatomic,weak) UIButton * selectFirstLevelBtn;
@property (nonatomic,strong) UIButton * cancelWriteBtn;
@property (nonatomic,strong) UIButton * affirmBtn;

@property (nonatomic,strong) UIView * drawTypeView;
@property (nonatomic,weak) UIButton * selectDrawTypeBtn;

@property (nonatomic,strong) UIView * paintingView;
@property (nonatomic,strong) UIScrollView * paintingScrollView;
@property (nonatomic,weak) UIButton * mosaicBtn;
@property (nonatomic,weak) UIButton * selectPaintingBtn;
@property (nonatomic,strong) UIButton * revocationBtn;
@property (nonatomic,strong) NSArray * colorArr;

@end

@implementation BKEditImageBottomView
@synthesize selectEditType = _selectEditType;
@synthesize selectPaintingType = _selectPaintingType;
@synthesize selectPaintingColor = _selectPaintingColor;

#pragma mark - 重新编辑文本

-(void)reeditWriteWithWriteStringColor:(UIColor *)color
{
    if (_paintingView) {
        [_paintingView removeFromSuperview];
        _paintingView = nil;
    }
    
    if (_drawTypeView) {
        [_drawTypeView removeFromSuperview];
        _drawTypeView = nil;
    }
    
    UIButton * button = (UIButton*)[_firstLevelScrollView viewWithTag:200];
    self.selectFirstLevelBtn = button;
    
    _selectEditType = BKEditImageSelectEditTypeWrite;
    _selectPaintingType = BKEditImageSelectPaintingTypeColor;
    _selectPaintingColor = color;
    
    if (!_paintingView) {
        [self addSubview:self.paintingView];
    }
    
    _paintingView.bk_y = 0;
    _firstLevelView.bk_y = CGRectGetMaxY(_paintingView.frame);
    self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
}

#pragma mark - NSNotification

-(void)keyboardWillShow:(NSNotification*)notification
{
    _paintingScrollView.bk_width = _paintingView.bk_width;
    _mosaicBtn.hidden = YES;
    _paintingScrollView.contentSize = CGSizeMake(CGRectGetMinX(_mosaicBtn.frame), _paintingScrollView.bk_height);
    _revocationBtn.hidden = YES;
    
    _firstLevelScrollView.hidden = YES;
    _cancelWriteBtn.hidden = NO;
    [_affirmBtn setTitle:@"完成" forState:UIControlStateNormal];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
    [self cancelEditOperation];
    
    _firstLevelScrollView.hidden = NO;
    _cancelWriteBtn.hidden = YES;
    [_affirmBtn setTitle:@"确认" forState:UIControlStateNormal];
}

#pragma mark - 选中裁剪选项

-(void)selectClipOption
{
    UIButton * button = (UIButton*)[_firstLevelScrollView viewWithTag:300];
    [self editBtnClick:button];
}

#pragma mark - 取消本次选中的编辑

-(void)cancelEditOperation
{
    [self editBtnClick:_selectFirstLevelBtn];
}

#pragma mark - init

-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, BK_SCREENW, BK_SYSTEM_TABBAR_UI_HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage * masaike = [[BKTool sharedManager] editImageWithImageName:@"masaike"];
        self.colorArr = @[[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],[UIColor blueColor],[UIColor purpleColor],[UIColor blackColor],[UIColor whiteColor],[UIColor lightGrayColor],masaike];
        
        [self addSubview:self.firstLevelView];
    }
    return self;
}

#pragma mark - firstLevelView

-(UIView*)firstLevelView
{
    if (!_firstLevelView) {
        
        _firstLevelView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, BK_SYSTEM_TABBAR_UI_HEIGHT)];
        _firstLevelView.backgroundColor = [UIColor clearColor];
        
        _firstLevelScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _firstLevelView.bk_width/5*4 - 6, _firstLevelView.bk_height)];
        _firstLevelScrollView.backgroundColor = [UIColor clearColor];
        _firstLevelScrollView.showsVerticalScrollIndicator = NO;
        _firstLevelScrollView.showsHorizontalScrollIndicator = NO;
        [_firstLevelView addSubview:_firstLevelScrollView];
        
        NSArray * imageArr_n = @[[[BKTool sharedManager] editImageWithImageName:@"draw_n"],
                                 [[BKTool sharedManager] editImageWithImageName:@"write_n"],
                                 [[BKTool sharedManager] editImageWithImageName:@"clip_n"]];
//        NSArray * imageArr_s = @[[[BKTool sharedManager] editImageWithImageName:@"draw_s"],
//                                 [[BKTool sharedManager] editImageWithImageName:@"write_s"],
//                                 [[BKTool sharedManager] editImageWithImageName:@"clip_s"]];
        
        __block UIView * lastView;
        [imageArr_n enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, self.firstLevelScrollView.bk_height);
            [button addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = (idx+1)*100;
            [self.firstLevelScrollView addSubview:button];
            
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((button.bk_width - 20)/2, (button.bk_height - 20)/2, 20, 20)];
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = obj;
            imageView.tag = button.tag+1;
            [button addSubview:imageView];
            
            lastView = button;
        }];
        _firstLevelScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), _firstLevelScrollView.bk_height);
        
        _cancelWriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelWriteBtn.frame = CGRectMake(6, (_firstLevelView.bk_height - 37)/2, _firstLevelView.bk_width/5-6, 37);
        [_cancelWriteBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelWriteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelWriteBtn setBackgroundColor:BKHighlightColor];
        _cancelWriteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _cancelWriteBtn.layer.cornerRadius = 4;
        _cancelWriteBtn.clipsToBounds = YES;
        [_cancelWriteBtn addTarget:self action:@selector(cancelWriteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _cancelWriteBtn.hidden = YES;
        [_firstLevelView addSubview:_cancelWriteBtn];
        
        _affirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _affirmBtn.frame = CGRectMake(_firstLevelView.bk_width/5*4, (_firstLevelView.bk_height - 37)/2, _firstLevelView.bk_width/5-6, 37);
        [_affirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        [_affirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_affirmBtn setBackgroundColor:BKHighlightColor];
        _affirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _affirmBtn.layer.cornerRadius = 4;
        _affirmBtn.clipsToBounds = YES;
        [_affirmBtn addTarget:self action:@selector(affirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_firstLevelView addSubview:_affirmBtn];
        
        UIImageView * line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _firstLevelView.bk_width, BK_ONE_PIXEL)];
        line.backgroundColor = BKLineColor;
        [_firstLevelView addSubview:line];
    }
    return _firstLevelView;
}

-(void)editBtnClick:(UIButton*)button
{
    NSArray * imageArr_n = @[[[BKTool sharedManager] editImageWithImageName:@"draw_n"],
                             [[BKTool sharedManager] editImageWithImageName:@"write_n"],
                             [[BKTool sharedManager] editImageWithImageName:@"clip_n"]];
    NSArray * imageArr_s = @[[[BKTool sharedManager] editImageWithImageName:@"draw_s"],
                             [[BKTool sharedManager] editImageWithImageName:@"write_s"],
                             [[BKTool sharedManager] editImageWithImageName:@"clip_s"]];
    
    if (_selectFirstLevelBtn) {
        UIImageView * oldImageView = (UIImageView*)[self.selectFirstLevelBtn viewWithTag:self.selectFirstLevelBtn.tag+1];
        oldImageView.image = imageArr_n[self.selectFirstLevelBtn.tag/100-1];
    }
    
    if (_paintingView) {
        [_paintingView removeFromSuperview];
        _paintingView = nil;
    }
    
    if (_drawTypeView) {
        [_drawTypeView removeFromSuperview];
        _drawTypeView = nil;
    }
    
    if (self.selectFirstLevelBtn == button) {
        
        self.selectFirstLevelBtn = nil;
        
        _selectEditType = BKEditImageSelectEditTypeNone;
        _selectPaintingType = BKEditImageSelectPaintingTypeNone;
        _selectPaintingColor = nil;
        
        _firstLevelView.bk_y = 0;
        self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
        
        if (self.selectTypeAction) {
            self.selectTypeAction();
        }
        
        return;
    }
    
    self.selectFirstLevelBtn = button;
    UIImageView * imageView = (UIImageView*)[self.selectFirstLevelBtn viewWithTag:self.selectFirstLevelBtn.tag+1];
    imageView.image = imageArr_s[self.selectFirstLevelBtn.tag/100-1];
    
    switch (button.tag/100-1) {
        case 0:
        {
            _selectEditType = BKEditImageSelectEditTypeDrawLine;
            _selectPaintingType = BKEditImageSelectPaintingTypeColor;
            _selectPaintingColor = self.colorArr[0];
            
            if (![[self subviews] containsObject:_paintingView]) {
                [self addSubview:self.paintingView];
            }
            if (![[self subviews] containsObject:_drawTypeView]) {
                [self addSubview:self.drawTypeView];
            }
            
            _paintingView.bk_y = 0;
            _drawTypeView.bk_y = CGRectGetMaxY(_paintingView.frame);
            _firstLevelView.bk_y = CGRectGetMaxY(_drawTypeView.frame);
            self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
        }
            break;
        case 1:
        {
            _selectEditType = BKEditImageSelectEditTypeWrite;
            _selectPaintingType = BKEditImageSelectPaintingTypeColor;
            _selectPaintingColor = self.colorArr[0];
            
            if (!_paintingView) {
                [self addSubview:self.paintingView];
            }
            
            _paintingView.bk_y = 0;
            _firstLevelView.bk_y = CGRectGetMaxY(_paintingView.frame);
            self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
        }
            break;
        case 2:
        {
            _selectEditType = BKEditImageSelectEditTypeClip;
            _selectPaintingType = BKEditImageSelectPaintingTypeNone;
            _selectPaintingColor = nil;
            
            _firstLevelView.bk_y = 0;
            self.bk_height = CGRectGetMaxY(_firstLevelView.frame);
        }
            break;
        default:
            break;
    }
    
    if (self.selectTypeAction) {
        self.selectTypeAction();
    }
}

-(void)cancelWriteBtnClick
{
    _isSaveEditWrite = NO;
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

-(void)affirmBtnClick
{
    if ([_affirmBtn.titleLabel.text isEqualToString:@"确认"]) {
        if (self.sendBtnAction) {
            self.sendBtnAction();
        }
    }else if ([_affirmBtn.titleLabel.text isEqualToString:@"完成"]) {
        _isSaveEditWrite = YES;
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
    }
}

#pragma mark - drawTypeView

-(UIView*)drawTypeView
{
    if (!_drawTypeView) {
        _drawTypeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, 40)];
        _drawTypeView.backgroundColor = [UIColor clearColor];
        
        UIScrollView * scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _drawTypeView.bk_width, _drawTypeView.bk_height)];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [_drawTypeView addSubview:scrollView];
        
        NSArray * imageArr_n = @[[[BKTool sharedManager] editImageWithImageName:@"line_n"],
                                 [[BKTool sharedManager] editImageWithImageName:@"circle_n"],
                                 [[BKTool sharedManager] editImageWithImageName:@"rounded_rectangle_n"],
                                 [[BKTool sharedManager] editImageWithImageName:@"arrow_n"]];
        NSArray * imageArr_s = @[[[BKTool sharedManager] editImageWithImageName:@"line_s"],
                                 [[BKTool sharedManager] editImageWithImageName:@"circle_s"],
                                 [[BKTool sharedManager] editImageWithImageName:@"rounded_rectangle_s"],
                                 [[BKTool sharedManager] editImageWithImageName:@"arrow_s"]];
        
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
            imageView.image = obj;
            imageView.tag = button.tag+1;
            [button addSubview:imageView];
            
            if (idx == 0) {
                self.selectDrawTypeBtn = button;
                imageView.image = imageArr_s[idx];
            }
            
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
    
    NSArray * imageArr_n = @[[[BKTool sharedManager] editImageWithImageName:@"line_n"],
                             [[BKTool sharedManager] editImageWithImageName:@"circle_n"],
                             [[BKTool sharedManager] editImageWithImageName:@"rounded_rectangle_n"],
                             [[BKTool sharedManager] editImageWithImageName:@"arrow_n"]];
    NSArray * imageArr_s = @[[[BKTool sharedManager] editImageWithImageName:@"line_s"],
                             [[BKTool sharedManager] editImageWithImageName:@"circle_s"],
                             [[BKTool sharedManager] editImageWithImageName:@"rounded_rectangle_s"],
                             [[BKTool sharedManager] editImageWithImageName:@"arrow_s"]];
    
    if (_selectDrawTypeBtn) {
        UIImageView * oldImageView = (UIImageView*)[self.selectDrawTypeBtn viewWithTag:self.selectDrawTypeBtn.tag+1];
        oldImageView.image = imageArr_n[self.selectDrawTypeBtn.tag/100-1];
    }
    self.selectDrawTypeBtn = button;
    UIImageView * imageView = (UIImageView*)[self.selectDrawTypeBtn viewWithTag:self.selectDrawTypeBtn.tag+1];
    imageView.image = imageArr_s[self.selectDrawTypeBtn.tag/100-1];
    
    switch (self.selectDrawTypeBtn.tag) {
        case 100:
        {
            _selectEditType = BKEditImageSelectEditTypeDrawLine;
        }
            break;
        case 200:
        {
            _selectEditType = BKEditImageSelectEditTypeDrawCircle;
        }
            break;
        case 300:
        {
            _selectEditType = BKEditImageSelectEditTypeDrawRoundedRectangle;
        }
            break;
        case 400:
        {
            _selectEditType = BKEditImageSelectEditTypeDrawArrow;
        }
            break;
        default:
            break;
    }
    
    if (_selectEditType != BKEditImageSelectEditTypeDrawLine) {
        if (!_mosaicBtn.hidden) {
            _mosaicBtn.hidden = YES;
            _paintingScrollView.contentSize = CGSizeMake(CGRectGetMinX(_mosaicBtn.frame), _paintingScrollView.bk_height);
            
            if (_selectPaintingType == BKEditImageSelectPaintingTypeMosaic) {
                UIButton * button = [_paintingScrollView viewWithTag:(([self.colorArr count] - 2) + 1)*100];
                [self selectPaintingTypeBtnClick:button];
            }
        }
    }else{
        if (_mosaicBtn.hidden) {
            _mosaicBtn.hidden = NO;
            _paintingScrollView.contentSize = CGSizeMake(CGRectGetMaxX(_mosaicBtn.frame), _paintingScrollView.bk_height);
        }
    }
    
    if (self.selectTypeAction) {
        self.selectTypeAction();
    }
}

#pragma mark - paintingView

-(UIView*)paintingView
{
    if (!_paintingView) {
        _paintingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, 40)];
        _paintingView.backgroundColor = [UIColor clearColor];
        
        _paintingScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _paintingView.bk_width/5*4 - 6, _paintingView.bk_height)];
        _paintingScrollView.backgroundColor = [UIColor clearColor];
        _paintingScrollView.showsVerticalScrollIndicator = NO;
        _paintingScrollView.showsHorizontalScrollIndicator = NO;
        [_paintingView addSubview:_paintingScrollView];
        
        __block UIView * lastView;
        [self.colorArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(idx*50, 0, 50, self.paintingScrollView.bk_height);
            [button addTarget:self action:@selector(selectPaintingTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = (idx+1)*100;
            [self.paintingScrollView addSubview:button];
            
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
                self.mosaicBtn = button;
            }
            imageView.layer.cornerRadius = 4;
            [button addSubview:imageView];
            
            if (self.selectPaintingColor) {
                if ([obj isKindOfClass:[UIColor class]]) {
                    if (CGColorEqualToColor(((UIColor*)obj).CGColor, self.selectPaintingColor.CGColor)) {
                        self.selectPaintingBtn = button;
                        imageBgView.backgroundColor = BKHighlightColor;
                    }
                }
            }else{
                if (idx == 0) {
                    self.selectPaintingBtn = button;
                    imageBgView.backgroundColor = BKHighlightColor;
                }
            }
            
            lastView = button;
        }];
        _paintingScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastView.frame), _paintingScrollView.bk_height);
        
        _revocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _revocationBtn.frame = CGRectMake(CGRectGetMaxX(_paintingScrollView.frame), 0, _paintingView.bk_width - CGRectGetMaxX(_paintingScrollView.frame), _paintingView.bk_height);
        [_revocationBtn addTarget:self action:@selector(revocationBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_paintingView insertSubview:_revocationBtn belowSubview:_paintingScrollView];
        
        UIImageView * revocationImageView = [[UIImageView alloc]initWithFrame:CGRectMake((_revocationBtn.bk_width - 20)/2, (_revocationBtn.bk_height - 20)/2, 20, 20)];
        revocationImageView.clipsToBounds = YES;
        revocationImageView.contentMode = UIViewContentModeScaleAspectFit;
        revocationImageView.image = [[BKTool sharedManager] editImageWithImageName:@"revocation"];
        [_revocationBtn addSubview:revocationImageView];
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, BK_ONE_PIXEL, _paintingView.bk_height)];
        line.backgroundColor = BKLineColor;
        [_revocationBtn addSubview:line];
        
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
    
    NSObject * obj = self.colorArr[self.selectPaintingBtn.tag/100-1];
    if ([obj isKindOfClass:[UIColor class]]) {
        _selectPaintingType = BKEditImageSelectPaintingTypeColor;
        _selectPaintingColor = (UIColor*)obj;
    }else if ([obj isKindOfClass:[UIImage class]]){
        _selectPaintingType = BKEditImageSelectPaintingTypeMosaic;
        _selectPaintingColor = nil;
    }
    
    if (self.selectTypeAction) {
        self.selectTypeAction();
    }
}

-(void)revocationBtnClick
{
    if (self.revocationAction) {
        self.revocationAction();
    }
}

@end
