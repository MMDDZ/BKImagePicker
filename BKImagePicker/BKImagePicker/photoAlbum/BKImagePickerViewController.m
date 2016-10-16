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

#import "BKImagePickerViewController.h"
#import <Photos/Photos.h>
#import "BKImagePickerCollectionViewCell.h"
#import "BKImagePickerFooterCollectionReusableView.h"
#import "BKShowExampleImageViewController.h"

@interface BKImagePickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) PHFetchResult<PHAsset *> *assets;

@property (nonatomic,strong) NSMutableArray * albumImageArray;
@property (nonatomic,strong) UICollectionView * albumCollectionView;

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
    BKShowExampleImageViewController * vc =[[BKShowExampleImageViewController alloc]init];
    vc.title = [NSString stringWithFormat:@"%ld/%ld",indexPath.row+1,[self.assets countOfAssetsWithMediaType:PHAssetMediaTypeImage]];
    vc.assets = self.assets;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
