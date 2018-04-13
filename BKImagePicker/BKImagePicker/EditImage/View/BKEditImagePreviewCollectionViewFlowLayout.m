//
//  BKEditImagePreviewCollectionViewFlowLayout.m
//  zhaolin
//
//  Created by BIKE on 2018/4/4.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKEditImagePreviewCollectionViewFlowLayout.h"
#import "BKTool.h"

@implementation BKEditImagePreviewCollectionViewFlowLayout

-(void)prepareLayout
{
    [super prepareLayout];
    
    self.itemSize = CGSizeMake(floor(BK_SYSTEM_NAV_UI_HEIGHT/16*9), BK_SYSTEM_NAV_UI_HEIGHT);
    self.minimumLineSpacing = 2;
    self.minimumInteritemSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray * originalAttributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray * updatedAttributes = [NSMutableArray arrayWithArray:originalAttributes];
    
    for (UICollectionViewLayoutAttributes * attributes in originalAttributes) {
        if (!attributes.representedElementKind) {
            NSUInteger index = [updatedAttributes indexOfObject:attributes];
            updatedAttributes[index] = [self layoutAttributesForItemAtIndexPath:attributes.indexPath];
        }
    }
    
    CGFloat total_width = 0;
    for (int i = 0; i < [originalAttributes count]; i++) {
        UICollectionViewLayoutAttributes * attributes = originalAttributes[i];
        if (!attributes.representedElementKind) {
            total_width = total_width + attributes.frame.size.width + self.minimumLineSpacing;
        }
    }
    
    if (total_width < self.collectionView.bk_width) {
        CGFloat beginX = (self.collectionView.bk_width - total_width - self.minimumLineSpacing)/2;
        for (int i = 0; i < [originalAttributes count]; i++) {
            UICollectionViewLayoutAttributes * attributes = originalAttributes[i];
            if (!attributes.representedElementKind) {
                UICollectionViewLayoutAttributes * updateAttr = updatedAttributes[i];
                CGRect updateFrame = updateAttr.frame;
                updateFrame.origin.x = beginX;
                updateAttr.frame = updateFrame;
                [updatedAttributes replaceObjectAtIndex:i withObject:updateAttr];
                
                beginX = beginX + updateAttr.frame.size.width + self.minimumLineSpacing;
            }
        }
    }
    
    return updatedAttributes;
}

@end
