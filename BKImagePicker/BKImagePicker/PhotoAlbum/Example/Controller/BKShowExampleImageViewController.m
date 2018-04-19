//
//  BKShowExampleImageViewController.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/6.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKShowExampleImageViewController.h"
#import "BKShowExampleImageCollectionViewFlowLayout.h"
#import "BKShowExampleImageCollectionViewCell.h"
#import "BKImageAlbumItemSelectButton.h"
#import "BKTool.h"
#import "BKShowExampleInteractiveTransition.h"
#import "BKShowExampleTransitionAnimater.h"
#import "BKEditImageViewController.h"
#import "BKImageOriginalButton.h"

@interface BKShowExampleImageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate>

@property (nonatomic,strong) BKImageAlbumItemSelectButton * rightNavBtn;

@property (nonatomic,strong) UIButton * editBtn;
@property (nonatomic,strong) BKImageOriginalButton * originalBtn;
@property (nonatomic,strong) UIButton * sendBtn;

@property (nonatomic,assign) NSInteger currentImageIndex;//当前image的index
@property (nonatomic,assign) BOOL isLoadOver;//是否加载完毕
@property (nonatomic,assign) BOOL currentOriginalImageLoadedFlag;//当前image的原图是否加载完毕

@property (nonatomic,strong) UICollectionView * exampleImageCollectionView;

@property (nonatomic,strong) UINavigationController * nav;//导航
@property (nonatomic,strong) BKShowExampleInteractiveTransition * interactiveTransition;//交互方法

@end

@implementation BKShowExampleImageViewController

#pragma mark - 显示方法

-(void)showInNav:(UINavigationController*)nav
{
    _nav = nav;
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
        
        CGRect endRect = [self.delegate getFrameOfCurrentImageInListVCWithImageModel:self.imageListArray[_currentImageIndex]];
        
        BKShowExampleTransitionAnimater * transitionAnimater = [[BKShowExampleTransitionAnimater alloc] initWithTransitionType:BKShowExampleTransitionPop];
        transitionAnimater.startImageView = CGRectEqualToRect(self.interactiveTransition.panImageView.frame, CGRectZero)?self.interactiveTransition.startImageView:self.interactiveTransition.panImageView;
        transitionAnimater.endRect = endRect;
        BK_WEAK_SELF(self);
        [transitionAnimater setEndTransitionAnimateAction:^{
            BK_STRONG_SELF(self);
            strongSelf.exampleImageCollectionView.hidden = NO;
            strongSelf.nav.delegate = nil;
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.nav.delegate = self;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.exampleImageCollectionView.frame = CGRectMake(-BKExampleImagesSpacing, 0, self.view.bk_width + 2*BKExampleImagesSpacing, self.view.bk_height);
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"currentImageIndex"];
}

#pragma mark - initTopNav

-(void)initTopNav
{
    [self addObserver:self forKeyPath:@"currentImageIndex" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    if ([self.imageListArray count] == 1) {
        self.title = @"预览";
    }else{
        if ([_imageListArray count] > 0 && _tapImageModel) {
            self.currentImageIndex = [self.imageListArray indexOfObject:self.tapImageModel];
        }
        self.title = [NSString stringWithFormat:@"%ld/%ld",_currentImageIndex+1,[self.imageListArray count]];
    }
    
    if ([BKTool sharedManager].max_select > 1) {
        [self.rightBtn addSubview:self.rightNavBtn];
    }
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
            if ([[BKTool sharedManager].selectImageArray count] == 1) {
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
    BKImageModel * model = self.imageListArray[_currentImageIndex];
    BOOL isHave = [[BKTool sharedManager].selectImageArray containsObject:model];
    if (!isHave && [[BKTool sharedManager].selectImageArray count] >= [BKTool sharedManager].max_select) {
        [[BKTool sharedManager] showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",[BKTool sharedManager].max_select]];
        return;
    }
    
    if (isHave) {
        [[BKTool sharedManager].selectImageArray removeObject:model];
        [button cancelSelect];
    }else{
        [[BKTool sharedManager].selectImageArray addObject:model];
        [button selectClickNum:[[BKTool sharedManager].selectImageArray count]];
    }
    
    if ([BKTool sharedManager].isOriginal) {
        [self calculataImageSize];
    }
    
    __block BOOL canEidtFlag = YES;
    [[BKTool sharedManager].selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKImageModel * currentImageModel = obj;
        if (currentImageModel.photoType != BKSelectPhotoTypeImage) {
            canEidtFlag = NO;
            *stop = YES;
        }
    }];
    
    if (canEidtFlag) {
        [_editBtn setTitleColor:BKHighlightColor forState:UIControlStateNormal];
    }else{
        [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
    }
    
    if ([[BKTool sharedManager].selectImageArray count] == 0) {
        [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
    }else {
        [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[[BKTool sharedManager].selectImageArray count]] forState:UIControlStateNormal];
    }
    
    if ([self.delegate respondsToSelector:@selector(refreshSelectPhoto)]) {
        [self.delegate refreshSelectPhoto];
    }
}

#pragma mark - initBottomNav

-(void)initBottomNav
{
    self.bottomNavViewHeight = BK_SYSTEM_TABBAR_HEIGHT;
    
    [self.bottomNavView addSubview:[self editBtn]];
    if ([BKTool sharedManager].isHaveOriginal) {
        [self.bottomNavView addSubview:[self originalBtn]];
    }
    [self.bottomNavView addSubview:[self sendBtn]];
    
    __block BOOL canEidtFlag = YES;
    [[BKTool sharedManager].selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BKImageModel * currentImageModel = obj;
        if (currentImageModel.photoType != BKSelectPhotoTypeImage) {
            canEidtFlag = NO;
            *stop = YES;
        }
    }];
    
    BKImageModel * currentImageModel = self.imageListArray[_currentImageIndex];
    if (currentImageModel.photoType != BKSelectPhotoTypeImage) {
        canEidtFlag = NO;
    }
    
    if (canEidtFlag) {
        [_editBtn setTitleColor:BKHighlightColor forState:UIControlStateNormal];
    }else{
        [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
    }
    
    if ([[BKTool sharedManager].selectImageArray count] == 0) {
        [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
    }else {
        [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[[BKTool sharedManager].selectImageArray count]] forState:UIControlStateNormal];
    }
}

-(UIButton*)editBtn
{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame = CGRectMake(0, 0, self.view.bk_width / 6, BK_SYSTEM_TABBAR_UI_HEIGHT);
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

-(BKImageOriginalButton*)originalBtn
{
    if (!_originalBtn) {
        _originalBtn = [[BKImageOriginalButton alloc] initWithFrame:CGRectMake(BK_SCREENW/6, 0, BK_SCREENW/7*3, BK_SYSTEM_TABBAR_UI_HEIGHT)];
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
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:BKHighlightColor];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _sendBtn.layer.cornerRadius = 4;
        _sendBtn.clipsToBounds = YES;
        [_sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _sendBtn;
}

-(void)editBtnClick:(UIButton*)button
{
    if ([[BKTool sharedManager].selectImageArray count] > 0) {
        
        __block NSMutableArray * selectImageArr = [NSMutableArray array];
        __block NSInteger prepareIndex = 0;
        
        [[BKTool sharedManager].selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BKImageModel * model = obj;
            if (model.photoType != BKSelectPhotoTypeImage) {
                return;
            }
            
            [selectImageArr addObject:@""];
            
            [self prepareEditWithImageModel:model complete:^(UIImage *image) {
                if (idx < [selectImageArr count]) {
                    [selectImageArr replaceObjectAtIndex:idx withObject:image];
                }
                prepareIndex++;
                
                if (prepareIndex == [[BKTool sharedManager].selectImageArray count]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self pushEditImageVCWithEditImageArr:[selectImageArr copy]];
                    });
                }
            }];
        }];
        
    }else{
        BKImageModel * model = _imageListArray[_currentImageIndex];
        if (model.photoType != BKSelectPhotoTypeImage) {
            return;
        }
        
        [self prepareEditWithImageModel:model complete:^(UIImage *image) {
            [self pushEditImageVCWithEditImageArr:@[image]];
        }];
    }
}

-(void)prepareEditWithImageModel:(BKImageModel*)imageModel complete:(void (^)(UIImage * image))complete
{
    if (imageModel.isHaveOriginalImageFlag) {
        if (complete) {
            complete([UIImage imageWithData:imageModel.originalImageData]);
        }
    }else{
        [[BKTool sharedManager] getOriginalImageDataSizeWithAsset:imageModel.asset complete:^(NSData *originalImageData, NSURL *url) {
            
            imageModel.originalImageData = originalImageData;
            imageModel.isHaveOriginalImageFlag = YES;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                imageModel.thumbImageData = [[BKTool sharedManager] compressImageData:originalImageData];
            });
            imageModel.url = url;
            imageModel.originalImageSize = (double)originalImageData.length/1024/1024;
            
            if (complete) {
                complete([UIImage imageWithData:imageModel.originalImageData]);
            }
        }];
    }
}

-(void)pushEditImageVCWithEditImageArr:(NSArray<UIImage*>*)imageArr
{
    BKEditImageViewController * vc = [[BKEditImageViewController alloc]init];
    vc.editImageArr = imageArr;
    vc.fromModule = BKEditImageFromModulePhotoAlbum;
    self.nav.delegate = nil;
    [self.nav pushViewController:vc animated:YES];
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
    if ([self.delegate respondsToSelector:@selector(refreshSelectPhoto)]) {
        [self.delegate refreshSelectPhoto];
    }
}

-(void)calculataImageSize
{
    __block double allSize = 0.0;
    if ([BKTool sharedManager].max_select == 1) {
        BKImageModel * model = _imageListArray[_currentImageIndex];
        allSize = model.originalImageSize;
    }else{
        [[BKTool sharedManager].selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            BKImageModel * model = obj;
            allSize = allSize + model.originalImageSize;
        }];
    }
    
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
        if ([BKTool sharedManager].max_select == 1) {
            
            BKImageModel * model = _imageListArray[_currentImageIndex];
            [[BKTool sharedManager].selectImageArray addObject:model];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    currentCell.imageScrollView.zoomScale = 1;
    currentCell.imageScrollView.contentSize = CGSizeMake(currentCell.bk_width-BKExampleImagesSpacing*2, currentCell.bk_height);
    
    BKImageModel * model = self.imageListArray[indexPath.item];
    
    _currentOriginalImageLoadedFlag = NO;
    
    if (model.thumbImage) {
        [self editImageView:currentCell.showImageView image:model.thumbImage imageData:nil scrollView:currentCell.imageScrollView];
        [[BKTool sharedManager] getOriginalImageSizeWithAsset:model.asset complete:^(UIImage *originalImage) {
            [self editImageView:currentCell.showImageView image:originalImage imageData:nil scrollView:currentCell.imageScrollView];
            
            self.currentOriginalImageLoadedFlag = YES;
        }];
    }else{
        [[BKTool sharedManager] getThumbImageSizeWithAsset:model.asset complete:^(UIImage *thumbImage) {
            model.thumbImage = thumbImage;
            [self editImageView:currentCell.showImageView image:thumbImage imageData:nil scrollView:currentCell.imageScrollView];
            
            [[BKTool sharedManager] getOriginalImageSizeWithAsset:model.asset complete:^(UIImage *originalImage) {
                [self editImageView:currentCell.showImageView image:originalImage imageData:nil scrollView:currentCell.imageScrollView];
                
                self.currentOriginalImageLoadedFlag = YES;
            }];
        }];
    }
}

-(void)loadingOriginalImageData
{
    NSIndexPath * currentIndexPath = [NSIndexPath indexPathForItem:_currentImageIndex inSection:0];
    BOOL flag = [_exampleImageCollectionView.indexPathsForVisibleItems containsObject:currentIndexPath];
    
    while (!flag || !_currentOriginalImageLoadedFlag) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadingOriginalImageData];
        });
        return;
    }
    
    BKShowExampleImageCollectionViewCell * currentCell = (BKShowExampleImageCollectionViewCell*)[_exampleImageCollectionView cellForItemAtIndexPath:currentIndexPath];
    
    self.interactiveTransition.startImageView = currentCell.showImageView;
    self.interactiveTransition.supperScrollView = currentCell.imageScrollView;
    
    BKImageModel * model = self.imageListArray[currentIndexPath.item];
    
    if (model.isHaveOriginalImageFlag) {
        
        if (model.photoType == BKSelectPhotoTypeGIF) {
            if (![model.originalImageData isEqualToData:currentCell.showImageView.animatedImage.data]) {
                [self editImageView:currentCell.showImageView image:nil imageData:model.originalImageData scrollView:currentCell.imageScrollView];
            }
        }
        
        if ([BKTool sharedManager].isOriginal && [BKTool sharedManager].max_select == 1) {
            [self calculataImageSize];
        }
    }else{
        [[BKTool sharedManager] getOriginalImageDataSizeWithAsset:model.asset complete:^(NSData * originalImageData,NSURL * url) {
            
            model.originalImageData = originalImageData;
            model.isHaveOriginalImageFlag = YES;
            
            if (model.photoType == BKSelectPhotoTypeGIF) {
                [self editImageView:currentCell.showImageView image:nil imageData:model.originalImageData scrollView:currentCell.imageScrollView];
            }
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                model.thumbImageData = [[BKTool sharedManager] compressImageData:originalImageData];
            });
            model.url = url;
            model.originalImageSize = (double)originalImageData.length/1024/1024;
            if ([BKTool sharedManager].isOriginal && [BKTool sharedManager].max_select == 1) {
                [self calculataImageSize];
            }
        }];
    }
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
    
    if (image) {
        showImageView.image = image;
    }
    
    if (imageData) {
        FLAnimatedImage * gifImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
        if (gifImage) {
            showImageView.animatedImage = gifImage;
        }
    }
    
    showImageView.frame = [self calculateTargetFrameWithImageView:showImageView];
    imageScrollView.contentSize = CGSizeMake(showImageView.bk_width, showImageView.bk_height);
    
    CGFloat scale = image.size.width / self.view.bk_width;
    imageScrollView.maximumZoomScale = scale<2?2:scale;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _exampleImageCollectionView) {
        if (_isLoadOver) {
            
            CGPoint point = [self.view convertPoint:self.exampleImageCollectionView.center toView:self.exampleImageCollectionView];
            NSIndexPath * currentIndexPath = [self.exampleImageCollectionView indexPathForItemAtPoint:point];
            
            self.currentImageIndex = currentIndexPath.item;
            
            BOOL flag = [_exampleImageCollectionView.indexPathsForVisibleItems containsObject:currentIndexPath];
            if (flag) {
                BKShowExampleImageCollectionViewCell * currentCell = (BKShowExampleImageCollectionViewCell*)[_exampleImageCollectionView cellForItemAtIndexPath:currentIndexPath];
                
                self.interactiveTransition.startImageView = currentCell.showImageView;
                self.interactiveTransition.supperScrollView = currentCell.imageScrollView;
            }
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _exampleImageCollectionView) {
        [self loadingOriginalImageData];
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentImageIndex"]) {
        
        if ([change[@"old"] integerValue] == [change[@"new"] integerValue]) {
            return;
        }
        
        self.titleLab.text = [NSString stringWithFormat:@"%ld/%ld",_currentImageIndex+1,[self.imageListArray count]];
        
        BKImageModel * model = self.imageListArray[_currentImageIndex];
        if (self.delegate) {
            [self.delegate refreshLookLocationActionWithImageModel:model];
        }
        
        self.rightNavBtn.title = @"";
        [[BKTool sharedManager].selectImageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BKImageModel * selectModel = obj;
            if ([model.fileName isEqualToString:selectModel.fileName]) {
                self.rightNavBtn.title = [NSString stringWithFormat:@"%ld",idx+1];
                *stop = YES;
            }
        }];
        
    }else if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGFloat contentOffX = (self.view.bk_width+BKExampleImagesSpacing*2) * _currentImageIndex;
        if (_exampleImageCollectionView.contentSize.width - _exampleImageCollectionView.bk_width >= contentOffX) {
            [_exampleImageCollectionView setContentOffset:CGPointMake(contentOffX, 0) animated:NO];
        }
        
        [_exampleImageCollectionView removeObserver:self forKeyPath:@"contentSize"];
        _isLoadOver = YES;
        
        [self loadingOriginalImageData];
    }
}

@end

