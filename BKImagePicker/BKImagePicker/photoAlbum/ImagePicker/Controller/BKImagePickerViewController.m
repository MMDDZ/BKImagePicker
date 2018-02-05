//
//  BKImagePickerViewController.m
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define item_Size CGSizeMake((BK_SCREENW-BKAlbumImagesSpacing*5)/4, (BK_SCREENW-BKAlbumImagesSpacing*5)/4)

#define imagePickerCell_identifier @"BKImagePickerCollectionViewCell"
#define imagePickerFooter_identifier @"BKImagePickerFooterCollectionReusableView"

#define imageSize CGSizeMake(BK_SCREENW/2.0f, BK_SCREENW/2.0f)

#import "BKPhotoAlbumListViewController.h"

#import "BKImagePickerViewController.h"
#import "BKImagePickerCollectionViewCell.h"
#import "BKImagePickerFooterCollectionReusableView.h"
#import "BKImageAlbumItemSelectButton.h"
#import "BKImagePickerConst.h"
#import "BKShowExampleImageView.h"
#import "BKShowExampleVideoView.h"

@interface BKImagePickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,BKImagePickerCollectionViewCellDelegate>

@property (nonatomic,strong) PHImageRequestOptions * options;

@property (nonatomic,strong) UICollectionView * albumCollectionView;

/**
 list数据
 */
@property (nonatomic,strong) NSMutableArray * listArray;
/**
 list数据(不包括视频)
 */
@property (nonatomic,strong) NSMutableArray * imageListArray;


/**
 该相簿中所有照片和视频总数
 */
@property (nonatomic,assign) NSInteger allAlbumImageNum;
/**
 该相簿中所有普通照片总数
 */
@property (nonatomic,assign) NSInteger allNormalImageNum;
/**
 该相簿中所有GIF照片总数
 */
@property (nonatomic,assign) NSInteger allGifImageNum;
/**
 该相簿中所有视频总数
 */
@property (nonatomic,assign) NSInteger allVideoNum;


@property (nonatomic,strong) UIButton * previewBtn;
@property (nonatomic,strong) UIButton * editBtn;
@property (nonatomic,strong) UIButton * originalBtn;
@property (nonatomic,strong) UIButton * sendBtn;

@end

@implementation BKImagePickerViewController

-(NSMutableArray*)listArray
{
    if (!_listArray) {
        _listArray = [NSMutableArray array];
    }
    return _listArray;
}

-(NSMutableArray*)imageListArray
{
    if (!_imageListArray) {
        _imageListArray = [NSMutableArray array];
    }
    return _imageListArray;
}

-(NSMutableArray*)selectImageArray
{
    if (!_selectImageArray) {
        _selectImageArray = [NSMutableArray array];
    }
    return _selectImageArray;
}

//更新选取的PHAsset数组
-(void)refreshClassSelectImageArray
{
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[BKPhotoAlbumListViewController class]]) {
            BKPhotoAlbumListViewController * vc = (BKPhotoAlbumListViewController*)obj;
            vc.selectImageArray = [NSArray arrayWithArray:self.selectImageArray];
            vc.isOriginal = self.isOriginal;
            
            if ([self.selectImageArray count] == 0) {
                [_previewBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_sendBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:BKNavSendGrayBackgroundColor];
            }else if ([self.selectImageArray count] == 1) {
                [_previewBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
                BKImageModel * model = self.selectImageArray[0];
                if (model.photoType == BKSelectPhotoTypeImage) {
                    [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
                }else{
                    [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                }
                [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
            }else if ([self.selectImageArray count] > 1) {
                [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
            }
            
            if ([self.selectImageArray count] == 0) {
                [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
            }else{
                [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.selectImageArray count]] forState:UIControlStateNormal];
            }
            
            *stop = YES;
        }
    }];
}

#pragma mark - 获取图片

-(PHImageRequestOptions*)options
{
    if (!_options) {
        _options = [[PHImageRequestOptions alloc] init];
        _options.resizeMode = PHImageRequestOptionsResizeModeFast;
        _options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _options.synchronous = NO;
    }
    return _options;
}

-(void)getAllImageClassData
{
    //系统的相簿
    PHFetchResult * smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    BOOL systemFlag = [self getSingleAlbum:smartAlbums];
    
    if (systemFlag) {
        return;
    }
    
    //用户自己创建的相簿
    PHFetchResult * userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    BOOL userFlag = [self getSingleAlbum:userAlbums];
    
    if (userFlag) {
        return;
    }
}

-(BOOL)getSingleAlbum:(PHFetchResult*)fetchResult
{
    __block BOOL flag = NO;
    
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAssetCollection *collection = obj;
        
        if ([collection.localizedTitle isEqualToString:self.title]) {
            
            // 获取所有资源的集合按照创建时间排列
            PHFetchOptions * fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d || mediaType = %d",PHAssetMediaTypeImage,PHAssetMediaTypeVideo];

            
            PHFetchResult<PHAsset *> * assets  = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            
            self.allAlbumImageNum = [assets count];
            
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                BKImageModel * model = [[BKImageModel alloc]init];
                model.asset = obj;
                
                NSString * fileName = [obj valueForKey:@"filename"];
                model.fileName = fileName;
                
                if (obj.mediaType == PHAssetMediaTypeImage) {
                    if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                        self.allNormalImageNum++;
                        model.photoType = BKSelectPhotoTypeImage;
                    }else{
                        self.allGifImageNum++;
                        model.photoType = BKSelectPhotoTypeGIF;
                    }
                    
                    [self.imageListArray addObject:model];
                    
                }else{
                    self.allVideoNum++;
                    model.photoType = BKSelectPhotoTypeVideo;
                }
                
                switch (self.photoType) {
                    case BKPhotoTypeDefault:
                    {
                        [self.listArray addObject:model];
                    }
                        break;
                    case BKPhotoTypeImageAndGif:
                    {
                        if (obj.mediaType == PHAssetMediaTypeImage) {
                            [self.listArray addObject:model];
                        }else{
                            self.allAlbumImageNum--;
                        }
                    }
                        break;
                    case BKPhotoTypeImageAndVideo:
                    {
                        if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                            [self.listArray addObject:model];
                        }else{
                            self.allAlbumImageNum--;
                        }
                    }
                        break;
                    case BKPhotoTypeImage:
                    {
                        if (obj.mediaType == PHAssetMediaTypeImage) {
                            
                            if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                                [self.listArray addObject:model];
                            }else{
                                self.allAlbumImageNum--;
                            }
                        }else{
                            self.allAlbumImageNum--;
                        }
                    }
                        break;
                }
                
                if ([self.listArray count] == self.allAlbumImageNum) {
                    [self.albumCollectionView reloadData];
                }
            }];
            
            *stop = YES;
            flag = YES;
        }
    }];
    return flag;
}

#pragma mark - 根据index 获取对应缩略图

-(void)getImageWithIndex:(NSInteger)index getThumbComplete:(void (^)(void))getThumbComplete
{
    BKImageModel * model = self.listArray[index];
    if (model.thumbImageData) {
        if (getThumbComplete) {
            getThumbComplete();
        }
    }else{
        [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            // 排除取消，错误，低清图
            BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downImageloadFinined) {
                if(result) {
                    
                    model.thumbImage = result;
                    
                    [self.listArray replaceObjectAtIndex:index withObject:model];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (getThumbComplete) {
                            getThumbComplete();
                        }
                    });
                }
            }
        }];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        if (self.albumCollectionView.contentSize.height > self.albumCollectionView.bk_height) {
            [self.albumCollectionView setContentOffset:CGPointMake(0, self.albumCollectionView.contentSize.height - self.albumCollectionView.bk_height) animated:NO];
        }
        [self.albumCollectionView removeObserver:self forKeyPath:@"contentSize"];
    }
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.allNormalImageNum = 0;
    self.allGifImageNum = 0;
    self.allVideoNum = 0;
    
    [self initTopNav];
    if (self.max_select != 1) {
        [self initBottomNav];
    }
    
    [self getAllImageClassData];
}

#pragma mark - UICollectionView

-(UICollectionView*)albumCollectionView
{
    if (!_albumCollectionView) {
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = item_Size;
        flowLayout.minimumLineSpacing = BKAlbumImagesSpacing;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(BKAlbumImagesSpacing, BKAlbumImagesSpacing, BKAlbumImagesSpacing, BKAlbumImagesSpacing);
        [flowLayout setFooterReferenceSize:CGSizeMake(BK_SCREENW, 40)];
        
        _albumCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _albumCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(BK_SYSTEM_NAV_HEIGHT, 0, 0, 0);
        _albumCollectionView.contentInset = UIEdgeInsetsMake(BK_SYSTEM_NAV_HEIGHT, 0, 0, 0);
        _albumCollectionView.delegate = self;
        _albumCollectionView.dataSource = self;
        _albumCollectionView.backgroundColor = [UIColor clearColor];
        [_albumCollectionView registerClass:[BKImagePickerCollectionViewCell class] forCellWithReuseIdentifier:imagePickerCell_identifier];
        [_albumCollectionView registerClass:[BKImagePickerFooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:imagePickerFooter_identifier];
        if (@available(iOS 11.0, *)) {
            _albumCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.view insertSubview:_albumCollectionView atIndex:0];
        
        [_albumCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).mas_offset(0);
            make.left.mas_equalTo(self.view.mas_left).mas_offset(0);
            make.bottom.mas_equalTo(self.bottomNavView.mas_top).mas_offset(0);
            make.right.mas_equalTo(self.view.mas_right).mas_offset(0);
        }];
        
        [_albumCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _albumCollectionView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.listArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKImagePickerCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:imagePickerCell_identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.max_select = self.max_select;
    
    [self getImageWithIndex:indexPath.item getThumbComplete:^{
        [cell revaluateIndexPath:indexPath listArr:[self.listArray copy] selectImageArr:[self.selectImageArray copy]];
    }];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView * reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter){
        
        BKImagePickerFooterCollectionReusableView * footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:imagePickerFooter_identifier forIndexPath:indexPath];
        
        switch (self.photoType) {
            case BKPhotoTypeDefault:
            {
                footerView.titleLab.text = [NSString stringWithFormat:@"共%ld张照片、%ld个GIF、%ld个视频",self.allNormalImageNum,self.allGifImageNum,self.allVideoNum];
            }
                break;
            case BKPhotoTypeImageAndGif:
            {
                footerView.titleLab.text = [NSString stringWithFormat:@"共%ld张照片、%ld个GIF",self.allNormalImageNum,self.allGifImageNum];
            }
                break;
            case BKPhotoTypeImageAndVideo:
            {
                footerView.titleLab.text = [NSString stringWithFormat:@"共%ld张照片、%ld个视频",self.allNormalImageNum,self.allVideoNum];
            }
                break;
            case BKPhotoTypeImage:
            {
                footerView.titleLab.text = [NSString stringWithFormat:@"共%ld张照片",self.allNormalImageNum];
            }
                break;
        }
        
        reusableview = footerView;
    }
    
    return reusableview;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.view.userInteractionEnabled) {
        self.view.userInteractionEnabled = NO;
    }else{
        return;
    }
    
    BKImageModel * model = self.listArray[indexPath.item];
    
    if (model.asset.mediaType == PHAssetMediaTypeImage) {
        
        BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
        if (!cell) {
            [self.albumCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
                [self previewWithCell:cell imageListArray:self.imageListArray tapModel:model];
            });
        }else{
            [self previewWithCell:cell imageListArray:self.imageListArray tapModel:model];
        }
        
    }else{
        if ([self.selectImageArray count] > 0) {
            [[BKTool sharedManager] showRemind:@"不能同时选择照片和视频"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
            });
            return;
        }
        
        BKShowExampleVideoView * exampleVideoView = [[BKShowExampleVideoView alloc]initWithModel:model];
        [exampleVideoView showInVC:self];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = YES;
    });
}

-(void)previewWithCell:(BKImagePickerCollectionViewCell*)cell imageListArray:(NSArray*)imageListArray tapModel:(BKImageModel*)tapModel
{
    if (!cell.photoImageView.image && cell) {
        return;
    }
    
    _albumCollectionView.scrollsToTop = NO;
    
    BKShowExampleImageView * exampleImageView = [[BKShowExampleImageView alloc] initWithLocationVC:self imageListArray:imageListArray selectImageArray:_selectImageArray tapModel:tapModel maxSelect:_max_select isOriginal:_isOriginal];
    __weak typeof(self) weakSelf = self;
    __weak typeof(exampleImageView) weakExampleImageView = exampleImageView;
    
    [exampleImageView setRefreshLookLocationOption:^(BKImageModel * model) {
        __strong typeof(self) strongSelf = weakSelf;
        __block NSInteger item = 0;
        __block BOOL isHaveFlag = NO;
        [strongSelf.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BKImageModel * listModel = obj;
            if ([listModel.fileName isEqualToString: model.fileName]) {
                item = idx;
                isHaveFlag = YES;
                *stop = YES;
            }
        }];
        
        if (isHaveFlag) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:0];
            BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
            if (!cell) {
                [self.albumCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            }
        }
        
    }];
    [exampleImageView setBackOption:^(BKImageModel * model, UIImageView * imageView) {
        __strong typeof(self) strongSelf = weakSelf;
        __strong typeof(weakExampleImageView) strongExampleImageView = weakExampleImageView;
        __block BOOL isHaveFlag = NO;
        __block NSInteger item = 0;
        [strongSelf.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BKImageModel * listModel = obj;
            if ([listModel.fileName isEqualToString: model.fileName]) {
                item = idx;
                isHaveFlag = YES;
                *stop = YES;
            }
        }];
        
        CGRect imageViewFrame = [[imageView superview] convertRect:imageView.frame toView:strongExampleImageView];
        
        UIImageView * newImageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
        newImageView.clipsToBounds = YES;
        newImageView.contentMode = UIViewContentModeScaleAspectFill;
        newImageView.image = imageView.image;
        [strongExampleImageView addSubview:newImageView];
        [strongExampleImageView bringSubviewToFront:strongExampleImageView.topView];
        [strongExampleImageView bringSubviewToFront:strongExampleImageView.bottomView];
        
        if (isHaveFlag) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:0];
            
            BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[strongSelf.albumCollectionView cellForItemAtIndexPath:indexPath];
            CGRect cellImageFrame = [[cell.photoImageView superview] convertRect:cell.photoImageView.frame toView:self.view];
            
            cell.alpha = 0;
            
            [UIView animateWithDuration:BKCheckExampleImageAnimateTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                newImageView.frame = cellImageFrame;
                strongExampleImageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
                strongExampleImageView.topView.alpha = 0;
                strongExampleImageView.bottomView.alpha = 0;
            } completion:^(BOOL finished) {
                [newImageView removeFromSuperview];
                cell.alpha = 1;
                [strongExampleImageView removeFromSuperview];
            }];
        }else{
            
            [strongExampleImageView removeFromSuperview];
            [[strongSelf.view superview] addSubview:strongExampleImageView];
            strongSelf.view.bk_x = - BK_SCREENW/2.0f;
            
            [UIView animateWithDuration:BKCheckExampleGifAndVideoAnimateTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                strongSelf.view.bk_x = 0;
                strongExampleImageView.bk_x = BK_SCREENW;
                
            } completion:^(BOOL finished) {
                [strongExampleImageView removeFromSuperview];
            }];
        }
        
        _albumCollectionView.scrollsToTop = YES;
    }];
    [exampleImageView setRefreshAlbumViewOption:^(NSArray * selectImageArray,BOOL isOriginal) {
        __strong typeof(self) strongSelf = weakSelf;
        
        strongSelf.selectImageArray = [NSMutableArray arrayWithArray:selectImageArray];
        [strongSelf.albumCollectionView reloadData];
        
        strongSelf.isOriginal = isOriginal;
        if (strongSelf.isOriginal) {
            [_originalBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
            [strongSelf calculataImageSize];
        }else{
            [_originalBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
            [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
        }
        
        [strongSelf refreshClassSelectImageArray];
    }];
    [exampleImageView showImageAnimate:cell.photoImageView beginAnimateOption:^{
        cell.alpha = 0;
    } endAnimateOption:^{
        cell.alpha = 1;
    }];
}

#pragma mark - BKImagePickerCollectionViewCellDelegate

-(void)selectImageBtnClick:(BKImageAlbumItemSelectButton*)button
{
    if (self.view.userInteractionEnabled) {
        self.view.userInteractionEnabled = NO;
    }else{
        return;
    }
    
    BKImageModel * model = self.listArray[button.tag];
    
    __block BOOL isHave = NO;
    __block NSInteger item = 0;
    [self.selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKImageModel * selectModel = obj;
        if ([selectModel.fileName isEqualToString: model.fileName]) {
            item = idx;
            isHave = YES;
            *stop = YES;
        }
    }];
    
    if (!isHave && [self.selectImageArray count] >= self.max_select) {
        [[BKTool sharedManager] showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",self.max_select]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
        });
        return;
    }
    
    [button selectClickNum:[self.selectImageArray count]+1 addMethod:^{
        if (isHave) {
            
            [self.selectImageArray removeObjectAtIndex:item];
            
            if (self.isOriginal) {
                [self calculataImageSize];
            }
            
            [self.selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[self.listArray indexOfObject:obj] inSection:0];
                [self.albumCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            
        }else{
            
            [self.selectImageArray addObject:model];
            
            if (model.originalImageSize) {
                if (self.isOriginal) {
                    [self calculataImageSize];
                }
            }else{
                [self getOriginalImageDataSizeWithAsset:model.asset complete:^(NSData * originalImageData,NSURL * url) {
                   
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        model.thumbImageData = [[BKTool sharedManager] compressImageData:originalImageData];
                    });
                    model.originalImageData = originalImageData;
                    model.originalImageSize = (double)originalImageData.length/1024/1024;;
                    model.url = url;
                    
                    if (self.isOriginal) {
                        [self calculataImageSize];
                    }
            
                }];
            }
        }
        
        [self refreshClassSelectImageArray];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
        });
    }];
}

#pragma mark - initTopNav

-(void)initTopNav
{
    self.rightLab.text = @"取消";
}

-(void)rightNavBtnAction:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - initBottomNav

-(void)initBottomNav
{
    self.bottomNavViewHeight = BK_SYSTEM_TABBAR_HEIGHT;
    
    [self.bottomNavView addSubview:[self previewBtn]];
    if ([BKImagePicker sharedManager].isHaveEdit) {
        [self.bottomNavView addSubview:[self editBtn]];
    }
    if ([BKImagePicker sharedManager].isHaveOriginal) {
        [self.bottomNavView addSubview:[self originalBtn]];
    }
    [self.bottomNavView addSubview:[self sendBtn]];
    
    if ([self.selectImageArray count] == 1) {
        [_previewBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
        [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
        
        [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.selectImageArray count]] forState:UIControlStateNormal];
    }else if ([self.selectImageArray count] > 1) {
        
        [_previewBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
        [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
        
        [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.selectImageArray count]] forState:UIControlStateNormal];
    }
}

-(UIButton*)previewBtn
{
    if (!_previewBtn) {
        _previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewBtn.frame = CGRectMake(0, 0, BK_SCREENW/6, 49);
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [_previewBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        _previewBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_previewBtn addTarget:self action:@selector(previewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewBtn;
}

-(UIButton*)editBtn
{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame = CGRectMake(BK_SCREENW/6, 0, BK_SCREENW/6, 49);
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

-(UIButton*)originalBtn
{
    if (!_originalBtn) {
        _originalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalBtn.frame = CGRectMake(BK_SCREENW/6*2, 0, BK_SCREENW/7*3, 49);
        if (![BKImagePicker sharedManager].isHaveEdit) {
            _originalBtn.bk_x = BK_SCREENW/6;
        }
        if (self.isOriginal) {
            [_originalBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
            [self calculataImageSize];
        }else{
            [_originalBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
            [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
        }
        _originalBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _originalBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        _originalBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_originalBtn addTarget:self action:@selector(originalBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _originalBtn;
}

-(UIButton*)sendBtn
{
    if (!_sendBtn) {
        
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(BK_SCREENW/4*3, 6, BK_SCREENW/4-6, 37);
        [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:BKNavSendGrayBackgroundColor];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _sendBtn.layer.cornerRadius = 4;
        _sendBtn.clipsToBounds = YES;
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _sendBtn;
}

-(void)previewBtnClick:(UIButton*)button
{
    if (self.view.userInteractionEnabled) {
        self.view.userInteractionEnabled = NO;
    }else{
        return;
    }
    
    if ([self.selectImageArray count] == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
        });
        return;
    }
    
    BKImageModel * model = [self.selectImageArray lastObject];
    __block BOOL isHaveFlag = NO;
    __block NSInteger item = 0;
    [self.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKImageModel * listModel = obj;
        if ([listModel.fileName isEqualToString: model.fileName]) {
            item = idx;
            isHaveFlag = YES;
            *stop = YES;
        }
    }];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    
    if (!isHaveFlag) {
        [self previewWithCell:nil imageListArray:self.selectImageArray tapModel:[self.selectImageArray lastObject]];
    }else{
        BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
        if (!cell) {
            [self.albumCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
                [self previewWithCell:cell imageListArray:self.selectImageArray tapModel:[self.selectImageArray lastObject]];
            });
        }else{
            [self previewWithCell:cell imageListArray:self.selectImageArray tapModel:[self.selectImageArray lastObject]];
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = YES;
    });
}

-(void)editBtnClick:(UIButton*)button
{
    if ([self.selectImageArray count] > 1) {
        return;
    }
}

-(void)originalBtnClick:(UIButton*)button
{
    if (!self.isOriginal) {
        [button setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
        [self calculataImageSize];
    }else{
        [button setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        [button setTitle:@"原图" forState:UIControlStateNormal];
    }
    self.isOriginal = !self.isOriginal;
    [self refreshClassSelectImageArray];
}

-(void)calculataImageSize
{
    __block double allSize = 0.0;
    [self.selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKImageModel * model = obj;
        allSize = allSize + model.originalImageSize;
    }];
    if (allSize>1024) {
        allSize = allSize / 1024;
        if (allSize > 1024) {
            allSize = allSize / 1024;
            [_originalBtn setTitle:[NSString stringWithFormat:@"原图(%.1fT)",allSize] forState:UIControlStateNormal];
        }else{
            [_originalBtn setTitle:[NSString stringWithFormat:@"原图(%.1fG)",allSize] forState:UIControlStateNormal];
        }
    }else{
        [_originalBtn setTitle:[NSString stringWithFormat:@"原图(%.1fM)",allSize] forState:UIControlStateNormal];
    }
}

-(void)sendBtnClick:(UIButton*)button
{
    if ([self.selectImageArray count] == 0) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:@{@"object":self.selectImageArray,@"isOriginal":@(_isOriginal)}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 算图片大小和高清图data/缩略图data

-(void)getOriginalImageDataSizeWithAsset:(PHAsset*)asset complete:(void (^)(NSData * originalImageData,NSURL * url))complete
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

        NSURL * url = info[@"PHImageFileURLKey"];
        if (complete) {
            complete(imageData,url);
        }
    }];
}

@end
