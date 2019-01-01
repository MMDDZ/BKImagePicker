//
//  BKImagePreviewCollectionViewFlowLayout.m
//  BKImagePicker
//
//  Created by BIKE on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePreviewCollectionViewFlowLayout.h"
#import "BKImagePickerMacro.h"
#import "BKImagePickerConstant.h"

@implementation BKImagePreviewCollectionViewFlowLayout

-(void)prepareLayout
{
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.itemSize = CGSizeMake(BK_SCREENW+BKExampleImagesSpacing*2, BK_SCREENH);
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake((BK_SCREENW+BKExampleImagesSpacing*2)*_allImageCount, BK_SCREENH);
}

@end
