//
//  BKShowExampleImageView.m
//  BKImagePicker
//
//  Created by 毕珂 on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define showExampleImageCell_identifier @"BKShowExampleImageCollectionViewCell"

#import "BKShowExampleImageView.h"
#import "BKShowExampleImageCollectionViewFlowLayout.h"
#import "BKShowExampleImageCollectionViewCell.h"
#import "BKImageClassViewController.h"
#import "BKImageAlbumItemSelectButton.h"
#import "BKImagePickerConst.h"
#import "BKEditPhotoView.h"

@interface BKShowExampleImageView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate>

/**
 点击的那张图片
 */
@property (nonatomic,strong) UIImageView * tapImageView;

/**
 展示数组
 */
@property (nonatomic,strong) NSArray * imageListArray;
/**
 选取数组
 */
@property (nonatomic,strong) NSMutableArray * selectImageArray;
/**
 选取的model
 */
@property (nonatomic,strong) BKImageModel * tapModel;
/**
 最大选取量
 */
@property (nonatomic,assign) NSInteger maxSelect;
/**
 是否选择原图
 */
@property (nonatomic,assign) BOOL isOriginal;



@property (nonatomic,strong) UICollectionView * exampleImageCollectionView;


@property (nonatomic,strong) UILabel * titleLab;
@property (nonatomic,weak) UIViewController * locationVC;

@property (nonatomic,strong) BKImageAlbumItemSelectButton * rightBtn;


@property (nonatomic,strong) UIButton * editBtn;
@property (nonatomic,strong) UIButton * originalBtn;
@property (nonatomic,strong) UIButton * sendBtn;

//当前看见image的index
@property (nonatomic,assign) NSInteger nowImageIndex;

@end

@implementation BKShowExampleImageView

-(NSMutableArray*)selectImageArray
{
    if (!_selectImageArray) {
        _selectImageArray = [NSMutableArray array];
    }
    return _selectImageArray;
}

#pragma mark - init

-(instancetype)initWithLocationVC:(UIViewController*)locationVC imageListArray:(NSArray*)imageListArray selectImageArray:(NSArray*)selectImageArray tapModel:(BKImageModel*)tapModel maxSelect:(NSInteger)maxSelect isOriginal:(BOOL)isOriginal
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        self.locationVC = locationVC;
        
        self.imageListArray = imageListArray;
        self.selectImageArray = [NSMutableArray arrayWithArray:selectImageArray];
        self.tapModel = tapModel;
        self.maxSelect = maxSelect;
        self.isOriginal = isOriginal;
        
        [self addSubview:[self topView]];
        [self addSubview:[self bottomView]];
    }
    return self;
}

#pragma mark - topView

-(UIView*)topView
{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, 64)];
        _topView.backgroundColor = BKNavBackgroundColor;
        _topView.alpha = 0;
        
        [_topView addSubview:[self titleLab]];
        
        if ([self.imageListArray count] == 1) {
            self.titleLab.text = @"预览";
        }else{
            self.nowImageIndex = [self.imageListArray indexOfObject:self.tapModel];
            self.titleLab.text = [NSString stringWithFormat:@"%ld/%ld",_nowImageIndex+1,[self.imageListArray count]];
        }
        [self addObserver:self forKeyPath:@"nowImageIndex" options:NSKeyValueObservingOptionNew context:nil];
        
        UIButton * leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBtn.frame = CGRectMake(0, 0, 64, 64);
        [leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:leftBtn];
        
        NSString * backPath = [[NSBundle mainBundle] pathForResource:@"BKImage" ofType:@"bundle"];
        UIImageView * leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 20 + 12, 20, 20)];
        leftImageView.clipsToBounds = YES;
        leftImageView.contentMode = UIViewContentModeScaleAspectFit;
        leftImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/blue_back.png",backPath]];
        [leftBtn addSubview:leftImageView];
        
        if (self.maxSelect != 1) {
            UIView * rightBtn = [[UIView alloc]initWithFrame:CGRectMake(self.bk_width-64, 0, 64, 64)];
            [_topView addSubview:rightBtn];
            
            [rightBtn addSubview:[self rightBtn]];
        }
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64-BKLineHeight, self.bk_width, BKLineHeight)];
        line.backgroundColor = BKLineColor;
        [_topView addSubview:line];
    }
    return _topView;
}

-(UILabel*)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]initWithFrame:CGRectMake(64, 20, self.bk_width - 64*2, 44)];
        _titleLab.font = [UIFont boldSystemFontOfSize:17];
        _titleLab.textColor = [UIColor blackColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

-(BKImageAlbumItemSelectButton*)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [[BKImageAlbumItemSelectButton alloc]initWithFrame:CGRectMake(25, 27, 30, 30)];
        __weak typeof(self) weakSelf = self;
        [_rightBtn setSelectButtonClick:^(BKImageAlbumItemSelectButton * button) {
            [weakSelf rightBtnClick:button];
        }];
        
        if ([self.imageListArray count] == 1) {
            if ([self.selectImageArray count] == 1) {
                _rightBtn.title = @"1";
            }else{
                _rightBtn.title = @"0";
            }
        }
    }
    return _rightBtn;
}

-(void)rightBtnClick:(BKImageAlbumItemSelectButton*)button
{
    BKImageModel * model = self.imageListArray[button.tag];
    BOOL isHave = [self.selectImageArray containsObject:model];
    if (!isHave && [self.selectImageArray count] >= self.maxSelect) {
        [BKTool showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",self.maxSelect]];
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

-(void)leftBtnClick
{
    BKImageModel * model = self.imageListArray[_nowImageIndex];
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:_nowImageIndex inSection:0];
    BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[self.exampleImageCollectionView cellForItemAtIndexPath:indexPath];
    cell.showImageView.alpha = 0;
    if (self.backOption) {
        self.backOption(model,cell.showImageView);
    }
}

#pragma mark - bottomView

-(UIView*)bottomView
{
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bk_height-49, self.bk_width, 49)];
        _bottomView.backgroundColor = BKNavBackgroundColor;
        _bottomView.alpha = 0;
        
        [_bottomView addSubview:[self editBtn]];
        if (BKComfirmHaveOriginalOption) {
            [_bottomView addSubview:[self originalBtn]];
        }
        [_bottomView addSubview:[self sendBtn]];
        
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
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bk_width, BKLineHeight)];
        line.backgroundColor = BKLineColor;
        [_bottomView addSubview:line];
    }
    return _bottomView;
}

-(UIButton*)editBtn
{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame = CGRectMake(0, 0, self.bk_width / 6, 49);
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
        _originalBtn.frame = CGRectMake(UISCREEN_WIDTH/6, 0, UISCREEN_WIDTH/7*3, 49);
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
        _sendBtn.frame = CGRectMake(self.bk_width/4*3, 6, self.bk_width/4-6, 37);
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
    BKImageModel * model = _imageListArray[_nowImageIndex];
    if (model.originalImageData) {
        UIImage * originalImage = [UIImage imageWithData:model.originalImageData];
        BKEditPhotoView * editView = [[BKEditPhotoView alloc]initWithImage:originalImage];
        [self addSubview:editView];
    }else{
        [self getOriginalImageSizeWithAsset:model.asset complete:^(UIImage *originalImage) {
            BKEditPhotoView * editView = [[BKEditPhotoView alloc]initWithImage:originalImage];
            [self addSubview:editView];
        }];
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
            [self.locationVC dismissViewControllerAnimated:YES completion:nil];
        }
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BKFinishSelectImageNotification object:nil userInfo:@{@"object":self.selectImageArray,@"isOriginal":@(_isOriginal)}];
    [self.locationVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 显示方法

-(void)showImageAnimate:(UIImageView*)tapImageView beginAnimateOption:(void (^)())beginOption endAnimateOption:(void (^)())endOption
{
    [[self.locationVC.view superview] addSubview:self];
    
    [self insertSubview:self.exampleImageCollectionView atIndex:0];
    
    if (tapImageView) {
        self.tapImageView = tapImageView;
        [self showAnimateOption:beginOption endAnimateOption:endOption];
    }else{
        
        self.bk_x = UISCREEN_WIDTH;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        self.topView.alpha = 1;
        self.bottomView.alpha = 1;
        
        CGSize tapImageSize = self.tapModel.thumbImage.size;
        
        CGRect tapImageViewFrame;
        CGFloat scale = tapImageSize.width / self.bk_width;
        CGFloat height = tapImageSize.height / scale;
        if (height > self.bk_height) {
            tapImageViewFrame.size.height = self.bk_height;
            scale = tapImageSize.height / tapImageViewFrame.size.height;
            tapImageViewFrame.size.width = tapImageSize.width / scale;
            tapImageViewFrame.origin.x = (self.bk_width - tapImageViewFrame.size.width) / 2.0f;
            tapImageViewFrame.origin.y = 0;
        }else{
            tapImageViewFrame.size.height = height;
            tapImageViewFrame.size.width = self.bk_width;
            tapImageViewFrame.origin.x = 0;
            tapImageViewFrame.origin.y = (self.bk_height-tapImageViewFrame.size.height)/2.0f;
        }
        
        UIImageView * newTapImageView = [[UIImageView alloc]initWithFrame:tapImageViewFrame];
        newTapImageView.image = self.tapModel.thumbImage;
        newTapImageView.clipsToBounds = YES;
        newTapImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:newTapImageView];
        [self bringSubviewToFront:self.topView];
        [self bringSubviewToFront:self.bottomView];
        
        [UIView animateWithDuration:BKCheckExampleGifAndVideoAnimateTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.locationVC.view.bk_x = -UISCREEN_WIDTH/2.0f;
            self.bk_x = 0;
            
        } completion:^(BOOL finished) {
            
            self.locationVC.view.bk_x = 0;
            self.exampleImageCollectionView.alpha = 1;
            [newTapImageView removeFromSuperview];
            [self removeFromSuperview];
            [self.locationVC.view addSubview:self];
        }];
    }
}

-(void)showAnimateOption:(void (^)())beginOption endAnimateOption:(void (^)())endOption
{
    CGRect tapImageViewFrame = [[self.tapImageView superview] convertRect:self.tapImageView.frame toView:self];
    
    UIImageView * tapImageView = [[UIImageView alloc]initWithFrame:tapImageViewFrame];
    tapImageView.image = self.tapImageView.image;
    tapImageView.clipsToBounds = YES;
    tapImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:tapImageView];
    [self bringSubviewToFront:self.topView];
    [self bringSubviewToFront:self.bottomView];
    
    CGSize tapImageSize = tapImageView.image.size;
    
    CGFloat scale = tapImageSize.width / self.bk_width;
    CGFloat height = tapImageSize.height / scale;
    if (height > self.bk_height) {
        tapImageViewFrame.size.height = self.bk_height;
        scale = tapImageSize.height / tapImageViewFrame.size.height;
        tapImageViewFrame.size.width = tapImageSize.width / scale;
        tapImageViewFrame.origin.x = (self.bk_width - tapImageViewFrame.size.width) / 2.0f;
        tapImageViewFrame.origin.y = 0;
    }else{
        tapImageViewFrame.size.height = height;
        tapImageViewFrame.size.width = self.bk_width;
        tapImageViewFrame.origin.x = 0;
        tapImageViewFrame.origin.y = (self.bk_height-tapImageViewFrame.size.height)/2.0f;
    }
    
    if (beginOption) {
        beginOption();
    }
    
    [UIView animateWithDuration:BKCheckExampleImageAnimateTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        tapImageView.frame = tapImageViewFrame;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        self.topView.alpha = 1;
        self.bottomView.alpha = 1;
    } completion:^(BOOL finished) {
        [tapImageView removeFromSuperview];
        self.exampleImageCollectionView.alpha = 1;
        
        if (endOption) {
            endOption();
        }
    }];
}

#pragma mark - UICollectionView

-(UICollectionView*)exampleImageCollectionView
{
    if (!_exampleImageCollectionView) {
        BKShowExampleImageCollectionViewFlowLayout * flowLayout = [[BKShowExampleImageCollectionViewFlowLayout alloc]init];
        flowLayout.allImageCount = [self.imageListArray count];
        
        _exampleImageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-BKExampleImagesSpacing, 0, self.bk_width+BKExampleImagesSpacing*2, self.bk_height) collectionViewLayout:flowLayout];
        _exampleImageCollectionView.delegate = self;
        _exampleImageCollectionView.dataSource = self;
        _exampleImageCollectionView.backgroundColor = [UIColor clearColor];
        _exampleImageCollectionView.showsVerticalScrollIndicator = NO;
        _exampleImageCollectionView.showsHorizontalScrollIndicator = NO;
        _exampleImageCollectionView.pagingEnabled = YES;
        _exampleImageCollectionView.alpha = 0;
        
        [_exampleImageCollectionView registerClass:[BKShowExampleImageCollectionViewCell class] forCellWithReuseIdentifier:showExampleImageCell_identifier];
        
        CGFloat contentOffX = (self.bk_width+BKExampleImagesSpacing*2) * _nowImageIndex;
        [_exampleImageCollectionView setContentOffset:CGPointMake(contentOffX, 0) animated:NO];
        
        UITapGestureRecognizer * exampleImageCollectionViewTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exampleImageCollectionViewTapRecognizer)];
        [_exampleImageCollectionView addGestureRecognizer:exampleImageCollectionViewTapRecognizer];
    }
    return _exampleImageCollectionView;
}

-(void)exampleImageCollectionViewTapRecognizer
{
    [UIApplication sharedApplication].statusBarHidden = ![UIApplication sharedApplication].statusBarHidden;
    if ([UIApplication sharedApplication].statusBarHidden) {
        self.topView.alpha = 0;
        self.bottomView.alpha = 0;
        
    }else{
        self.topView.alpha = 0.8;
        self.bottomView.alpha = 0.8;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageListArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:showExampleImageCell_identifier forIndexPath:indexPath];
    
    cell.imageScrollView.contentSize = CGSizeMake(cell.bk_width-BKExampleImagesSpacing*2, cell.bk_height);
    cell.showImageView.transform = CGAffineTransformMakeScale(1, 1);
    
    BKImageModel * model = self.imageListArray[indexPath.item];
    
    if (model.photoType == BKSelectPhotoTypeImage) {
        [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
        
        if (model.thumbImage){
            [self editImageView:cell.showImageView image:model.thumbImage imageData:nil scrollView:cell.imageScrollView];
            [self getOriginalImageSizeWithAsset:model.asset complete:^(UIImage *originalImage) {
                [self editImageView:cell.showImageView image:originalImage imageData:nil scrollView:cell.imageScrollView];
            }];
        }else{
            [self getThumbImageSizeWithAsset:model.asset complete:^(UIImage *thumbImage) {
                [self editImageView:cell.showImageView image:thumbImage imageData:nil scrollView:cell.imageScrollView];
                model.thumbImage = thumbImage;
                
                [self getOriginalImageSizeWithAsset:model.asset complete:^(UIImage *originalImage) {
                    [self editImageView:cell.showImageView image:originalImage imageData:nil scrollView:cell.imageScrollView];
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
            [self editImageView:cell.showImageView image:model.thumbImage imageData:nil scrollView:cell.imageScrollView];
            
            [self initCell:cell gifImageModel:model];
            
        }else{
            [self getThumbImageSizeWithAsset:model.asset complete:^(UIImage *thumbImage) {
                [self editImageView:cell.showImageView image:thumbImage imageData:nil scrollView:cell.imageScrollView];
                model.thumbImage = thumbImage;
                
                [self initCell:cell gifImageModel:model];
            }];
        }
    }
    
    return cell;
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
            
            model.url = model.url;
            model.originalImageSize = (double)originalImageData.length/1024/1024;
            if (self.isOriginal && self.maxSelect == 1) {
                [self calculataImageSize];
            }
        }];
    }
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
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(self.bk_width/2.0f, self.bk_width/2.0f) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
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
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
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
    
    CGRect showImageViewFrame = showImageView.frame;
    
    CGFloat scale = image.size.width / imageScrollView.bk_width;
    CGFloat height = image.size.height / scale;
    if (height > imageScrollView.bk_height) {
        showImageViewFrame.size.height = imageScrollView.bk_height;
        scale = image.size.height / showImageViewFrame.size.height;
        showImageViewFrame.size.width = image.size.width / scale;
        showImageViewFrame.origin.x = (imageScrollView.bk_width - showImageViewFrame.size.width) / 2.0f;
        showImageViewFrame.origin.y = 0;
    }else{
        showImageViewFrame.size.height = height;
        showImageViewFrame.size.width = imageScrollView.bk_width;
        showImageViewFrame.origin.x = 0;
        showImageViewFrame.origin.y = (imageScrollView.bk_height-showImageViewFrame.size.height)/2.0f;
    }
    
    imageScrollView.maximumZoomScale = scale<2?2:scale;
    
    showImageView.frame = showImageViewFrame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.exampleImageCollectionView) {
        
        CGPoint p = [self convertPoint:self.exampleImageCollectionView.center toView:self.exampleImageCollectionView];
        NSIndexPath * indexPath = [self.exampleImageCollectionView indexPathForItemAtPoint:p];
        NSInteger item = indexPath.item;
        
        self.nowImageIndex = item;
    }
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"nowImageIndex"]) {
        
        self.titleLab.text = [NSString stringWithFormat:@"%ld/%ld",_nowImageIndex+1,[self.imageListArray count]];
        
        BKImageModel * model = self.imageListArray[_nowImageIndex];
        if (self.refreshLookLocationOption) {
            self.refreshLookLocationOption(model);
        }
        
        if ([self.selectImageArray containsObject:model]) {
            NSInteger select_num = [self.selectImageArray indexOfObject:model]+1;
            self.rightBtn.title = [NSString stringWithFormat:@"%ld",select_num];
        }else{
            self.rightBtn.title = @"";
        }
        self.rightBtn.tag = _nowImageIndex;
    }
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"nowImageIndex"];
}

@end
