//
//  BKImagePickerCollectionViewCell.m
//  BKImagePicker
//
//  Created by BIKE on 16/10/14.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePickerCollectionViewCell.h"
#import "BKImageAlbumItemView.h"
#import "BKTool.h"

@interface BKImagePickerCollectionViewCell()

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
    
    _currentImageModel = listArr[indexPath.item];
    self.photoImageView.image = _currentImageModel.thumbImage;
    
    if (_currentImageModel.photoType != BKSelectPhotoTypeVideo) {
        
        if (_currentImageModel.photoType == BKSelectPhotoTypeGIF) {
            [_itemView photoType:BKSelectPhotoTypeGIF allSecond:0];
        }else{
            [_itemView photoType:BKSelectPhotoTypeImage allSecond:0];
        }
        
        if (self.max_select != 1) {
            
            _selectButton.hidden = NO;
            
            BK_WEAK_SELF(self);
            __block BOOL isHaveFlag = NO;
            __block NSInteger item = 0;
            [selectImageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BK_STRONG_SELF(self);
                BKImageModel * listModel = obj;
                if ([listModel.fileName isEqualToString:strongSelf.currentImageModel.fileName]) {
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
        NSInteger allSecond = [[_currentImageModel.asset valueForKey:@"duration"] integerValue];
        [_itemView photoType:BKSelectPhotoTypeVideo allSecond:allSecond];
    }
}

-(void)selectButton:(BKImageAlbumItemSelectButton*)button
{
    if (_currentImageModel) {
        if ([self.delegate respondsToSelector:@selector(selectImageBtnClick:withImageModel:)]) {
            [self.delegate selectImageBtnClick:button withImageModel:_currentImageModel];
        }
    }
}

@end
