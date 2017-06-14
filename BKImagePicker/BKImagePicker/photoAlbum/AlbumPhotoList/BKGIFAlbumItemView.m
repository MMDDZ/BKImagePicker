//
//  BKGIFAlbumItemView.m
//  BKImagePicker
//
//  Created by iMac on 16/11/2.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKGIFAlbumItemView.h"
#import "BKImagePickerConst.h"

@implementation BKGIFAlbumItemView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
    
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPathRef pathRef = CGPathCreateWithRect(self.frame, nil);
    CGContextAddPath(context, pathRef);
    CGContextClip(context);
    
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colors[] = {
        102.0/255.0,102.0/255.0,102.0/255.0,0,
        0.0/255.0,0.0/255.0,0.0/255.0,0.8,
    };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    CGColorSpaceRelease(rgb);
    
    CGPoint start = CGPointMake(0,self.bk_height - 20);
    CGPoint end = CGPointMake(0,self.bk_height);
    
    CGContextDrawLinearGradient(context, gradient ,start ,end ,kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:[UIColor whiteColor]};
    [@"GIF" drawWithRect:CGRectMake(0, self.bk_height-16, self.bk_width, 14) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
}

@end
