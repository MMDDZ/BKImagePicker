//
//  BKImagePickerViewController.m
//  BKImagePicker
//
//  Created by BIKE on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import "BKImagePickerViewController.h"
#import "BKImagePicker.h"
#import "BKImageModel.h"
#import "BKTool.h"
#import "BKImagePickerCollectionViewCell.h"
#import "BKImagePickerFooterCollectionReusableView.h"
#import "BKImageAlbumItemSelectButton.h"
#import "BKShowExampleImageViewController.h"
#import "BKShowExampleVideoViewController.h"
#import "BKImageOriginalButton.h"
#import "BKEditImageViewController.h"

@interface BKImagePickerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,BKImagePickerCollectionViewCellDelegate,BKShowExampleImageViewControllerDelegate>

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
@property (nonatomic,strong) BKImageOriginalButton * originalBtn;
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
                
                switch ([BKTool sharedManager].photoType) {
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
    if ([BKTool sharedManager].max_select != 1) {
        [self initBottomNav];
    }
    
    [self getAllImageClassData];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.albumCollectionView.frame = CGRectMake(0, 0, self.view.bk_width, self.view.bk_height - self.bottomNavView.bk_height);
}

#pragma mark - UICollectionView

-(UICollectionView*)albumCollectionView
{
    if (!_albumCollectionView) {
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake((BK_SCREENW-BKAlbumImagesSpacing*5)/4, (BK_SCREENW-BKAlbumImagesSpacing*5)/4);
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
        [_albumCollectionView registerClass:[BKImagePickerCollectionViewCell class] forCellWithReuseIdentifier:@"BKImagePickerCollectionViewCell"];
        [_albumCollectionView registerClass:[BKImagePickerFooterCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"BKImagePickerFooterCollectionReusableView"];
        if (@available(iOS 11.0, *)) {
            _albumCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.view insertSubview:_albumCollectionView atIndex:0];
        
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
    BKImagePickerCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BKImagePickerCollectionViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.max_select = [BKTool sharedManager].max_select;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    BKImagePickerCollectionViewCell * currentCell = (BKImagePickerCollectionViewCell*)cell;
    
    BKImageModel * model = self.listArray[indexPath.item];
    if (model.thumbImage) {
        [currentCell revaluateIndexPath:indexPath listArr:[self.listArray copy] selectImageArr:[[BKTool sharedManager].selectImageArray copy]];
    }else{
        
        [[BKTool sharedManager] getThumbImageWithAsset:model.asset complete:^(UIImage *thumbImage) {
            model.thumbImage = thumbImage;
            
            [self.listArray replaceObjectAtIndex:indexPath.item withObject:model];
            
            if ([self.albumCollectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [currentCell revaluateIndexPath:indexPath listArr:[self.listArray copy] selectImageArr:[[BKTool sharedManager].selectImageArray copy]];
                });
            }
        }];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView * reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter){
        
        BKImagePickerFooterCollectionReusableView * footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"BKImagePickerFooterCollectionReusableView" forIndexPath:indexPath];
        
        switch ([BKTool sharedManager].photoType) {
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
    BKImageModel * model = self.listArray[indexPath.item];
    
    if (model.asset.mediaType == PHAssetMediaTypeImage) {
        
        //当裁剪比例不为0时 进入裁剪状态
        if ([BKTool sharedManager].clipSize_width_height_ratio != 0) {
            
            [[BKTool sharedManager] getOriginalImageWithAsset:model.asset complete:^(UIImage *originalImage) {
                BKEditImageViewController * vc = [[BKEditImageViewController alloc] init];
                vc.editImageArr = @[originalImage];
                vc.fromModule = BKEditImageFromModulePhotoAlbum;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            
        }else{
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
        }
        
    }else{
        if ([[BKTool sharedManager].selectImageArray count] > 0) {
            [[BKTool sharedManager] showRemind:@"不能同时选择照片和视频"];
            return;
        }
        
        BKShowExampleVideoViewController * vc = [[BKShowExampleVideoViewController alloc]init];
        vc.tapVideoModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)previewWithCell:(BKImagePickerCollectionViewCell*)cell imageListArray:(NSArray*)imageListArray tapModel:(BKImageModel*)tapModel
{
    if (!cell.photoImageView.image && cell) {
        return;
    }
    
    BKShowExampleImageViewController * vc = [[BKShowExampleImageViewController alloc]init];
    vc.delegate = self;
    vc.tapImageView = cell.photoImageView;
    vc.imageListArray = [imageListArray copy];
    vc.tapImageModel = tapModel;
    [vc showInNav:self.navigationController];
}

#pragma mark - BKShowExampleImageViewControllerDelegate

-(void)refreshLookLocationActionWithImageModel:(BKImageModel*)model
{
    __block BOOL isHaveFlag = NO;
    __block NSInteger item = 0;
    [_listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
}

-(CGRect)getFrameOfCurrentImageInListVCWithImageModel:(BKImageModel*)model
{
    __block BOOL isHaveFlag = NO;
    __block NSInteger item = 0;
    [self.listArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKImageModel * listModel = obj;
        if ([listModel.fileName isEqualToString:model.fileName]) {
            item = idx;
            isHaveFlag = YES;
            *stop = YES;
        }
    }];
    
    if (isHaveFlag) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        CGRect in_list_rect = [self.albumCollectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
        CGRect in_view_rect = [self.albumCollectionView convertRect:in_list_rect toView:self.view];
        return in_view_rect;
    }else{
        return CGRectZero;
    }
}

-(void)refreshSelectPhoto
{
    [_albumCollectionView reloadItemsAtIndexPaths:[_albumCollectionView indexPathsForVisibleItems]];
    
    if ([BKTool sharedManager].isOriginal) {
        [_originalBtn setTitleColor:BKHighlightColor];
        _originalBtn.isSelect = YES;
        [self calculataImageSize];
    }else{
        [_originalBtn setTitleColor:BKNavGrayTitleColor];
        _originalBtn.isSelect = NO;
        [_originalBtn setTitle:@"原图"];
    }
    
    [self refreshBottomNavBtnState];
}

#pragma mark - BKImagePickerCollectionViewCellDelegate

-(void)selectImageBtnClick:(BKImageAlbumItemSelectButton *)button withImageModel:(BKImageModel *)imageModel
{
    if (![[BKTool sharedManager].selectImageArray containsObject:imageModel]) {
        [[BKTool sharedManager].selectImageArray addObject:imageModel];
    }
    
    [[BKTool sharedManager].selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKImageModel * selectModel = obj;
        if ([selectModel.fileName isEqualToString:imageModel.fileName]) {
            NSArray * currentShowCellArr = [self.albumCollectionView visibleCells];
            for (int i = 0; i<[currentShowCellArr count]; i++) {
                BKImagePickerCollectionViewCell * cell = currentShowCellArr[i];
                if ([selectModel.fileName isEqualToString:cell.currentImageModel.fileName]) {
                    if (cell.currentImageModel.loadingState == BKImageDataLoadingStateLoading) {
                        [[BKTool sharedManager] hideLoadInView:cell];
                        cell.currentImageModel.loadingState = BKImageDataLoadingStateNone;
                    }else{
                        [[BKTool sharedManager] showLoadInView:cell downLoadProgress:0.55];
                        cell.currentImageModel.loadingState = BKImageDataLoadingStateLoading;
                    }
                    break;
                }
            }
            *stop = YES;
        }
    }];
    
    return;
    
    __block BOOL isHave = NO;
    __block NSInteger currentIndex;
    [[BKTool sharedManager].selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BKImageModel * selectModel = obj;
        if ([selectModel.fileName isEqualToString:imageModel.fileName]) {
            currentIndex = idx;
            isHave = YES;
        }
        
        NSArray * currentShowCellArr = [self.albumCollectionView visibleCells];
        for (int i = 0; i<[currentShowCellArr count]; i++) {
            BKImagePickerCollectionViewCell * cell = currentShowCellArr[i];
            if ([selectModel.fileName isEqualToString:cell.currentImageModel.fileName]) {
                if (isHave) {
                    if (currentIndex == idx) {
                        [cell.selectButton cancelSelect];
                    }else{
                        [cell.selectButton refreshSelectClickNum:idx];
                    }
                }else{
                    [cell.selectButton refreshSelectClickNum:idx+1];
                }
                break;
            }
        }
    }];
    
    if (isHave) {
        
        [[BKTool sharedManager].selectImageArray removeObjectAtIndex:currentIndex];
        
        if ([BKTool sharedManager].isOriginal) {
            [self calculataImageSize];
        }
    }else {
        if ([[BKTool sharedManager].selectImageArray count] >= [BKTool sharedManager].max_select) {
            [[BKTool sharedManager] showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",[BKTool sharedManager].max_select]];
            return;
        }
        
        [[BKTool sharedManager].selectImageArray addObject:imageModel];
        [button selectClickNum:[[BKTool sharedManager].selectImageArray count]];
        
        if (imageModel.loadingState == BKImageDataLoadingStateDownloadFinish) {
            if ([BKTool sharedManager].isOriginal) {
                [self calculataImageSize];
            }
        }else{
            
            [[BKTool sharedManager] getOriginalImageDataWithAsset:imageModel.asset progressHandler:^(double progress, NSError *error, PHImageRequestID imageRequestID) {
                
                if (error) {
                    [[BKTool sharedManager] hideLoadInView:self.view];
                    imageModel.loadingState = BKImageDataLoadingStateNone;
                    return;
                }
                
                [[BKTool sharedManager] showLoadInView:self.view downLoadProgress:progress];
                imageModel.loadingState = BKImageDataLoadingStateLoading;
                
            } complete:^(NSData *originalImageData, NSURL *url, PHImageRequestID imageRequestID) {
                
                [[BKTool sharedManager] hideLoadInView:self.view];
                
                if (originalImageData) {
                    imageModel.thumbImageData = [[BKTool sharedManager] compressImageData:originalImageData];
                    imageModel.originalImageData = originalImageData;
                    imageModel.loadingState = BKImageDataLoadingStateDownloadFinish;
                    imageModel.originalImageSize = (double)originalImageData.length/1024/1024;
                    imageModel.url = url;
                    
                    if ([BKTool sharedManager].isOriginal) {
                        [self calculataImageSize];
                    }
                }else{
                    imageModel.loadingState = BKImageDataLoadingStateNone;
                    [[BKTool sharedManager] showRemind:@"原图下载失败"];
                    //删除选中的自己
                    [self selectImageBtnClick:button withImageModel:imageModel];
                }
            }];
        }
    }
    
    [self refreshBottomNavBtnState];
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
  
    if ([BKTool sharedManager].isHaveOriginal) {
        [self.bottomNavView addSubview:[self originalBtn]];
    }
    [self.bottomNavView addSubview:[self sendBtn]];
    
    if ([[BKTool sharedManager].selectImageArray count] >= 1) {
        
        [_previewBtn setTitleColor:BKHighlightColor forState:UIControlStateNormal];
        
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:BKHighlightColor];
        
        [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[[BKTool sharedManager].selectImageArray count]] forState:UIControlStateNormal];
    }
}

/**
 更新底部按钮状态
 */
-(void)refreshBottomNavBtnState
{
    if ([[BKTool sharedManager].selectImageArray count] <= 0) {
        [_previewBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        [_sendBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:BKNavSendGrayBackgroundColor];
        
        [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
    }else {
        [_previewBtn setTitleColor:BKHighlightColor forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:BKHighlightColor];
        
        [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[[BKTool sharedManager].selectImageArray count]] forState:UIControlStateNormal];
    }
}

-(UIButton*)previewBtn
{
    if (!_previewBtn) {
        _previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewBtn.frame = CGRectMake(0, 0, self.view.bk_width/6, BK_SYSTEM_TABBAR_UI_HEIGHT);
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [_previewBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        _previewBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_previewBtn addTarget:self action:@selector(previewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewBtn;
}

-(BKImageOriginalButton*)originalBtn
{
    if (!_originalBtn) {
        _originalBtn = [[BKImageOriginalButton alloc]initWithFrame:CGRectMake(self.view.bk_width/6, 0, self.view.bk_width/7*3, BK_SYSTEM_TABBAR_UI_HEIGHT)];
        if ([BKTool sharedManager].isOriginal) {
            [_originalBtn setTitleColor:BKHighlightColor];
            _originalBtn.isSelect = YES;
            [self calculataImageSize];
        }else{
            [_originalBtn setTitleColor:BKNavGrayTitleColor];
            _originalBtn.isSelect = NO;
            [_originalBtn setTitle:@"原图"];
        }
        BK_WEAK_SELF(self);
        [_originalBtn setTapSelctAction:^{
            BK_STRONG_SELF(self);
            [strongSelf originalBtnClick];
        }];
    }
    return _originalBtn;
}

-(UIButton*)sendBtn
{
    if (!_sendBtn) {
        
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(self.view.bk_width/5*4, 6, self.view.bk_width/5-6, 37);
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
    if ([[BKTool sharedManager].selectImageArray count] == 0) {
        return;
    }
    
    BKImageModel * model = [[BKTool sharedManager].selectImageArray lastObject];
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
        [self previewWithCell:nil imageListArray:[BKTool sharedManager].selectImageArray tapModel:[[BKTool sharedManager].selectImageArray lastObject]];
    }else{
        BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
        if (!cell) {
            [self.albumCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BKImagePickerCollectionViewCell * cell = (BKImagePickerCollectionViewCell*)[self.albumCollectionView cellForItemAtIndexPath:indexPath];
                [self previewWithCell:cell imageListArray:[BKTool sharedManager].selectImageArray tapModel:[[BKTool sharedManager].selectImageArray lastObject]];
            });
        }else{
            [self previewWithCell:cell imageListArray:[BKTool sharedManager].selectImageArray tapModel:[[BKTool sharedManager].selectImageArray lastObject]];
        }
    }
}

-(void)originalBtnClick
{
    if (![BKTool sharedManager].isOriginal) {
        [_originalBtn setTitleColor:BKHighlightColor];
        [self calculataImageSize];
    }else{
        [_originalBtn setTitleColor:BKNavGrayTitleColor];
        [_originalBtn setTitle:@"原图"];
    }
    [BKTool sharedManager].isOriginal = ![BKTool sharedManager].isOriginal;
    [self refreshBottomNavBtnState];
}

-(void)calculataImageSize
{
    __block double allSize = 0.0;
    [[BKTool sharedManager].selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKImageModel * model = obj;
        allSize = allSize + model.originalImageSize;
    }];
    if (allSize>1024) {
        allSize = allSize / 1024;
        if (allSize > 1024) {
            allSize = allSize / 1024;
            [_originalBtn setTitle:[NSString stringWithFormat:@"原图(%.1fT)",allSize]];
        }else{
            [_originalBtn setTitle:[NSString stringWithFormat:@"原图(%.1fG)",allSize]];
        }
    }else{
        [_originalBtn setTitle:[NSString stringWithFormat:@"原图(%.1fM)",allSize]];
    }
}

-(void)sendBtnClick:(UIButton*)button
{
    if ([[BKTool sharedManager].selectImageArray count] == 0) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
