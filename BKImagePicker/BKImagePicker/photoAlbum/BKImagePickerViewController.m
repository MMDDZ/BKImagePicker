//
//  BKImagePickerViewController.m
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define item_space 6
#define item_Size CGSizeMake((self.view.frame.size.width-item_space*5)/4, (self.view.frame.size.width-item_space*5)/4)

#define imagePickerCell_identifier @"BKImagePickerCollectionViewCell"
#define imagePickerFooter_identifier @"BKImagePickerFooterCollectionReusableView"

#import "BKImageClassViewController.h"

#import "BKImagePickerViewController.h"
#import "BKImagePickerCollectionViewCell.h"
#import "BKImagePickerFooterCollectionReusableView.h"
#import "BKShowExampleImageViewController.h"
#import "SelectButton.h"

@interface BKImagePickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) PHFetchResult<PHAsset *> *assets;

@property (nonatomic,strong) UICollectionView * albumCollectionView;

/**
 该相簿中所有thumb_image数组 包括视频
 */
@property (nonatomic,strong) NSMutableArray * albumImageArray;

/**
 该相簿中所有PHAsset数组 包括视频
 */
@property (nonatomic,strong) NSMutableArray * albumAssetArray;

/**
 该相簿中所有PHAsset数组 不包括视频
 */
@property (nonatomic,strong) NSMutableArray * imageAssetArray;
/**
 该相簿中所有thumb_image数组 不包括视频
 */
@property (nonatomic,strong) NSMutableArray * thumbImageArray;

@property (nonatomic,assign) NSInteger allImageCount;

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

-(NSMutableArray*)imageAssetArray
{
    if (!_imageAssetArray) {
        _imageAssetArray = [NSMutableArray array];
    }
    return _imageAssetArray;
}

-(NSMutableArray*)thumbImageArray
{
    if (!_thumbImageArray) {
        _thumbImageArray = [NSMutableArray array];
    }
    return _thumbImageArray;
}

-(NSMutableArray*)select_imageArray
{
    if (!_select_imageArray) {
        _select_imageArray = [NSMutableArray array];
    }
    return _select_imageArray;
}

//更新选取的PHAsset数组
-(void)refreshClassSelectImageArray
{
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[BKImageClassViewController class]]) {
            BKImageClassViewController * vc = (BKImageClassViewController*)obj;
            vc.select_imageArray = self.select_imageArray;
            *stop = YES;
        }
    }];
}

-(void)getAllImageClassData
{
    //系统的相簿
    PHFetchResult * smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [self getSingleAlbum:smartAlbums];
    
    //用户自己创建的相簿
    PHFetchResult * userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    [self getSingleAlbum:userAlbums];
}

-(void)getSingleAlbum:(PHFetchResult*)fetchResult
{
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAssetCollection *collection = obj;
        
        if ([collection.localizedTitle isEqualToString:self.title]) {
            
            // 获取所有资源的集合按照创建时间排列
            __block PHFetchOptions * fetchOptions = [[PHFetchOptions alloc] init];
            fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            
            self.assets  = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            
            self.allImageCount = [self.assets count];
            
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = YES;
            
            [self.assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                PHCachingImageManager * imageManager = [[PHCachingImageManager alloc]init];
                [imageManager requestImageForAsset:obj targetSize:CGSizeMake(150, 150) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    // 排除取消，错误，低清图三种情况，即已经获取到了高清图
                    BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (downImageloadFinined) {
                        if(result)
                        {
                            if (obj.mediaType == PHAssetMediaTypeImage) {
                                [self.imageAssetArray addObject:obj];
                                [self.thumbImageArray addObject:result];
                            }
                            
                            [self.albumAssetArray addObject:obj];
                            [self.albumImageArray addObject:result];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.albumCollectionView reloadData];
                            });
                        }
                    }
                }];
            }];
            
            *stop = YES;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNav];
    [self.view addSubview:[self albumCollectionView]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self getAllImageClassData];
    });
}

-(void)initNav
{
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}


-(void)rightItemClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)selectButton:(SelectButton*)button
{
    [button selectClickNum:[self.select_imageArray count]+1 addMethod:^{
        PHAsset * asset = (PHAsset*)self.albumAssetArray[button.tag];
        [self.select_imageArray addObject:asset];
    }];
}

#pragma mark - UICollectionView

-(UICollectionView*)albumCollectionView
{
    if (!_albumCollectionView) {
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = item_Size;
        flowLayout.minimumLineSpacing = item_space;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(item_space, item_space, item_space, item_space);
        [flowLayout setFooterReferenceSize:CGSizeMake(self.view.frame.size.width, 40)];
        
        _albumCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) collectionViewLayout:flowLayout];
        _albumCollectionView.delegate = self;
        _albumCollectionView.dataSource = self;
        _albumCollectionView.showsVerticalScrollIndicator = NO;
        _albumCollectionView.backgroundColor = [UIColor clearColor];
        [_albumCollectionView registerClass:[BKImagePickerCollectionViewCell class] forCellWithReuseIdentifier:imagePickerCell_identifier];
        [_albumCollectionView registerClass:[BKImagePickerFooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:imagePickerFooter_identifier];
    }
    return _albumCollectionView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.albumImageArray count];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKImagePickerCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:imagePickerCell_identifier forIndexPath:indexPath];
    
    cell.photoImageView.image = self.albumImageArray[indexPath.row];
    
    PHAsset * asset = (PHAsset*)(self.assets[indexPath.row]);
    if (asset.mediaType == PHAssetMediaTypeImage) {
        
        cell.selectButton.hidden = NO;
        
        if ([self.select_imageArray containsObject:asset]) {
            NSInteger select_num = [self.select_imageArray indexOfObject:asset]+1;
            cell.selectButton.title = [NSString stringWithFormat:@"%ld",select_num];
        }
        
        cell.selectButton.tag = indexPath.item;
        [cell.selectButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        
        cell.selectButton.hidden = YES;
        
    }
    
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter){
        
        BKImagePickerFooterCollectionReusableView * footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:imagePickerFooter_identifier forIndexPath:indexPath];
        
        footerView.titleLab.text = [NSString stringWithFormat:@"共%ld张照片",self.allImageCount];
        
        reusableview = footerView;
    }
    
    return reusableview;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset * asset = (PHAsset*)(self.assets[indexPath.row]);
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        BKShowExampleImageViewController * vc =[[BKShowExampleImageViewController alloc]init];
        vc.thumbImageArray = self.thumbImageArray;
        vc.imageArray = self.imageAssetArray;
        vc.tap_asset = asset;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        
    }
}

@end
