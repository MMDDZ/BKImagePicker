//
//  SelectButton.m
//  BKImagePicker
//
//  Created by iMac on 16/10/18.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "SelectButton.h"

@interface SelectButton()

@property (nonatomic,strong) UILabel * titleLab;

@end

@implementation SelectButton

-(void)setTitle:(NSString *)title
{
    if (_titleLab) {
        if ([title length] == 0) {
            _titleLab.text = @"";
            _titleLab.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        }else{
            _titleLab.text = title;
            _titleLab.backgroundColor = [UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1];
        }
    }
}

-(UILabel*)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-20)/2.0f, (self.frame.size.height-20)/2.0f, 20, 20)];
        _titleLab.font = [UIFont systemFontOfSize:12];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
        _titleLab.text = @"";
        _titleLab.clipsToBounds = YES;
        _titleLab.layer.cornerRadius = _titleLab.frame.size.width/2.0f;
        _titleLab.layer.borderColor = [UIColor whiteColor].CGColor;
        _titleLab.layer.borderWidth = 1;
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
        
        [self addSubview:[self titleLab]];
    }
    return self;
}

-(void)selectClickNum:(NSInteger)num addMethod:(void (^)())method
{
    if ([_titleLab.text length] == 0) {
        
        [UIView animateWithDuration:0.25 animations:^{
            _titleLab.transform = CGAffineTransformMakeScale(1.15, 1.15);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                _titleLab.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }];
        
        _titleLab.text = [NSString stringWithFormat:@"%ld",num];
        _titleLab.backgroundColor = [UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1];
        
        if (method) {
            method();
        }
    }else{
        _titleLab.text = @"";
        _titleLab.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    }
}

@end
