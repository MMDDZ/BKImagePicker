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

#define imageSize CGSizeMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.width/2.0f)

#import "BKImageClassViewController.h"

#import "BKImagePickerViewController.h"
#import "BKImagePickerCollectionViewCell.h"
#import "BKImagePickerFooterCollectionReusableView.h"
#import "BKShowExampleImageViewController.h"
#import "BKImageAlbumItemSelectButton.h"
#import "BKTool.h"
#import "BKShowExampleVideoView.h"
#import "BKShowExampleGIFView.h"

@interface BKImagePickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,BKImagePickerCollectionViewCellDelegate>

@property (nonatomic,strong) PHImageRequestOptions * options;

@property (nonatomic,strong) UICollectionView * albumCollectionView;

/**
 该相簿中所有thumb_image数组 包括视频 & GIF
 */
@property (nonatomic,strong) NSMutableArray * albumImageArray;

/**
 该相簿中所有PHAsset数组 包括视频 & GIF
 */
@property (nonatomic,strong) NSMutableArray * albumAssetArray;

/**
 该相簿中所有PHAsset数组 不包括视频 & GIF
 */
@property (nonatomic,strong) NSMutableArray * imageAssetArray;
/**
 该相簿中所有thumb_image数组 不包括视频 & GIF
 */
@property (nonatomic,strong) NSMutableArray * thumbImageArray;

/**
 该相簿中所有照片和视频总数
 */
@property (nonatomic,assign) NSInteger allAlbumImageNum;

@property (nonatomic,strong) UIView * bottomView;
@property (nonatomic,strong) UIButton * previewBtn;
@property (nonatomic,strong) UIButton * editBtn;
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
            vc.select_imageArray = [NSArray arrayWithArray:self.select_imageArray];
            
            if ([self.select_imageArray count] == 0) {
                [_sendBtn setTitle:@"确定" forState:UIControlStateNormal];
            }else{
                [_sendBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
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
            
            PHFetchResult<PHAsset *> * assets  = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
            
            self.allAlbumImageNum = [assets count];
            
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (obj.mediaType == PHAssetMediaTypeImage) {
                    
                    NSString * fileName = [obj valueForKey:@"filename"];
                    if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                        
                        [self.imageAssetArray addObject:obj];
                    }
                }
                
                [self.albumImageArray addObject:@""];
                [self.albumAssetArray addObject:obj];

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNav];
    [self.view addSubview:[self albumCollectionView]];
    [self.view addSubview:[self bottomView]];
    
    [self getAllImageClassData];
}

-(void)initNav
{
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithTitle:@"取消   " style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
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
        
        footerView.titleLab.text = [NSString stringWithFormat:@"共%ld张照片",self.allAlbumImageNum];
        
        reusableview = footerView;
    }
    
    return reusableview;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset * asset = (PHAsset*)(self.albumAssetArray[indexPath.row]);
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        NSString * fileName = [asset valueForKey:@"filename"];
        if ([fileName rangeOfString:@"gif"].location != NSNotFound || [fileName rangeOfString:@"GIF"].location != NSNotFound) {
            if ([self.select_imageArray count] > 0) {
                [BKTool showRemind:@"不能同时选择照片和GIF"];
                return;
            }
            
            BKShowExampleGIFView * gifView = [[BKShowExampleGIFView alloc]initWithAsset:asset];
            [gifView setFinishSelectOption:^(NSArray * imageArr, BKSelectPhotoType selectPhotoType) {
                if (self.finishSelectOption) {
                    self.finishSelectOption(imageArr,selectPhotoType);
                }
            }];
            [gifView showInVC:self];
        }else{
            BKShowExampleImageViewController * vc =[[BKShowExampleImageViewController alloc]init];
            vc.imageAssetsArray = [NSArray arrayWithArray:self.imageAssetArray];
            vc.select_imageArray = [NSMutableArray arrayWithArray:self.select_imageArray];
            vc.max_select = self.max_select;
            vc.tap_asset = asset;
            [vc setRefreshAlbumViewOption:^(NSMutableArray * select_imageArray) {
                self.select_imageArray = [NSMutableArray arrayWithArray:select_imageArray];
                [self.albumCollectionView reloadData];
            }];
            [vc setFinishSelectOption:^(NSArray * imageArr, BKSelectPhotoType selectPhotoType) {
                if (self.finishSelectOption) {
                    self.finishSelectOption(self.select_imageArray.copy, BKSelectPhotoTypeImage);
                }
            }];
            [self.navigationController pushViewController:vc animated:NO];
        }
    }else{
        if ([self.select_imageArray count] > 0) {
            [BKTool showRemind:@"不能同时选择照片和视频"];
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
}

#pragma mark - BKImagePickerCollectionViewCellDelegate

-(void)selectImageBtnClick:(BKImageAlbumItemSelectButton*)button
{
    PHAsset * asset = (PHAsset*)self.albumAssetArray[button.tag];
    BOOL isHave = [self.select_imageArray containsObject:asset];
    if (!isHave && [self.select_imageArray count] >= self.max_select) {
        [BKTool showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",self.max_select]];
        return;
    }
    
    [button selectClickNum:[self.select_imageArray count]+1 addMethod:^{
        if (isHave) {
            [self.select_imageArray removeObject:asset];
            [self.select_imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[self.albumAssetArray indexOfObject:obj] inSection:0];
                [self.albumCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            
            if ([self.select_imageArray count] == 0) {
                [_previewBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
                [_editBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
                [_sendBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1]];
            }else if ([self.select_imageArray count] == 1) {
                [_editBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
            }
        }else{
            [self.select_imageArray addObject:asset];
            if ([self.select_imageArray count] == 1) {
                [_previewBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
                [_editBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
                [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1]];
            }else if ([self.select_imageArray count] > 1) {
                [_editBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
            }
        }
        
        [self refreshClassSelectImageArray];
    }];
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
        
        [_bottomView addSubview:[self previewBtn]];
        [_bottomView addSubview:[self editBtn]];
        [_bottomView addSubview:[self sendBtn]];
        
        if ([self.select_imageArray count] == 1) {
            [_previewBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
            [_editBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
            [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sendBtn setBackgroundColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1]];
            
            [_sendBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
        }else if ([self.select_imageArray count] > 1) {
            
            [_previewBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
            [_editBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
            [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sendBtn setBackgroundColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1]];
            
            [_sendBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
        }
        
    }
    return _bottomView;
}

-(UIButton*)previewBtn
{
    if (!_previewBtn) {
        _previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewBtn.frame = CGRectMake(0, 0, self.view.frame.size.width/6, 49);
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [_previewBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
        _previewBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_previewBtn addTarget:self action:@selector(previewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewBtn;
}

-(UIButton*)editBtn
{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame = CGRectMake(self.view.frame.size.width/6, 0, self.view.frame.size.width/6, 49);
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

-(UIButton*)sendBtn
{
    if (!_sendBtn) {
        
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(self.view.frame.size.width/4*3, 6, self.view.frame.size.width/4-6, 37);
        [_sendBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1]];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _sendBtn.layer.cornerRadius = 4;
        _sendBtn.clipsToBounds = YES;
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _sendBtn;
}

-(void)previewBtnClick:(UIButton*)button
{
    if ([self.select_imageArray count] == 0) {
        return;
    }
    
    BKShowExampleImageViewController * vc = [[BKShowExampleImageViewController alloc]init];
    vc.select_imageArray = [NSMutableArray arrayWithArray:self.select_imageArray];
    vc.max_select = self.max_select;
    vc.tap_asset = [self.select_imageArray lastObject];
    [vc setRefreshAlbumViewOption:^(NSMutableArray * select_imageArray) {
        
        NSArray * oldSelect_imageArr = [NSArray arrayWithArray:self.select_imageArray];
        
        self.select_imageArray = [NSMutableArray arrayWithArray:select_imageArray];
        
        [oldSelect_imageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:[self.albumAssetArray indexOfObject:obj] inSection:0];
            [self.albumCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
    }];
    [vc setFinishSelectOption:^(NSArray * imageArr, BKSelectPhotoType selectPhotoType) {
        if (self.finishSelectOption) {
            self.finishSelectOption(self.select_imageArray.copy, BKSelectPhotoTypeImage);
        }
    }];
    [self.navigationController pushViewController:vc animated:NO];
}

-(void)editBtnClick:(UIButton*)button
{
    if ([self.select_imageArray count] > 1) {
        return;
    }
}

-(void)sendBtnClick:(UIButton*)button
{
    if (self.finishSelectOption) {
        self.finishSelectOption(self.select_imageArray.copy, BKSelectPhotoTypeImage);
    }
}

@end
