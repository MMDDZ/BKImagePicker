//
//  BKImageOriginalButton.m
//  BKImagePicker
//
//  Created by BIKE on 2018/4/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImageOriginalButton.h"
#import "BKTool.h"

@implementation BKImageOriginalButton

-(void)setTitle:(NSString *)title
{
    _title = title;
    
    [self setNeedsDisplay];
}

-(void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    
    [self setNeedsDisplay];
}

-(void)setIsSelect:(BOOL)isSelect
{
    _isSelect = isSelect;
    
    [self setNeedsDisplay];
}

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isSelect = NO;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer * selfTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selfTap)];
    [self addGestureRecognizer:selfTap];
}

-(void)selfTap
{
    _isSelect = !_isSelect;
    
    [self setNeedsDisplay];
    
    if (self.tapSelctAction) {
        self.tapSelctAction();
    }
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_isSelect) {
        CGContextSetFillColorWithColor(context, BKHighlightColor.CGColor);
        CGContextAddArc(context, 12, self.bk_height/2, 10, 0, 2*M_PI, 0);
        CGContextDrawPath(context, kCGPathFill);
        
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextMoveToPoint(context, 12 - 6, self.bk_height/2);
        CGContextAddLineToPoint(context, 12 - 2, self.bk_height/2 + 4);
        CGContextAddLineToPoint(context, 12 + 6, self.bk_height/2 - 4);
        CGContextSetLineWidth(context, 1.5);
        CGContextDrawPath(context, kCGPathStroke);
    }else{
        CGContextSetStrokeColorWithColor(context, [BKSelectNormalColor CGColor]);
        CGContextSetLineWidth(context, 1);
        CGContextAddArc(context, 12, self.bk_height/2, 10, 0, 2*M_PI, 0);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:_titleColor};
    [self.title drawWithRect:CGRectMake(28, 15, self.bk_width - 30, (self.bk_height - 15)/2) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
}

@end
