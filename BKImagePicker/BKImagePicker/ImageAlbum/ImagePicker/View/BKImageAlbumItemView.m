//
//  BKImageAlbumItemView.m
//  BKImagePicker
//
//  Created by BIKE on 16/11/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImageAlbumItemView.h"
#import "UIView+BKImagePicker.h"
#import "BKImagePickerMacro.h"

@interface BKImageAlbumItemView()

@property (nonatomic,strong) UILabel * markTitle;
@property (nonatomic,strong) UILabel * time;

@end

@implementation BKImageAlbumItemView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = BKClearColor;
        
        [self addSubview:self.markTitle];
        [self addSubview:self.time];
    }
    return self;
}

-(UILabel*)markTitle
{
    if (!_markTitle) {
        _markTitle = [[UILabel alloc]initWithFrame:CGRectMake(4, self.bk_height-16, self.bk_width/2 - 13, 14)];
        _markTitle.textColor = BKImagePickerVideoMarkColor;
        _markTitle.font = [UIFont systemFontOfSize:12*BK_SCREENW/414];
    }
    return _markTitle;
}

-(UILabel *)time
{
    if (!_time) {
        _time = [[UILabel alloc]initWithFrame:CGRectMake(self.bk_width/2 - 4, self.bk_height-16, self.bk_width/2, 14)];
        _time.textColor = BKImagePickerVideoTimeTitleColor;
        _time.font = [UIFont systemFontOfSize:12*BK_SCREENW/414];
        _time.textAlignment = NSTextAlignmentRight;
    }
    return _time;
}

-(void)photoType:(BKSelectPhotoType)photoType allSecond:(NSInteger)allSecond
{
    if (photoType == BKSelectPhotoTypeImage){

        _markTitle.text = @"";
        _time.text = @"";
        
    }else if (photoType == BKSelectPhotoTypeGIF){

        NSShadow *shadow = [[NSShadow alloc]init];
        shadow.shadowOffset = CGSizeMake(1, 1);
        shadow.shadowColor = BKImagePickerVideoShadowColor;
        shadow.shadowBlurRadius = 1;
        
        NSAttributedString * markTitle = [[NSAttributedString alloc]initWithString:@"GIF" attributes:@{NSStrokeWidthAttributeName:@(3),NSStrokeColorAttributeName:BKImagePickerVideoMarkColor,NSShadowAttributeName:shadow}];
        _markTitle.attributedText = markTitle;
        
        _time.text = @"";
        
    }else if (photoType == BKSelectPhotoTypeVideo) {

        NSString * timeStr = @"";
        if (allSecond > 60) {
            NSInteger second = allSecond%60;
            NSInteger minute = allSecond/60;
            timeStr = [NSString stringWithFormat:@"%02ld:%02ld",minute,second];
        }else{
            timeStr = [NSString stringWithFormat:@"00:%02ld",allSecond];
        }
        
        NSShadow *shadow = [[NSShadow alloc]init];
        shadow.shadowOffset = CGSizeMake(1, 1);
        shadow.shadowColor = BKImagePickerVideoShadowColor;
        shadow.shadowBlurRadius = 1;
        
        NSAttributedString * markTitle = [[NSAttributedString alloc]initWithString:@"Video" attributes:@{NSStrokeWidthAttributeName:@(3),NSStrokeColorAttributeName:BKImagePickerVideoMarkColor,NSShadowAttributeName:shadow}];
        _markTitle.attributedText = markTitle;
        
        NSAttributedString * string = [[NSAttributedString alloc]initWithString:timeStr attributes:@{NSStrokeWidthAttributeName:@(3),NSStrokeColorAttributeName:BKImagePickerVideoTimeTitleColor,NSShadowAttributeName:shadow}];
        _time.attributedText = string;
    }
}

//-(void)addShadow
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGPathRef pathRef = CGPathCreateWithRect(self.frame, nil);
//    CGContextAddPath(context, pathRef);
//    CGContextClip(context);
//    
//    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
//    CGFloat colors[] = {
//        102.0/255.0,102.0/255.0,102.0/255.0,0,
//        0.0/255.0,0.0/255.0,0.0/255.0,0.8,
//    };
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
//    CGColorSpaceRelease(rgb);
//    
//    CGPoint start = CGPointMake(0,self.bk_height - 20);
//    CGPoint end = CGPointMake(0,self.bk_height);
//    
//    CGContextDrawLinearGradient(context, gradient ,start ,end ,kCGGradientDrawsBeforeStartLocation);
//    CGGradientRelease(gradient);
//}

@end
