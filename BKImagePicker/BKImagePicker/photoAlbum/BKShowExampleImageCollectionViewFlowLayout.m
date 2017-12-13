//
//  BKShowExampleImageCollectionViewFlowLayout.m
//  BKImagePicker
//
//  Created by 毕珂 on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKShowExampleImageCollectionViewFlowLayout.h"
#import "BKImagePickerConst.h"

@implementation BKShowExampleImageCollectionViewFlowLayout

-(void)prepareLayout
{
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.itemSize = CGSizeMake(SCREENW+BKExampleImagesSpacing*2, SCREENH);
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake((SCREENW+BKExampleImagesSpacing*2)*_allImageCount, SCREENH);
}

@end
