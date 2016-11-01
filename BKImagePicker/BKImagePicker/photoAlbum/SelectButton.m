//
//  SelectButton.m
//  BKImagePicker
//
//  Created by iMac on 16/10/18.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "SelectButton.h"

@interface SelectButton()

@property (nonatomic,copy) NSString * bundlePath;

@property (nonatomic,strong) UILabel * titleLab;

@property (nonatomic,strong) UIImageView * showImageView;

@end

@implementation SelectButton

-(NSString*)bundlePath
{
    if (!_bundlePath) {
        _bundlePath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
    }
    return _bundlePath;
}

-(void)setTitle:(NSString *)title
{
    if (_titleLab) {
        if ([title length] == 0) {
            _titleLab.text = @"";
            _showImageView.image = [UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/no_select_image.png"]];
        }else{
            _titleLab.text = title;
            _showImageView.image = [UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/select_image.png"]];
        }
    }
}

-(UILabel*)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-20)/2.0f, (self.frame.size.height-20)/2.0f, 20, 20)];
        _titleLab.font = [UIFont systemFontOfSize:12];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.text = @"";
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.tag = 1;
    }
    return _titleLab;
}

-(UIImageView*)showImageView
{
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc]initWithFrame:CGRectMake(4, 4, self.frame.size.width-8, self.frame.size.height-8)];
        _showImageView.image = [UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/select_image.png"]];
    }
    return _showImageView;
}

-(instancetype)initSelectButtonWithFrame:(CGRect)frame
{
    self = [SelectButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        self.frame = frame;
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:[self showImageView]];
        [self addSubview:[self titleLab]];
    }
    return self;
}

-(void)selectClickNum:(NSInteger)num addMethod:(void (^)())method
{
    if ([_titleLab.text length] == 0) {
        
        _showImageView.image = [UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/select_image.png"]];
        
        [UIView animateWithDuration:0.25 animations:^{
            _showImageView.transform = CGAffineTransformMakeScale(1.15, 1.15);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                _showImageView.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }];
        
        _titleLab.text = [NSString stringWithFormat:@"%ld",num];

    }else{
        
        _showImageView.image = [UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/no_select_image.png"]];
       
        _titleLab.text = @"";
    }
    
    if (method) {
        method();
    }
}

@end
