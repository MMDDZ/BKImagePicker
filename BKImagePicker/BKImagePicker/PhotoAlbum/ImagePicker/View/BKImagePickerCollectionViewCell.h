//
//  BKImagePickerCollectionViewCell.h
//  BKImagePicker
//
//  Created by BIKE on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "BKImageAlbumItemSelectButton.h"
#import "BKImageModel.h"

@protocol BKImagePickerCollectionViewCellDelegate <NSObject>

-(void)selectImageBtnClick:(BKImageAlbumItemSelectButton*)button withImageModel:(BKImageModel*)imageModel;

@end

@interface BKImagePickerCollectionViewCell : UICollectionViewCell

@property (nonatomic,assign) id<BKImagePickerCollectionViewCellDelegate> delegate;

@property (nonatomic,strong) UIImageView * photoImageView;

@property (nonatomic,assign) NSInteger max_select;

@property (nonatomic,strong) BKImageModel * currentImageModel;

@property (nonatomic,strong) BKImageAlbumItemSelectButton * selectButton;

-(void)revaluateIndexPath:(NSIndexPath *)indexPath listArr:(NSArray *)listArr selectImageArr:(NSArray *)selectImageArr;

@end
