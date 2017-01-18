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
 该相簿中所有image数组 包括视频
 */
@property (nonatomic,strong) NSMutableArray * albumImageArray;

/**
 该相簿中所有PHAsset数组 包括视频
 */
@property (nonatomic,strong) NSMutableArray * albumAssetArray;

/**
 该相簿中所有PHAsset数组 不包括视频
 */
@property (nonatomic,strong) NSMutableArray * imageAlbumAssetArray;


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

-(NSMutableArray*)albumImageArray
{
    if (!_albumImageArray) {
        _albumImageArray = [NSMutableArray array];
    }
    return _albumImageArray;
}

-(NSMutableArray*)albumAssetArray
{
    if (!_albumAssetArray) {
        _albumAssetArray = [NSMutableArray array];
    }
    return _albumAssetArray;
}

-(NSMutableArray*)imageAlbumAssetArray
{
    if (!_imageAlbumAssetArray) {
        _imageAlbumAssetArray = [NSMutableArray array];
    }
    return _imageAlbumAssetArray;
}

-(NSMutableArray*)select_imageArray
{
    if (!_select_imageArray) {
        _select_imageArray = [NSMutableArray array];
    }
    return _select_imageArray;
}

-(NSMutableArray*)imageSizeArray
{
    if (!_imageSizeArray) {
        _imageSizeArray = [NSMutableArray array];
    }
    return _imageSizeArray;
}

-(NSMutableArray*)selectResultImageDataArray
{
    if (!_selectResultImageDataArray) {
        _selectResultImageDataArray = [NSMutableArray array];
    }
    return _selectResultImageDataArray;
}

//更新选取的PHAsset数组
-(void)refreshClassSelectImageArray
{
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[BKImageClassViewController class]]) {
            BKImageClassViewController * vc = (BKImageClassViewController*)obj;
            vc.select_imageArray = [NSArray arrayWithArray:self.select_imageArray];
            vc.selectResultImageDataArray = [NSArray arrayWithArray:self.selectResultImageDataArray];
            vc.isOriginal = self.isOriginal;
            vc.imageSizeArray = [NSArray arrayWithArray:self.imageSizeArray];
            
            if ([self.select_imageArray count] == 0) {
                [_previewBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_sendBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:BKNavSendGrayBackgroundColor];
            }else if ([self.select_imageArray count] == 1) {
                [_previewBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
                NSString * fileName = [self.select_imageArray[0] valueForKey:@"filename"];
                if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                    [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
                }else{
                    [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                }
                [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
            }else if ([self.select_imageArray count] > 1) {
                [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
            }
            
            if ([self.select_imageArray count] == 0) {
                [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
            }else{
                [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
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
                
                if (obj.mediaType == PHAssetMediaTypeImage) {
                    
                    [self.imageAlbumAssetArray addObject:obj];
                    
                    NSString * fileName = [obj valueForKey:@"filename"];
                    if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                        self.allNormalImageNum++;
                    }else{
                        self.allGifImageNum++;
                    }
                }else{
                    self.allVideoNum++;
                }
                
                switch (self.photoType) {
                    case BKPhotoTypeDefault:
                    {
                        [self.albumImageArray addObject:@""];
                        [self.albumAssetArray addObject:obj];
                    }
                        break;
                    case BKPhotoTypeImageAndGif:
                    {
                        if (obj.mediaType == PHAssetMediaTypeImage) {
                            [self.albumImageArray addObject:@""];
                            [self.albumAssetArray addObject:obj];
                        }else{
                            self.allAlbumImageNum--;
                        }
                    }
                        break;
                    case BKPhotoTypeImageAndVideo:
                    {
                        NSString * fileName = [obj valueForKey:@"filename"];
                        if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                            
                            [self.albumImageArray addObject:@""];
                            [self.albumAssetArray addObject:obj];
                        }else{
                            self.allAlbumImageNum--;
                        }
                    }
                        break;
                    case BKPhotoTypeImage:
                    {
                        if (obj.mediaType == PHAssetMediaTypeImage) {
                            
                            NSString * fileName = [obj valueForKey:@"filename"];
                            if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                                
                                [self.albumImageArray addObject:@""];
                                [self.albumAssetArray addObject:obj];
                            }else{
                                self.allAlbumImageNum--;
                            }
                        }else{
                            self.allAlbumImageNum--;
                        }
                    }
                        break;
                }
                
                if ([self.albumAssetArray count] == self.allAlbumImageNum) {
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

-(void)getImageWithIndex:(NSInteger)index complete:(void (^)(UIImage * image))complete
{
    if ([self.albumImageArray[index] isKindOfClass:[UIImage class]]) {
        if (complete) {
            complete(self.albumImageArray[index]);
        }
    }else{
        PHAsset * asset = self.albumAssetArray[index];
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            // 排除取消，错误，低清图
            BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downImageloadFinined) {
                if(result) {
                    [self.albumImageArray replaceObjectAtIndex:index withObject:result];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (complete) {
                            complete(result);
                        }
                    });
                }
            }
        }];
    }
}

-(void)moveAlbumViewToBottom
{
    NSUInteger finalRow = MAX(0, [self.albumCollectionView numberOfItemsInSection:0] - 1);
    NSIndexPath *finalIndexPath = [NSIndexPath indexPathForItem:finalRow inSection:0];
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
        [_albumCollectionView registerClass:[BKImagePickerCollectionViewCell class] forCellWithReuseIdentifier:imagePickerCell_identifier];
        [_albumCollectionView registerClass:[BKImagePickerFooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:imagePickerFooter_identifier];
    }
    return _albumCollectionView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.albumAssetArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKImagePickerCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:imagePickerCell_identifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.max_select = self.max_select;
    
    [self getImageWithIndex:indexPath.item complete:^(UIImage *image) {
        [cell revaluateIndexPath:indexPath exampleAssetArr:[NSArray arrayWithArray:self.albumAssetArray] selectImageArr:[NSArray arrayWithArray:self.select_imageArray] photoImage:image];
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
    
    PHAsset * asset = (PHAsset*)(self.albumAssetArray[indexPath.row]);
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        
        BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
        if (!cell) {
            [self.albumCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
                [self previewWithCell:cell imageAssetsArray:self.imageAlbumAssetArray tapAsset:asset];
            });
        }else{
            [self previewWithCell:cell imageAssetsArray:self.imageAlbumAssetArray tapAsset:asset];
        }
        
    }else{
        if ([self.select_imageArray count] > 0) {
            [BKTool showRemind:@"不能同时选择照片和视频"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
            });
            return;
        }
        
        BKShowExampleVideoView * exampleVideoView = [[BKShowExampleVideoView alloc]initWithAsset:asset];
        [exampleVideoView setFinishSelectOption:^(NSArray * imageArr, BKSelectPhotoType selectPhotoType) {
            if (self.finishSelectOption) {
                self.finishSelectOption(imageArr,selectPhotoType);
            }
        }];
        [exampleVideoView showInVC:self];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = YES;
    });
}

-(void)previewWithCell:(BKImagePickerCollectionViewCell*)cell imageAssetsArray:(NSArray*)imageAssetsArray tapAsset:(PHAsset*)tapAsset
{
    BKShowExampleImageView * exampleImageView = [[BKShowExampleImageView alloc]initWithLocationVC:self imageAssetsArray:[imageAssetsArray copy] selectImageArray:self.select_imageArray tapAsset:tapAsset maxSelect:self.max_select imageSizeArray:[self.imageSizeArray copy] selectResultImageDataArray:[self.selectResultImageDataArray copy] isOriginal:self.isOriginal];
    exampleImageView.tapImageView = cell.photoImageView;
    [exampleImageView setRefreshLookAsset:^(PHAsset * asset) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[self.albumAssetArray indexOfObject:asset] inSection:0];
        BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
        if (!cell) {
            [self.albumCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        }
    }];
    __weak BKShowExampleImageView * copyExampleImageView = exampleImageView;
    [exampleImageView setBackOption:^(PHAsset * asset, UIImageView * imageView) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[self.albumAssetArray indexOfObject:asset] inSection:0];
        BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
        
        cell.alpha = 0;
        
        CGRect cellImageFrame = [[cell.photoImageView superview] convertRect:cell.photoImageView.frame toView:self.view];
        
        CGRect imageViewFrame = [[imageView superview] convertRect:imageView.frame toView:copyExampleImageView];
        
        UIImageView * newImageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
        newImageView.clipsToBounds = YES;
        newImageView.contentMode = UIViewContentModeScaleAspectFill;
        newImageView.image = imageView.image;
        [copyExampleImageView addSubview:newImageView];
        [copyExampleImageView bringSubviewToFront:copyExampleImageView.topView];
        [copyExampleImageView bringSubviewToFront:copyExampleImageView.bottomView];
        
        [UIView animateWithDuration:BKCheckExampleImageAnimateTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            newImageView.frame = cellImageFrame;
            copyExampleImageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
            copyExampleImageView.topView.alpha = 0;
            copyExampleImageView.bottomView.alpha = 0;
        } completion:^(BOOL finished) {
            [newImageView removeFromSuperview];
            cell.alpha = 1;
            [copyExampleImageView removeFromSuperview];
        }];
    }];
    [exampleImageView setRefreshAlbumViewOption:^(NSArray * select_imageArray,NSArray * imageSizeArray,NSArray * selectResultImageDataArray,BOOL isOriginal) {
        self.select_imageArray = [NSMutableArray arrayWithArray:select_imageArray];
        [self.albumCollectionView reloadData];
        
        self.imageSizeArray = [NSMutableArray arrayWithArray:imageSizeArray];
        self.selectResultImageDataArray = [NSMutableArray arrayWithArray:selectResultImageDataArray];
        
        self.isOriginal = isOriginal;
        if (self.isOriginal) {
            [_originalBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
            [self calculataImageSize];
        }else{
            [_originalBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
            [_originalBtn setTitle:@"原图" forState:UIControlStateNormal];
        }
        
        [self refreshClassSelectImageArray];
    }];
    [exampleImageView setFinishSelectOption:^(id result, BKSelectPhotoType selectPhotoType) {
        if (self.finishSelectOption) {
            self.finishSelectOption(result, selectPhotoType);
        }
    }];
    [exampleImageView showAndBeginAnimateOption:^{
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
    
    PHAsset * asset = (PHAsset*)self.albumAssetArray[button.tag];
    BOOL isHave = [self.select_imageArray containsObject:asset];
    if (!isHave && [self.select_imageArray count] >= self.max_select) {
        [BKTool showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",self.max_select]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
        });
        return;
    }
    
    [button selectClickNum:[self.select_imageArray count]+1 addMethod:^{
        if (isHave) {
            
            NSInteger index = [self.select_imageArray indexOfObject:asset];
            [self.select_imageArray removeObjectAtIndex:index];
            [self.imageSizeArray removeObjectAtIndex:index];
            [self.selectResultImageDataArray removeObjectAtIndex:index];
            if (self.isOriginal) {
                [self calculataImageSize];
            }
            
            [self.select_imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[self.albumAssetArray indexOfObject:obj] inSection:0];
                [self.albumCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            
            [self refreshClassSelectImageArray];
        }else{
            
            [self.select_imageArray addObject:asset];
            [self getOriginalImageSizeWithAsset:asset complete:^(NSData *originalImageData, double originalImageSize, NSData *thumbImageData) {
                [self.imageSizeArray addObject:[NSString stringWithFormat:@"%f",originalImageSize]];
                if (self.isOriginal) {
                    [self calculataImageSize];
                }
                
                NSString * assetType = @"";
                NSString * fileName = [asset valueForKey:@"filename"];
                if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                    assetType = [NSString stringWithFormat:@"%ld",BKSelectPhotoTypeImage];
                }else{
                    assetType = [NSString stringWithFormat:@"%ld",BKSelectPhotoTypeGIF];
                }
                
                [self.selectResultImageDataArray addObject:@{@"original":originalImageData,@"thumb":thumbImageData,@"type":assetType}];
                
                [self refreshClassSelectImageArray];
            }];
        }
        
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
        
        if ([self.select_imageArray count] == 1) {
            [_previewBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
            [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
            [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
            
            [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
        }else if ([self.select_imageArray count] > 1) {
            
            [_previewBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
            [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
            [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
            
            [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
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
    
    if ([self.select_imageArray count] == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
        });
        return;
    }
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[self.albumAssetArray indexOfObject:[self.select_imageArray lastObject]] inSection:0];
    BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
    if (!cell) {
        [self.albumCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
            [self previewWithCell:cell imageAssetsArray:self.select_imageArray tapAsset:[self.select_imageArray lastObject]];
        });
    }else{
        [self previewWithCell:cell imageAssetsArray:self.select_imageArray tapAsset:[self.select_imageArray lastObject]];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.userInteractionEnabled = YES;
    });
}

-(void)editBtnClick:(UIButton*)button
{
    if ([self.select_imageArray count] > 1) {
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
    [self.imageSizeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        allSize = allSize + [obj doubleValue];
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
    if ([self.selectResultImageDataArray count] == 0) {
        return;
    }
    
    for (NSDictionary * dic in self.selectResultImageDataArray) {
        if (self.finishSelectOption) {
            if (self.isOriginal) {
                self.finishSelectOption([UIImage imageWithData:dic[@"original"]], [dic[@"type"] integerValue]);
            }else{
                self.finishSelectOption([UIImage imageWithData:dic[@"thumb"]], [dic[@"type"] integerValue]);
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 算图片大小和高清图data/缩略图data

-(void)getOriginalImageSizeWithAsset:(PHAsset*)asset complete:(void (^)(NSData * originalImageData , double originalImageSize , NSData * thumbImageData))complete
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

        if (complete) {
            NSData * thumbImageData = [BKTool compressImageData:imageData];
            complete(imageData,(double)imageData.length/1024/1024,thumbImageData);
        }
    }];
}

@end
