//
//  BKImagePickerViewController.m
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define item_Size CGSizeMake((UISCREEN_WIDTH-BKAlbumImagesSpacing*5)/4, (UISCREEN_WIDTH-BKAlbumImagesSpacing*5)/4)

#define imagePickerCell_identifier @"BKImagePickerCollectionViewCell"
#define imagePickerFooter_identifier @"BKImagePickerFooterCollectionReusableView"

#define imageSize CGSizeMake(UISCREEN_WIDTH/2.0f, UISCREEN_WIDTH/2.0f)

#import "BKImageClassViewController.h"

#import "BKImagePickerViewController.h"
#import "BKImagePickerCollectionViewCell.h"
#import "BKImagePickerFooterCollectionReusableView.h"
#import "BKImageAlbumItemSelectButton.h"
#import "BKTool.h"
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


@property (nonatomic,strong) UIView * topView;

@property (nonatomic,strong) UIView * bottomView;
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
        if ([obj isKindOfClass:[BKImageClassViewController class]]) {
            BKImageClassViewController * vc = (BKImageClassViewController*)obj;
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
                    [self moveAlbumViewToBottom];
                }
            }];
            
            *stop = YES;
            flag = YES;
        }
    }];
    return flag;
}

-(void)getImageWithIndex:(NSInteger)index getThumbComplete:(void (^)())getThumbComplete getOriginalDataComplete:(void (^)(BKImageModel * model))getOriginalDataComplete
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
                    
                    if (model.photoType == BKSelectPhotoTypeGIF) {
                        
                        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                        options.resizeMode = PHImageRequestOptionsResizeModeFast;
                        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                        options.synchronous = NO;
                        
                        [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                            
                            model.thumbImageData = imageData;
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if (getOriginalDataComplete) {
                                    getOriginalDataComplete(model);
                                }
                            });
                        }];
                    }
                }
            }
        }];
    }
}

-(void)moveAlbumViewToBottom
{
    NSUInteger finalItem = MAX(0, [self.albumCollectionView numberOfItemsInSection:0] - 1);
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalItem inSection:0];
    [self.albumCollectionView scrollToItemAtIndexPath:finalIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    
    if (self.albumCollectionView.contentOffset.y > 0) {
        [self.albumCollectionView setContentOffset:CGPointMake(0, self.albumCollectionView.contentOffset.y + 46)];
    }
}

#pragma mark - viewDidLoad

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.allNormalImageNum = 0;
    self.allGifImageNum = 0;
    self.allVideoNum = 0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:[self albumCollectionView]];
    [self.view addSubview:[self topView]];
    if (self.max_select != 1) {
        [self.view addSubview:[self bottomView]];
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
        [flowLayout setFooterReferenceSize:CGSizeMake(UISCREEN_WIDTH, 40)];
        
        if (self.max_select == 1) {
            _albumCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT) collectionViewLayout:flowLayout];
        }else{
            _albumCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT-49) collectionViewLayout:flowLayout];
        }
        _albumCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0);
        _albumCollectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        _albumCollectionView.delegate = self;
        _albumCollectionView.dataSource = self;
        _albumCollectionView.backgroundColor = [UIColor clearColor];
        _albumCollectionView.scrollsToTop = NO;
        [_albumCollectionView registerClass:[BKImagePickerCollectionViewCell class] forCellWithReuseIdentifier:imagePickerCell_identifier];
        [_albumCollectionView registerClass:[BKImagePickerFooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:imagePickerFooter_identifier];
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
    } getOriginalDataComplete:^(BKImageModel * model){
        if (model.thumbImageData) {
            FLAnimatedImage * gifImage = [FLAnimatedImage animatedImageWithGIFData:model.thumbImageData];
            if (gifImage) {
                cell.photoImageView.animatedImage = gifImage;
            }
        }
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
            [BKTool showRemind:@"不能同时选择照片和视频"];
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
    BKShowExampleImageView * exampleImageView = [[BKShowExampleImageView alloc] initWithLocationVC:self imageListArray:imageListArray selectImageArray:_selectImageArray tapModel:tapModel maxSelect:_max_select isOriginal:_isOriginal];
    __weak typeof(self) weakSelf = self;
    __weak typeof(exampleImageView) weakExampleImageView = exampleImageView;
    
    [exampleImageView setRefreshLookLocationOption:^(BKImageModel * model) {
        __block typeof(self) strongSelf = weakSelf;
        __block NSInteger item = 0;
        [strongSelf.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BKImageModel * listModel = obj;
            if ([listModel.fileName isEqualToString: model.fileName]) {
                item = idx;
                *stop = YES;
            }
        }];
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
        if (!cell) {
            [self.albumCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        }
    }];
    [exampleImageView setBackOption:^(BKImageModel * model, UIImageView * imageView) {
        __block typeof(self) strongSelf = weakSelf;
        __block typeof(weakExampleImageView) strongExampleImageView = weakExampleImageView;
        __block NSInteger item = 0;
        [strongSelf.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BKImageModel * listModel = obj;
            if ([listModel.fileName isEqualToString: model.fileName]) {
                item = idx;
                *stop = YES;
            }
        }];
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        
        BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[strongSelf.albumCollectionView cellForItemAtIndexPath:indexPath];
        
        cell.alpha = 0;
        
        CGRect cellImageFrame = [[cell.photoImageView superview] convertRect:cell.photoImageView.frame toView:self.view];
        
        CGRect imageViewFrame = [[imageView superview] convertRect:imageView.frame toView:strongExampleImageView];
        
        UIImageView * newImageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
        newImageView.clipsToBounds = YES;
        newImageView.contentMode = UIViewContentModeScaleAspectFill;
        newImageView.image = imageView.image;
        [strongExampleImageView addSubview:newImageView];
        [strongExampleImageView bringSubviewToFront:strongExampleImageView.topView];
        [strongExampleImageView bringSubviewToFront:strongExampleImageView.bottomView];
        
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
    }];
    [exampleImageView setRefreshAlbumViewOption:^(NSArray * selectImageArray,BOOL isOriginal) {
        __block typeof(self) strongSelf = weakSelf;
        
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
    BOOL isHave = [self.selectImageArray containsObject:model];
    if (!isHave && [self.selectImageArray count] >= self.max_select) {
        [BKTool showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",self.max_select]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
        });
        return;
    }
    
    [button selectClickNum:[self.selectImageArray count]+1 addMethod:^{
        if (isHave) {
            
            [self.selectImageArray removeObject:model];
            
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
                        
                        if (model.photoType == BKSelectPhotoTypeGIF) {
                            
                            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                            options.resizeMode = PHImageRequestOptionsResizeModeFast;
                            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                            options.synchronous = NO;
                            
                            [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                
                                model.thumbImageData = imageData;
                                
                            }];
                        }else{
                            model.thumbImageData = [BKTool compressImageData:originalImageData];
                        }
                        
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

#pragma mark - topView

-(UIView*)topView
{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, 64)];
        _topView.backgroundColor = BKNavBackgroundColor;
        
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(100, 20, UISCREEN_WIDTH - 100*2, 44)];
        titleLab.font = [UIFont boldSystemFontOfSize:17];
        titleLab.textColor = [UIColor blackColor];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = self.title;
        [_topView addSubview:titleLab];
        
        UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 0, 100, 64);
        [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:leftBtn];
        
        NSString * backPath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        UIImageView * leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20 + 12, 20, 20)];
        leftImageView.clipsToBounds = YES;
        leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        leftImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/blue_back.png",backPath]];
        [leftBtn addSubview:leftImageView];
        
        UILabel * leftLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(leftImageView.frame), 0, 70, 30)];
        leftLab.textColor = BKNavHighlightTitleColor;
        leftLab.font = [UIFont systemFontOfSize:17];
        leftLab.text = self.navigationController.viewControllers[0].title;
        CGPoint leftLabCenter = leftLab.center;
        leftLabCenter.y = leftImageView.center.y;
        leftLab.center = leftLabCenter;
        [leftBtn addSubview:leftLab];
        
        UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(UISCREEN_WIDTH - 64, 20, 64, 44);
        [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        [rightBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:rightBtn];
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64-BKLineHeight, UISCREEN_WIDTH, BKLineHeight)];
        line.backgroundColor = BKLineColor;
        [_topView addSubview:line];
    }
    return _topView;
}

-(void)leftBtnClick:(UIButton*)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightBtnClick:(UIButton*)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BottomView

-(UIView*)bottomView
{
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, UISCREEN_HEIGHT-49, UISCREEN_WIDTH, 49)];
        _bottomView.backgroundColor = BKNavBackgroundColor;
        
        UIImageView * lineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, BKLineHeight)];
        lineView.backgroundColor = BKLineColor;
        [_bottomView addSubview:lineView];
        
        [_bottomView addSubview:[self editBtn]];
        [_bottomView addSubview:[self previewBtn]];
        if (BKComfirmHaveOriginalOption) {
            [_bottomView addSubview:[self originalBtn]];
        }
        [_bottomView addSubview:[self sendBtn]];
        
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
    return _bottomView;
}

-(UIButton*)previewBtn
{
    if (!_previewBtn) {
        _previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewBtn.frame = CGRectMake(0, 0, UISCREEN_WIDTH/6, 49);
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
        _editBtn.frame = CGRectMake(UISCREEN_WIDTH/6, 0, UISCREEN_WIDTH/6, 49);
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
        _originalBtn.frame = CGRectMake(UISCREEN_WIDTH/6*2, 0, UISCREEN_WIDTH/7*3, 49);
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
        _sendBtn.frame = CGRectMake(UISCREEN_WIDTH/4*3, 6, UISCREEN_WIDTH/4-6, 37);
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