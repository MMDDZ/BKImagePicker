//
//  BKImageAlbumItemSelectButton.m
//  BKImagePicker
//
//  Created by iMac on 16/10/18.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImageAlbumItemSelectButton.h"
#import "BKImagePickerConst.h"

@interface BKImageAlbumItemSelectButton()

@property (nonatomic,strong) NSString * showTitle;
@property (nonatomic,strong) UIColor * fillColor;

@property (nonatomic,assign) BOOL isAnimate;

@end

@implementation BKImageAlbumItemSelectButton

-(void)setTitle:(NSString *)title
{
    if ([title length] == 0) {
        self.showTitle = @"";
        self.fillColor = BKSelectImageCircleNormalColor;
    }else{
        self.showTitle = title;
        self.fillColor = BKSelectImageCircleHighlightColor;
    }
    
    [self setNeedsDisplay];
}

-(NSString*)showTitle
{
    if (!_showTitle) {
        _showTitle = @"";
    }
    return _showTitle;
}

-(UIColor*)fillColor
{
    if (!_fillColor) {
        _fillColor = BKSelectImageCircleNormalColor;
    }
    return _fillColor;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer * selfRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selfRecognizer)];
    [self addGestureRecognizer:selfRecognizer];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetLineWidth(context, 1.5);
    CGContextAddArc(context, self.bk_width/2.0f, self.bk_height/2.0f, self.bk_width/2.0f - 4, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);

    CGContextSetFillColorWithColor(context, [self.fillColor CGColor]);
    CGContextAddArc(context, self.bk_width/2.0f, self.bk_height/2.0f, self.bk_width/2.0f - 4.5, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);
    
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    if ([self.showTitle integerValue] > 99) {
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:8],NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:[UIColor whiteColor]};
        [self.showTitle drawWithRect:CGRectMake(5, 10, self.bk_width - 10, self.bk_height - 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    }else{
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:[UIColor whiteColor]};
        [self.showTitle drawWithRect:CGRectMake(5, 7.5, self.bk_width - 10, self.bk_height - 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    }
}

-(void)selfRecognizer
{
    if (self.selectButtonClick) {
        self.selectButtonClick(self);
    }
}

-(void)selectClickNum:(NSInteger)num addMethod:(void (^)(void))method
{
    if (self.isAnimate) {
        return;
    }
    
    if ([self.showTitle length] == 0) {
        
        self.showTitle = [NSString stringWithFormat:@"%ld",num];
        self.fillColor = BKSelectImageCircleHighlightColor;
        [self setNeedsDisplay];
        
        self.isAnimate = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeScale(1.15, 1.15);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.transform = CGAffineTransformMakeScale(1, 1);
                } completion:^(BOOL finished) {
                    self.isAnimate = NO;
                }];
            }];
        });
    }else{
        self.showTitle = @"";
        self.fillColor = BKSelectImageCircleNormalColor;
        [self setNeedsDisplay];
    }
    
    if (method) {
        method();
    }
}

@end
