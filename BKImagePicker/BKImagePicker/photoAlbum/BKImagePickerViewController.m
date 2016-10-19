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
#import "BKTool.h"

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

/**
 该相簿中所有相册和视频总数
 */
@property (nonatomic,assign) NSInteger allAlbumImageNum;

@property (nonatomic,strong) UIView * bottomView;
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
            
            if ([self.select_imageArray count] == 0) {
                [_sendBtn setTitle:@"确定" forState:UIControlStateNormal];
            }else{
                [_sendBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
            }
            
            *stop = YES;
        }
    }];
}

-(void)getAllImageClassData
{
    [self.albumCollectionView setHidden:YES];
    [[BKTool shareInstance] showLoad];
    
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
            
            self.allAlbumImageNum = [self.assets count];
            
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
                                if ([self.albumImageArray count] == self.allAlbumImageNum) {
                                    [self.albumCollectionView reloadData];
                                    [self.albumCollectionView setContentOffset:CGPointMake(0, self.albumCollectionView.contentSize.height - self.albumCollectionView.frame.size.height)];
                                    
                                    [self.albumCollectionView setHidden:NO];
//                                    [[BKTool shareInstance] hideLoad];
                                }
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
    [self.view addSubview:[self bottomView]];
    
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
        
        _albumCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64-49) collectionViewLayout:flowLayout];
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
        }else{
            cell.selectButton.title = @"";
        }
        
        cell.selectButton.tag = indexPath.item;
        [cell.selectButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        cell.selectButton.hidden = YES;
    }
    
    return cell;
}

-(void)selectButton:(SelectButton*)button
{
    PHAsset * asset = (PHAsset*)self.albumAssetArray[button.tag];
    BOOL isHave = [self.select_imageArray containsObject:asset];
    if (!isHave && [self.select_imageArray count] >= self.max_select) {
        [[BKTool shareInstance] showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",self.max_select]];
        return;
    }
    
    [button selectClickNum:[self.select_imageArray count]+1 addMethod:^{
        if (isHave) {
            [self.select_imageArray removeObject:asset];
            [self.albumCollectionView reloadData];
        }else{
            [self.select_imageArray addObject:asset];
        }
        
        [self refreshClassSelectImageArray];
    }];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter){
        
        BKImagePickerFooterCollectionReusableView * footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:imagePickerFooter_identifier forIndexPath:indexPath];
        
        footerView.titleLab.text = [NSString stringWithFormat:@"共%ld张照片",self.allAlbumImageNum];
        
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
        if ([self.select_imageArray count] > 0) {
            [[BKTool shareInstance] showRemind:@"不能同时选择照片和视频"];
            return;
        }
    }
}

#pragma mark - BottomView

-(UIView*)bottomView
{
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-49, self.view.frame.size.width, 49)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        
        UIImageView * lineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.3)];
        lineView.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
        [_bottomView addSubview:lineView];
        
        UIButton * previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        previewBtn.frame = CGRectMake(0, 0, self.view.frame.size.width/6, 49);
        [previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [previewBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
        previewBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [previewBtn addTarget:self action:@selector(previewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:previewBtn];
        
        UIButton * editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        editBtn.frame = CGRectMake(self.view.frame.size.width/6, 0, self.view.frame.size.width/6, 49);
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [editBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
        editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:editBtn];
        
        [_bottomView addSubview:[self sendBtn]];
    }
    return _bottomView;
}

-(UIButton*)sendBtn
{
    if (!_sendBtn) {
        
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(self.view.frame.size.width/4*3, 6, self.view.frame.size.width/4-6, 37);
        [_sendBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1]];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _sendBtn.layer.cornerRadius = 4;
        _sendBtn.clipsToBounds = YES;
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _sendBtn;
}

-(void)previewBtnClick:(UIButton*)button
{
    
}

-(void)editBtnClick:(UIButton*)button
{
    
}

-(void)sendBtnClick:(UIButton*)button
{
    
}

@end
