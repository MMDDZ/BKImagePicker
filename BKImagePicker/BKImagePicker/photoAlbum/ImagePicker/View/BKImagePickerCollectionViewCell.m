//
//  BKImagePickerCollectionViewCell.m
//  BKImagePicker
//
//  Created by iMac on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePickerCollectionViewCell.h"
#import "BKImageAlbumItemView.h"
#import "BKImagePickerConst.h"
#import "BKImageModel.h"

@interface BKImagePickerCollectionViewCell()

@property (nonatomic,strong) BKImageAlbumItemSelectButton * selectButton;
@property (nonatomic,strong) BKImageAlbumItemView * itemView;

@end

@implementation BKImagePickerCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _photoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _photoImageView.clipsToBounds = YES;
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_photoImageView];
        
        _itemView = [[BKImageAlbumItemView alloc]initWithFrame:_photoImageView.bounds];
        [self.contentView addSubview:_itemView];
        
        _selectButton = [[BKImageAlbumItemSelectButton alloc]initWithFrame:CGRectMake(self.bk_width - 30, 0, 30, 30)];
        __weak typeof(self) weakSelf = self;
        [_selectButton setSelectButtonClick:^(BKImageAlbumItemSelectButton * button) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf selectButton:button];
        }];
        [self.contentView addSubview:_selectButton];
        
    }
    return self;
}

-(void)revaluateIndexPath:(NSIndexPath *)indexPath listArr:(NSArray *)listArr selectImageArr:(NSArray *)selectImageArr
{
    _selectButton.hidden = YES;
    
    BKImageModel * model = listArr[indexPath.item];
    self.photoImageView.image = model.thumbImage;
    
    if (model.photoType != BKSelectPhotoTypeVideo) {
        
        if (model.photoType == BKSelectPhotoTypeGIF) {
            [_itemView photoType:BKSelectPhotoTypeGIF allSecond:0];
        }else{
            [_itemView photoType:BKSelectPhotoTypeImage allSecond:0];
        }
        
        if (self.max_select != 1) {
            
            _selectButton.hidden = NO;
            _selectButton.tag = indexPath.item;
            
            __block BOOL isHaveFlag = NO;
            __block NSInteger item = 0;
            [selectImageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BKImageModel * listModel = obj;
                if ([listModel.fileName isEqualToString: model.fileName]) {
                    item = idx;
                    isHaveFlag = YES;
                    *stop = YES;
                }
            }];
            
            if (isHaveFlag) {
                _selectButton.title = [NSString stringWithFormat:@"%ld",item+1];
            }else{
                _selectButton.title = @"";
            }
        }
        
    }else{
        NSInteger allSecond = [[model.asset valueForKey:@"duration"] integerValue];
        [_itemView photoType:BKSelectPhotoTypeVideo allSecond:allSecond];
    }
}

-(void)selectButton:(BKImageAlbumItemSelectButton*)button
{
    if ([self.delegate respondsToSelector:@selector(selectImageBtnClick:)]) {
        [self.delegate selectImageBtnClick:button];
    }
}

@end
