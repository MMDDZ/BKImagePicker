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


@interface BKShowExampleImageView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate>

/**
 展示数组
 */
@property (nonatomic,strong) NSArray * imageAssetsArray;
/**
 选取的PHAsset数组
 */
@property (nonatomic,strong) NSMutableArray * select_imageArray;
/**
 选取的照片
 */
@property (nonatomic,strong) PHAsset * tap_asset;
/**
 最大选取量
 */
@property (nonatomic,assign) NSInteger max_select;
/**
 图片大小数组
 */
@property (nonatomic,strong) NSMutableArray * imageSizeArray;

/**
 选取的原图data数组 包含@{@"original":@"",@"thumb":@""}
 */
@property (nonatomic,strong) NSMutableArray * selectResultImageDataArray;

/**
 是否选择原图
 */
@property (nonatomic,assign) BOOL isOriginal;


@property (nonatomic,strong) UICollectionView * exampleImageCollectionView;


@property (nonatomic,strong) UILabel * titleLab;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,weak) UIViewController * locationVC;

@property (nonatomic,strong) BKImageAlbumItemSelectButton * rightBtn;


@property (nonatomic,strong) UIButton * editBtn;
@property (nonatomic,strong) UIButton * originalBtn;
@property (nonatomic,strong) UIButton * sendBtn;

@end

@implementation BKShowExampleImageView

-(NSArray*)imageAssetsArray
{
    if (!_imageAssetsArray) {
        _imageAssetsArray = [NSArray array];
    }
    return _imageAssetsArray;
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

#pragma mark - init

-(instancetype)initWithLocationVC:(UIViewController *)locationVC imageAssetsArray:(NSArray *)imageAssetsArray selectImageArray:(NSArray *)selectImageArray tapAsset:(PHAsset *)tapAsset maxSelect:(NSInteger)maxSelect imageSizeArray:(NSArray *)imageSizeArray selectResultImageDataArray:(NSArray *)selectResultImageDataArray isOriginal:(BOOL)isOriginal
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        self.locationVC = locationVC;
        
        self.imageAssetsArray = imageAssetsArray;
        self.select_imageArray = [NSMutableArray arrayWithArray:selectImageArray];
        self.tap_asset = tapAsset;
        self.max_select = maxSelect;
        self.imageSizeArray = [NSMutableArray arrayWithArray:imageSizeArray];
        self.selectResultImageDataArray = [NSMutableArray arrayWithArray:selectResultImageDataArray];
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
        
        if ([self.imageAssetsArray count] == 1) {
            self.title = @"预览";
        }else{
            self.title = [NSString stringWithFormat:@"%ld/%ld",[self.imageAssetsArray indexOfObject:self.tap_asset]+1,[self.imageAssetsArray count]];
        }
        self.titleLab.text = self.title;
        [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        
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
        
        if (self.max_select != 1) {
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        
        self.titleLab.text = change[@"new"];
        
        NSInteger item = [[change[@"new"] componentsSeparatedByString:@"/"][0] integerValue]-1;
        
        PHAsset * asset = (PHAsset*)(self.imageAssetsArray[item]);
        if (self.refreshLookAsset) {
            self.refreshLookAsset(asset);
        }
        
        if ([self.select_imageArray containsObject:asset]) {
            NSInteger select_num = [self.select_imageArray indexOfObject:asset]+1;
            self.rightBtn.title = [NSString stringWithFormat:@"%ld",select_num];
        }else{
            self.rightBtn.title = @"";
        }
        self.rightBtn.tag = item;
    }
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"title"];
}

-(BKImageAlbumItemSelectButton*)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [[BKImageAlbumItemSelectButton alloc]initWithFrame:CGRectMake(25, 27, 30, 30)];
        __weak BKShowExampleImageView * mySelf = self;
        [_rightBtn setSelectButtonClick:^(BKImageAlbumItemSelectButton * button) {
            [mySelf rightBtnClick:button];
        }];
        
        if ([self.imageAssetsArray count] == 1) {
            if ([self.select_imageArray count] == 1) {
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
    PHAsset * asset = (PHAsset*)self.imageAssetsArray[button.tag];
    BOOL isHave = [self.select_imageArray containsObject:asset];
    if (!isHave && [self.select_imageArray count] >= self.max_select) {
        [BKTool showRemind:[NSString stringWithFormat:@"最多只能选择%ld张照片",self.max_select]];
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
            
            if (self.refreshAlbumViewOption) {
                self.refreshAlbumViewOption([self.select_imageArray copy],[self.imageSizeArray copy],[self.selectResultImageDataArray copy],self.isOriginal);
            }
            
            if ([self.select_imageArray count] == 0) {
                [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_sendBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:BKNavSendGrayBackgroundColor];
            }else if ([self.select_imageArray count] == 1) {
                NSString * fileName = [self.select_imageArray[0] valueForKey:@"filename"];
                if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
                    [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
                }else{
                    [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                }
            }
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
                
                if (self.refreshAlbumViewOption) {
                    self.refreshAlbumViewOption([self.select_imageArray copy],[self.imageSizeArray copy],[self.selectResultImageDataArray copy],self.isOriginal);
                }
            }];
            
            if ([self.select_imageArray count] == 1) {
                
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
        }
        
        if ([self.select_imageArray count] == 0) {
            [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
        }else{
            [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
        }
        
        
    }];
}

-(void)leftBtnClick
{
    if ([self.title rangeOfString:@"/"].location != NSNotFound) {
        NSInteger item = [[self.title componentsSeparatedByString:@"/"][0] integerValue]-1;
        PHAsset * asset = (PHAsset*)(self.imageAssetsArray[item]);
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[self.exampleImageCollectionView  cellForItemAtIndexPath:indexPath];
        cell.showImageView.alpha = 0;
        if (self.backOption) {
            self.backOption(asset,cell.showImageView);
        }
    }else{
        PHAsset * asset = (PHAsset*)(self.imageAssetsArray[0]);
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[self.exampleImageCollectionView  cellForItemAtIndexPath:indexPath];
        cell.showImageView.alpha = 0;
        if (self.backOption) {
            self.backOption(asset,cell.showImageView);
        }
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
        [_bottomView addSubview:[self originalBtn]];
        [_bottomView addSubview:[self sendBtn]];
        
        if (self.max_select == 1) {
            [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
            [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
            
            [_sendBtn setTitle:@"确认" forState:UIControlStateNormal];
        }else{
            if ([self.select_imageArray count] == 1) {
                [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
                [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
                
                [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
            }else if ([self.select_imageArray count] > 1) {
                [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
                [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:BKNavHighlightTitleColor];
                
                [_sendBtn setTitle:[NSString stringWithFormat:@"确认(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
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
        self.refreshAlbumViewOption([self.select_imageArray copy],[self.imageSizeArray copy],[self.selectResultImageDataArray copy],self.isOriginal);
    }
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
    
    if (self.finishSelectOption) {
        for (NSDictionary * dic in self.selectResultImageDataArray) {
            if (self.finishSelectOption) {
                if (self.isOriginal) {
                    self.finishSelectOption([UIImage imageWithData:dic[@"original"]], [dic[@"type"] integerValue]);
                }else{
                    self.finishSelectOption([UIImage imageWithData:dic[@"thumb"]], [dic[@"type"] integerValue]);
                }
            }
        }
        [self.locationVC dismissViewControllerAnimated:YES completion:nil];
    }
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

#pragma mark - 显示方法

-(void)showAndBeginAnimateOption:(void (^)())beginOption endAnimateOption:(void (^)())endOption
{
    [self.locationVC.view addSubview:self];
    [self addSubview:[self exampleImageCollectionView]];
    [self sendSubviewToBack:self.exampleImageCollectionView];
    
    [self showAnimateOption:beginOption endAnimateOption:endOption];
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
        flowLayout.allImageCount = [self.imageAssetsArray count];
        
        _exampleImageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-20, 0, self.bk_width+20*2, self.bk_height) collectionViewLayout:flowLayout];
        _exampleImageCollectionView.delegate = self;
        _exampleImageCollectionView.dataSource = self;
        _exampleImageCollectionView.backgroundColor = [UIColor clearColor];
        _exampleImageCollectionView.showsVerticalScrollIndicator = NO;
        _exampleImageCollectionView.showsHorizontalScrollIndicator = NO;
        _exampleImageCollectionView.pagingEnabled = YES;
        _exampleImageCollectionView.alpha = 0;
        
        [_exampleImageCollectionView registerClass:[BKShowExampleImageCollectionViewCell class] forCellWithReuseIdentifier:showExampleImageCell_identifier];
        
        CGFloat contentOffX = (self.bk_width+20*2) * ([[self.title componentsSeparatedByString:@"/"][0] integerValue] - 1);
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
    return [self.imageAssetsArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:showExampleImageCell_identifier forIndexPath:indexPath];
    
    cell.imageScrollView.contentSize = CGSizeMake(cell.bk_width-20*2, cell.bk_height);
    cell.showImageView.transform = CGAffineTransformMakeScale(1, 1);
    
    [self getThumbSizeImageOption:^(UIImage *thumbImage) {
        [self editImageView:cell.showImageView image:thumbImage imageUrl:nil scrollView:cell.imageScrollView];
    } nowIndex:indexPath.item];
    
    [self getMaximumSizeImageOption:^(UIImage *originalImage,NSString * imageUrl) {
        [self editImageView:cell.showImageView image:originalImage imageUrl:imageUrl scrollView:cell.imageScrollView];
    } nowIndex:indexPath.item];
    
    return cell;
}

/**
 获取对应缩略图
 
 @param imageOption 缩略图
 */
-(void)getThumbSizeImageOption:(void (^)(UIImage * thumbImage))imageOption nowIndex:(NSInteger)nowIndex
{
    NSString * fileName = [self.imageAssetsArray[nowIndex] valueForKey:@"filename"];
    if ([fileName rangeOfString:@"gif"].location == NSNotFound && [fileName rangeOfString:@"GIF"].location == NSNotFound) {
        [_editBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
    }else{
        [_editBtn setTitleColor:BKNavGrayTitleColor forState:UIControlStateNormal];
    }
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageForAsset:self.imageAssetsArray[nowIndex] targetSize:CGSizeMake(self.bk_width/2.0f, self.bk_width/2.0f) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
        BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downImageloadFinined) {
            if(result)
            {
                if (imageOption) {
                    imageOption(result);
                }
            }
        }
    }];
}

/**
 获取对应缩略图大图
 
 @param imageOption 大图
 */
-(void)getMaximumSizeImageOption:(void (^)(UIImage * originalImage , NSString * imageUrl))imageOption nowIndex:(NSInteger)nowIndex
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageForAsset:self.imageAssetsArray[nowIndex] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        // 排除取消，错误，低清图三种情况，即已经获取到了高清图
        BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        if (downImageloadFinined) {
            if(result)
            {
                if (imageOption) {
                    imageOption(result,info[@"PHImageFileURLKey"]);
                }
            }
        }
    }];
}

/**
 修改图frame
 
 @param showImageView   image所在的imageVIew
 @param image           image
 @param imageUrl        imageUrl
 @param imageScrollView image所在的scrollView
 */
-(void)editImageView:(FLAnimatedImageView*)showImageView image:(UIImage*)image imageUrl:(NSString*)imageUrl scrollView:(UIScrollView*)imageScrollView
{
    FLAnimatedImage * gifImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:imageUrl]];
    if (gifImage) {
        showImageView.animatedImage = gifImage;
    }else{
        showImageView.image = image;
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
        
        if ([self.title rangeOfString:@"/"].location != NSNotFound) {
            self.title = [NSString stringWithFormat:@"%ld/%ld",item+1,[self.imageAssetsArray count]];
        }
    }
}

@end
