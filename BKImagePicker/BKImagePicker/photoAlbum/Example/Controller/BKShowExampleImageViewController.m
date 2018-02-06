//
//  BKShowExampleImageViewController.m
//  BKImagePicker
//
//  Created by zhaolin on 2018/2/6.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKShowExampleImageViewController.h"
#import "BKShowExampleImageCollectionViewFlowLayout.h"
#import "BKShowExampleImageCollectionViewCell.h"
#import "BKImageAlbumItemSelectButton.h"
#import "BKImagePickerConst.h"
#import "BKShowExampleInteractiveTransition.h"
#import "BKShowExampleTransitionAnimater.h"
#import "BKImageNavViewController.h"

@interface BKShowExampleImageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate>

@property (nonatomic,strong) BKImageAlbumItemSelectButton * rightNavBtn;

@property (nonatomic,strong) UIButton * editBtn;
@property (nonatomic,strong) UIButton * originalBtn;
@property (nonatomic,strong) UIButton * sendBtn;

@property (nonatomic,assign) NSInteger nowImageIndex;//当前看见image的index
@property (nonatomic,assign) BOOL isLoadOver;//是否加载完毕

@property (nonatomic,strong) UICollectionView * exampleImageCollectionView;

@property (nonatomic,strong) UINavigationController * nav;//导航
@property (nonatomic,strong) BKShowExampleInteractiveTransition * interactiveTransition;//交互方法

@end

@implementation BKShowExampleImageViewController

-(NSMutableArray*)selectImageArray
{
    if (!_selectImageArray) {
        _selectImageArray = [NSMutableArray array];
    }
    return _selectImageArray;
}

#pragma mark - 显示方法

-(void)showInNav:(UINavigationController*)nav
{
    _nav = nav;
    
    if ([nav isKindOfClass:[BKImageNavViewController class]]) {
        ((BKImageNavViewController*)_nav).isCustomTransition = YES;
    }
    _nav.delegate = self;
    [_nav pushViewController:self animated:YES];
}

#pragma mark - BKShowExampleInteractiveTransition

-(BKShowExampleInteractiveTransition*)interactiveTransition
{
    if (!_interactiveTransition) {
        _interactiveTransition = [[BKShowExampleInteractiveTransition alloc] init];
        [_interactiveTransition addPanGestureForViewController:self];
    }
    return _interactiveTransition;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        
        UIImageView * imageView = [self getTapImageView];
        
        BKShowExampleTransitionAnimater * transitionAnimater = [[BKShowExampleTransitionAnimater alloc] initWithTransitionType:BKShowExampleTransitionPush];
        transitionAnimater.startImageView = imageView;
        transitionAnimater.endRect = [self calculateTargetFrameWithImageView:imageView];
        BK_WEAK_SELF(self);
        [transitionAnimater setEndTransitionAnimateAction:^{
            BK_STRONG_SELF(self);
            strongSelf.exampleImageCollectionView.hidden = NO;
        }];
        
        return transitionAnimater;
    }else{
        
        _exampleImageCollectionView.hidden = YES;
        
        UIImageView * imageView = [self.delegate backActionWithImageModel:self.imageListArray[_nowImageIndex]];
        CGRect endRect = CGRectZero;
        if (imageView) {
            endRect = [imageView.superview convertRect:imageView.frame toView:self.view];
        }
        
        BKShowExampleTransitionAnimater * transitionAnimater = [[BKShowExampleTransitionAnimater alloc] initWithTransitionType:BKShowExampleTransitionPop];
        transitionAnimater.startImageView = self.interactiveTransition.startImageView;
        transitionAnimater.endRect = endRect;
        BK_WEAK_SELF(self);
        [transitionAnimater setEndTransitionAnimateAction:^{
            BK_STRONG_SELF(self);
            strongSelf.exampleImageCollectionView.hidden = NO;
        }];
        
        return transitionAnimater;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactiveTransition.interation?self.interactiveTransition:nil;
}

/**
 获取初始点击图片
 
 @return 图片
 */
-(UIImageView*)getTapImageView
{
    CGRect parentRect = [_tapImageView.superview convertRect:_tapImageView.frame toView:self.view];
    
    UIImageView * newImageView = [[UIImageView alloc]initWithFrame:parentRect];
    newImageView.contentMode = UIViewContentModeScaleAspectFill;
    newImageView.clipsToBounds = YES;
    if (_tapImageView.image) {
        newImageView.image = _tapImageView.image;
    }
    
    return newImageView;
}

/**
 获取初始图片动画后frame
 
 @param imageView 初始点击图片
 @return frame
 */
-(CGRect)calculateTargetFrameWithImageView:(UIImageView*)imageView
{
    CGRect targetFrame = CGRectZero;
    
    UIImage * image = imageView.image;
    
    targetFrame.size.width = self.view.frame.size.width;
    if (image) {
        CGFloat scale = image.size.width / targetFrame.size.width;
        targetFrame.size.height = image.size.height/scale;
        if (targetFrame.size.height < self.view.frame.size.height) {
            targetFrame.origin.y = (self.view.frame.size.height - targetFrame.size.height)/2;
        }
    }else{
        targetFrame.size.height = self.view.frame.size.width;
        targetFrame.origin.y = (self.view.frame.size.height - targetFrame.size.height)/2;
    }
    
    return targetFrame;
}

#pragma mark - viewDidload

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTopNav];
    [self initBottomNav];
    [self exampleImageCollectionView];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.exampleImageCollectionView.frame = CGRectMake(-BKExampleImagesSpacing, 0, self.view.bk_width + 2*BKExampleImagesSpacing, self.view.bk_height);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addObserver:self forKeyPath:@"nowImageIndex" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeObserver:self forKeyPath:@"nowImageIndex"];
}

#pragma mark - initTopNav

-(void)initTopNav
{
    if ([self.imageListArray count] == 1) {
        self.title = @"预览";
    }else{
        if ([_imageListArray count] > 0 && _tapImageModel) {
            self.nowImageIndex = [self.imageListArray indexOfObject:self.tapImageModel];
        }
        self.title = [NSString stringWithFormat:@"%ld/%ld",_nowImageIndex+1,[self.imageListArray count]];
    }
    
    [self.rightBtn addSubview:self.rightNavBtn];
}

-(BKImageAlbumItemSelectButton*)rightNavBtn
{
    if (!_rightNavBtn) {
        _rightNavBtn = [[BKImageAlbumItemSelectButton alloc]initWithFrame:CGRectMake(self.rightBtn.bk_width - 30 - 10, (self.rightBtn.bk_height - 30)/2, 30, 30)];
        __weak typeof(self) weakSelf = self;
        [_rightNavBtn setSelectButtonClick:^(BKImageAlbumItemSelectButton * button) {
            [weakSelf rightBtnClick:button];
        }];
        
        if ([self.imageListArray count] == 1) {
            if ([self.selectImageArray count] == 1) {
                _rightNavBtn.title = @"1";
            }else{
                _rightNavBtn.title = @"0";
            }
        }
    }
    return _rightNavBtn;
}

-(void)rightBtnClick:(BKImageAlbumItemSelectButton*)button
{
    BKImageModel * model = self.imageListArray[button.tag];
    BOOL isHave = [self.selectImageArray containsObject:model];
    if (!isHave && [self.selectImageArray count] >= self.maxSelect) {
        [[BKTool sharedManager] showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",self.maxSelect]];
        return;
    }
    
    [button selectClickNum:[self.selectImageArray count]+1 addMethod:^{
        if (isHave) {
            NSInteger index = [self.selectImageArray indexOfObject:model];
            [self.selectImageArray removeObjectAtIndex:index];
            if (self.isOriginal) {
                [self calculataImageSize];
            }
            
            if (self.refreshAlbumViewOption) {
                self.refreshAlbumViewOption([self.selectImageArray copy],self.isOriginal);
            }
            
            if ([self.selectImageArray count] == 0) {
                [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_sendBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:BKNavSendGrayBackgroundColor];
            }else if ([self.selectImageArray count] == 1) {
                
                BKImageModel * firstModel = self.selectImageArray[0];
                if (firstModel.photoType == BKSelectPhotoTypeImage) {
                    [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
                }else{
                    [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                }
            }
        }else{
            [self.selectImageArray addObject:model];
            
            if (self.refreshAlbumViewOption) {
                self.refreshAlbumViewOption([self.selectImageArray copy],self.isOriginal);
            }
            
            if (self.isOriginal) {
                [self calculataImageSize];
            }
            
            if ([self.selectImageArray count] == 1) {
                
                BKImageModel * firstModel = self.selectImageArray[0];
                if (firstModel.photoType == BKSelectPhotoTypeImage) {
                    [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
                }else{
                    [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                }
                [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
            }else if ([self.selectImageArray count] > 1) {
                [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
            }
        }
        
        if ([self.selectImageArray count] == 0) {
            [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
        }else{
            [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.selectImageArray count]] forState:UIControlStateNormal];
        }
        
        
    }];
}

#pragma mark - initBottomNav

-(void)initBottomNav
{
    self.bottomNavViewHeight = BK_SYSTEM_TABBAR_HEIGHT;
    
    if ([BKImagePicker sharedManager].isHaveEdit) {
        [self.bottomNavView addSubview:[self editBtn]];
    }
    if ([BKImagePicker sharedManager].isHaveOriginal) {
        [self.bottomNavView addSubview:[self originalBtn]];
    }
    [self.bottomNavView addSubview:[self sendBtn]];
    
    if (self.maxSelect == 1) {
        [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
        
        [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
    }else{
        if ([self.selectImageArray count] == 1) {
            [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
            [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
            
            [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.selectImageArray count]] forState:UIControlStateNormal];
        }else if ([self.selectImageArray count] > 1) {
            [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
            [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
            
            [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.selectImageArray count]] forState:UIControlStateNormal];
        }
    }
}

-(UIButton*)editBtn
{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame = CGRectMake(0, 0, self.view.bk_width / 6, 49);
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
        _originalBtn.frame = CGRectMake(BK_SCREENW/6, 0, BK_SCREENW/7*3, 49);
        if (![BKImagePicker sharedManager].isHaveEdit) {
            _originalBtn.bk_x = 0;
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
        _sendBtn.frame = CGRectMake(self.view.bk_width/4*3, 6, self.view.bk_width/4-6, 37);
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

-(void)editBtnClick:(UIButton*)button
{
    //    BKImageModel * model = _imageListArray[_nowImageIndex];
    //    if (model.originalImageData) {
    //        UIImage * originalImage = [UIImage imageWithData:model.originalImageData];
    //        BKEditPhotoView * editView = [[BKEditPhotoView alloc]initWithImage:originalImage];
    //        [self addSubview:editView];
    //    }else{
    //        [self getOriginalImageSizeWithAsset:model.asset complete:^(UIImage *originalImage) {
    //            BKEditPhotoView * editView = [[BKEditPhotoView alloc]initWithImage:originalImage];
    //            [self addSubview:editView];
    //        }];
    //    }
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
    if (self.refreshAlbumViewOption) {
        self.refreshAlbumViewOption([self.selectImageArray copy],self.isOriginal);
    }
}

-(void)calculataImageSize
{
    __block double allSize = 0.0;
    if (self.maxSelect == 1) {
        BKImageModel * model = _imageListArray[_nowImageIndex];
        allSize = model.originalImageSize;
    }else{
        [self.selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            BKImageModel * model = obj;
            allSize = allSize + model.originalImageSize;
        }];
    }
    
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
        if (self.maxSelect == 1) {
            
            BKImageModel * model = _imageListArray[_nowImageIndex];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:@{@"object":model,@"isOriginal":@(_isOriginal)}];
            [self.getCurrentVC dismissViewControllerAnimated:YES completion:nil];
        }
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:@{@"object":self.selectImageArray,@"isOriginal":@(_isOriginal)}];
    [self.getCurrentVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView

-(UICollectionView*)exampleImageCollectionView
{
    if (!_exampleImageCollectionView) {
        
        BKShowExampleImageCollectionViewFlowLayout * flowLayout = [[BKShowExampleImageCollectionViewFlowLayout alloc]init];
        flowLayout.allImageCount = [self.imageListArray count];
        
        _exampleImageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _exampleImageCollectionView.delegate = self;
        _exampleImageCollectionView.dataSource = self;
        _exampleImageCollectionView.backgroundColor = [UIColor clearColor];
        _exampleImageCollectionView.showsVerticalScrollIndicator = NO;
        _exampleImageCollectionView.showsHorizontalScrollIndicator = NO;
        _exampleImageCollectionView.pagingEnabled = YES;
        _exampleImageCollectionView.hidden = YES;
        if (@available(iOS 11.0, *)) {
            _exampleImageCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_exampleImageCollectionView registerClass:[BKShowExampleImageCollectionViewCell class] forCellWithReuseIdentifier:@"BKShowExampleImageCollectionViewCell"];
        
        UITapGestureRecognizer * exampleImageCollectionViewTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exampleImageCollectionViewTapRecognizer)];
        [_exampleImageCollectionView addGestureRecognizer:exampleImageCollectionViewTapRecognizer];
        
        [self.view insertSubview:_exampleImageCollectionView atIndex:0];
        
        [_exampleImageCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _exampleImageCollectionView;
}

-(void)exampleImageCollectionViewTapRecognizer
{
    [UIApplication sharedApplication].statusBarHidden = ![UIApplication sharedApplication].statusBarHidden;
    if ([UIApplication sharedApplication].statusBarHidden) {
        self.topNavView.alpha = 0;
        self.bottomNavView.alpha = 0;
        
        self.interactiveTransition.isNavHidden = YES;
    }else{
        self.topNavView.alpha = 0.8;
        self.bottomNavView.alpha = 0.8;
        
        self.interactiveTransition.isNavHidden = NO;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageListArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"BKShowExampleImageCollectionViewCell" forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKShowExampleImageCollectionViewCell * currentCell = (BKShowExampleImageCollectionViewCell*)cell;
    
    BKImageModel * model = self.imageListArray[indexPath.item];
    
    if (model.photoType == BKSelectPhotoTypeImage) {
        [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
        
        if (model.thumbImage) {
            [self editImageView:currentCell.showImageView image:model.thumbImage imageData:nil scrollView:currentCell.imageScrollView];
            [self getOriginalImageSizeWithAsset:model.asset complete:^(UIImage *originalImage) {
                [self editImageView:currentCell.showImageView image:originalImage imageData:nil scrollView:currentCell.imageScrollView];
            }];
        }else{
            [self getThumbImageSizeWithAsset:model.asset complete:^(UIImage *thumbImage) {
                [self editImageView:currentCell.showImageView image:thumbImage imageData:nil scrollView:currentCell.imageScrollView];
                model.thumbImage = thumbImage;
                
                [self getOriginalImageSizeWithAsset:model.asset complete:^(UIImage *originalImage) {
                    [self editImageView:currentCell.showImageView image:originalImage imageData:nil scrollView:currentCell.imageScrollView];
                }];
            }];
        }
        
        if (model.originalImageData) {
            if (self.isOriginal && self.maxSelect == 1) {
                [self calculataImageSize];
            }
        }else{
            [self getOriginalImageDataSizeWithAsset:model.asset complete:^(NSData * originalImageData,NSURL * url) {
                
                model.originalImageData = originalImageData;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    model.thumbImageData = [[BKTool sharedManager] compressImageData:originalImageData];
                });
                model.url = url;
                model.originalImageSize = (double)originalImageData.length/1024/1024;
                if (self.isOriginal && self.maxSelect == 1) {
                    [self calculataImageSize];
                }
            }];
        }
    }else{
        [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        
        if (model.thumbImage){
            [self editImageView:currentCell.showImageView image:model.thumbImage imageData:nil scrollView:currentCell.imageScrollView];
            
            [self initCell:currentCell gifImageModel:model];
            
        }else{
            [self getThumbImageSizeWithAsset:model.asset complete:^(UIImage *thumbImage) {
                [self editImageView:currentCell.showImageView image:thumbImage imageData:nil scrollView:currentCell.imageScrollView];
                model.thumbImage = thumbImage;
                
                [self initCell:currentCell gifImageModel:model];
            }];
        }
    }
}

-(void)initCell:(BKShowExampleImageCollectionViewCell*)cell gifImageModel:(BKImageModel*)model
{
    if (model.originalImageData) {
        
        [self editImageView:cell.showImageView image:model.thumbImage imageData:model.originalImageData scrollView:cell.imageScrollView];
        
        if (self.isOriginal && self.maxSelect == 1) {
            [self calculataImageSize];
        }
    }else{
        [self getOriginalImageDataSizeWithAsset:model.asset complete:^(NSData * originalImageData,NSURL * url) {
            
            [self editImageView:cell.showImageView image:model.thumbImage imageData:originalImageData scrollView:cell.imageScrollView];
            
            model.originalImageData = originalImageData;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                model.thumbImageData = [[BKTool sharedManager] compressImageData:originalImageData];
            });
            
            model.url = model.url;
            model.originalImageSize = (double)originalImageData.length/1024/1024;
            if (self.isOriginal && self.maxSelect == 1) {
                [self calculataImageSize];
            }
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKShowExampleImageCollectionViewCell * currentCell = (BKShowExampleImageCollectionViewCell*)cell;
    
    currentCell.imageScrollView.zoomScale = 1;
    currentCell.imageScrollView.contentSize = CGSizeMake(currentCell.bk_width-BKExampleImagesSpacing*2, currentCell.bk_height);
}

#pragma mark - 缩略图 、 原图 、 原图data

/**
 获取对应缩略图
 
 @param asset 相簿
 @param complete 完成方法
 */
-(void)getThumbImageSizeWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * thumbImage))complete
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(self.view.bk_width/2.0f, self.view.bk_width/2.0f) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
        BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downImageloadFinined) {
            if(result) {
                if (complete) {
                    complete(result);
                }
            }
        }
    }];
}

/**
 获取对应原图
 
 @param asset 相簿
 @param complete 完成方法
 */
-(void)getOriginalImageSizeWithAsset:(PHAsset*)asset complete:(void (^)(UIImage * originalImage))complete
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
        BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downImageloadFinined) {
            if(result) {
                if (complete) {
                    complete(result);
                }
            }
        }
    }];
}

/**
 获取对应原图data
 
 @param asset 相簿
 @param complete 完成方法
 */
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

#pragma mark - 整合image与imageView

/**
 修改图frame
 
 @param showImageView   image所在的imageVIew
 @param image           image
 @param imageData       imageData
 @param imageScrollView image所在的scrollView
 */
-(void)editImageView:(FLAnimatedImageView*)showImageView image:(UIImage*)image imageData:(NSData*)imageData scrollView:(UIScrollView*)imageScrollView
{
    if (!imageData && !image) {
        return;
    }
    
    showImageView.image = image;
    
    if (imageData) {
        FLAnimatedImage * gifImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
        if (gifImage) {
            showImageView.animatedImage = gifImage;
        }
    }
    
    CGRect showImageViewFrame = [self calculateTargetFrameWithImageView:showImageView];
    
    CGFloat scale = image.size.width / self.view.bk_width;
    imageScrollView.maximumZoomScale = scale<2?2:scale;
    
    showImageView.frame = showImageViewFrame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _exampleImageCollectionView) {
        if (_isLoadOver) {
            
            CGPoint p = [self.view convertPoint:self.exampleImageCollectionView.center toView:self.exampleImageCollectionView];
            NSIndexPath * indexPath = [self.exampleImageCollectionView indexPathForItemAtPoint:p];
            NSInteger item = indexPath.item;
            
            BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[_exampleImageCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0]];
            self.interactiveTransition.startImageView = cell.showImageView;
            
            self.nowImageIndex = item;
        }
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"nowImageIndex"]) {
        
        self.titleLab.text = [NSString stringWithFormat:@"%ld/%ld",_nowImageIndex+1,[self.imageListArray count]];
        
        BKImageModel * model = self.imageListArray[_nowImageIndex];
        if (self.delegate) {
            [self.delegate refreshLookLocationActionWithImageModel:model];
        }
        
        if ([self.selectImageArray containsObject:model]) {
            NSInteger select_num = [self.selectImageArray indexOfObject:model]+1;
            self.rightNavBtn.title = [NSString stringWithFormat:@"%ld",select_num];
        }else{
            self.rightNavBtn.title = @"";
        }
        self.rightBtn.tag = _nowImageIndex;
        
    }else if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGFloat contentOffX = (self.view.bk_width+BKExampleImagesSpacing*2) * _nowImageIndex;
        if (_exampleImageCollectionView.contentSize.width - _exampleImageCollectionView.bk_width >= contentOffX) {
            [_exampleImageCollectionView setContentOffset:CGPointMake(contentOffX, 0) animated:NO];
        }
        
        [_exampleImageCollectionView removeObserver:self forKeyPath:@"contentSize"];
        _isLoadOver = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[_exampleImageCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_nowImageIndex inSection:0]];
            self.interactiveTransition.startImageView = cell.showImageView;
        });
    }
}

@end

