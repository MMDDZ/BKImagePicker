//
//  BKShowExampleImageCollectionViewFlowLayout.m
//  BKImagePicker
//
//  Created by 毕珂 on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKShowExampleImageCollectionViewFlowLayout.h"

@implementation BKShowExampleImageCollectionViewFlowLayout

-(void)prepareLayout
{
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width+10*2, [UIScreen mainScreen].bounds.size.height-64);
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width+10*2)*_allImageCount, [UIScreen mainScreen].bounds.size.height-64);
}

@end
