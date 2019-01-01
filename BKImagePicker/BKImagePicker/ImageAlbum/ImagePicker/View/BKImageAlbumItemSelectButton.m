//
//  BKImageAlbumItemSelectButton.m
//  BKImagePicker
//
//  Created by BIKE on 16/10/18.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImageAlbumItemSelectButton.h"
#import "BKImagePickerMacro.h"

@interface BKImageAlbumItemSelectButton()

@property (nonatomic,assign) CGRect selfRect;

@property (nonatomic,strong) NSString * showTitle;
@property (nonatomic,strong) UIColor * fillColor;

@end

@implementation BKImageAlbumItemSelectButton

-(void)setTitle:(NSString *)title
{
    if ([title length] == 0) {
        self.showTitle = @"";
        self.fillColor = BKImagePickerSelectImageNumberNormalBackgroundColor;
    }else{
        self.showTitle = title;
        self.fillColor = BKImagePickerSelectImageNumberHighlightedBackgroundColor;
    }
    
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.selfRect = frame;
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
        _fillColor = BKImagePickerSelectImageNumberNormalBackgroundColor;
    }
    return _fillColor;
}

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selfRect = frame;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = BKClearColor;
    
    UITapGestureRecognizer * selfRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selfRecognizer)];
    [self addGestureRecognizer:selfRecognizer];
}

-(void)selfRecognizer
{
    if (self.selectButtonClick) {
        self.selectButtonClick(self);
    }
}

#pragma mark - drawRect

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [BKImagePickerSelectImageNumberBorderColor CGColor]);
    CGContextSetLineWidth(context, 1.5);
    CGContextAddArc(context, self.selfRect.size.width/2.0f, self.selfRect.size.height/2.0f, self.selfRect.size.width/2.0f - 4, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);

    CGContextSetFillColorWithColor(context, [self.fillColor CGColor]);
    CGContextAddArc(context, self.selfRect.size.width/2.0f, self.selfRect.size.height/2.0f, self.selfRect.size.width/2.0f - 4.5, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);
    
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    if ([self.showTitle integerValue] > 99) {
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:8],NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:BKImagePickerSelectImageNumberTitleColor};
        [self.showTitle drawWithRect:CGRectMake(5, 10, self.selfRect.size.width - 10, self.selfRect.size.height - 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    }else{
        NSDictionary * attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:BKImagePickerSelectImageNumberTitleColor};
        [self.showTitle drawWithRect:CGRectMake(5, 7.5, self.selfRect.size.width - 10, self.selfRect.size.height - 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    }
}

-(void)selectClickNum:(NSInteger)num
{
    [self refreshSelectClickNum:num];
        
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformMakeScale(1.15, 1.15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
}

-(void)refreshSelectClickNum:(NSInteger)num
{
    if (num != 0) {
        self.showTitle = [NSString stringWithFormat:@"%ld",num];
        self.fillColor = BKImagePickerSelectImageNumberHighlightedBackgroundColor;
        [self setNeedsDisplay];
    }else{
        self.showTitle = @"";
        self.fillColor = BKImagePickerSelectImageNumberNormalBackgroundColor;
        [self setNeedsDisplay];
    }
}

-(void)cancelSelect
{
    self.showTitle = @"";
    self.fillColor = BKImagePickerSelectImageNumberNormalBackgroundColor;
    [self setNeedsDisplay];
}

@end
