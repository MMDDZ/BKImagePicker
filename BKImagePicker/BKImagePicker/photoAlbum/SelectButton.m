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
            [self setImage:[UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/no_select_image.png"]] forState:UIControlStateNormal];
        }else{
            _titleLab.text = title;
            [self setImage:[UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/select_image.png"]] forState:UIControlStateNormal];
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

-(instancetype)initSelectButtonWithFrame:(CGRect)frame
{
    self = [SelectButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        self.frame = frame;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setImage:[UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/no_select_image.png"]] forState:UIControlStateNormal];
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        self.clipsToBounds = YES;
        
        [self addSubview:[self titleLab]];
    }
    return self;
}

-(void)selectClickNum:(NSInteger)num addMethod:(void (^)())method
{
    if ([_titleLab.text length] == 0) {
        
        [self setImage:[UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/select_image.png"]] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.transform = CGAffineTransformMakeScale(1.15, 1.15);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }];
        
        _titleLab.text = [NSString stringWithFormat:@"%ld",num];

    }else{
        
        [self setImage:[UIImage imageWithContentsOfFile:[self.bundlePath stringByAppendingString:@"/no_select_image.png"]] forState:UIControlStateNormal];
        
        _titleLab.text = @"";
    }
    
    if (method) {
        method();
    }
}

@end
