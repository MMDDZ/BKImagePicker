//
//  BKImagePreviewCollectionViewCell.m
//  BKImagePicker
//
//  Created by BIKE on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePreviewCollectionViewCell.h"
#import "BKImagePickerConstant.h"
#import "BKImagePickerMacro.h"
#import "UIView+BKImagePicker.h"

@interface BKImagePreviewCollectionViewCell()<UIScrollViewDelegate>

@end

@implementation BKImagePreviewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = BKClearColor;
        
        _imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(BKExampleImagesSpacing, 0, frame.size.width-BKExampleImagesSpacing*2, frame.size.height)];
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        _imageScrollView.delegate = self;
        _imageScrollView.contentSize = CGSizeMake(frame.size.width-BKExampleImagesSpacing*2, frame.size.height);
        _imageScrollView.backgroundColor = BKClearColor;
        _imageScrollView.minimumZoomScale = 1.0;
        if (@available(iOS 11.0, *)) {
            _imageScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:_imageScrollView];
        
        _showImageView = [[FLAnimatedImageView alloc] init];
        _showImageView.userInteractionEnabled = YES;
        _showImageView.clipsToBounds = YES;
        _showImageView.contentMode = UIViewContentModeScaleAspectFill;
        _showImageView.runLoopMode = NSRunLoopCommonModes;
        [_imageScrollView addSubview:_showImageView];
        
    }
    return self;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self scrollViewScale];
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _showImageView;
}

- (void)scrollViewScale
{
    _imageScrollView.contentSize = CGSizeMake(_showImageView.bk_width, _showImageView.bk_height);
    
    _showImageView.bk_centerX = _showImageView.bk_width>_imageScrollView.bk_width?_imageScrollView.contentSize.width/2.0f:_imageScrollView.bk_centerX-BKExampleImagesSpacing;
    _showImageView.bk_centerY = _showImageView.bk_height>_imageScrollView.bk_height?_imageScrollView.contentSize.height/2.0f:_imageScrollView.bk_centerY;
}


@end
