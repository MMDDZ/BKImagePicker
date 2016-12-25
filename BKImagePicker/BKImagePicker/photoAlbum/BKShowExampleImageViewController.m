//
//  BKShowExampleImageViewController.m
//  BKImagePicker
//
//  Created by 毕珂 on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define showExampleImageCell_identifier @"BKShowExampleImageCollectionViewCell"

#import "BKShowExampleImageViewController.h"
#import "BKShowExampleImageCollectionViewFlowLayout.h"
#import "BKShowExampleImageCollectionViewCell.h"
#import "BKImageClassViewController.h"
#import "BKImageAlbumItemSelectButton.h"
#import "BKTool.h"

@interface BKShowExampleImageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate>

@property (nonatomic,strong) BKImageAlbumItemSelectButton * rightBtn;

@property (nonatomic,strong) UICollectionView * exampleImageCollectionView;

@property (nonatomic,strong) UIView * bottomView;
@property (nonatomic,strong) UIButton * editBtn;
@property (nonatomic,strong) UIButton * sendBtn;

@end

@implementation BKShowExampleImageViewController

-(NSArray*)imageAssetsArray
{
    if (!_imageAssetsArray && [_select_imageArray count] > 0) {
        _imageAssetsArray = [NSArray arrayWithArray:_select_imageArray];
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

-(UIView*)bottomView
{
    if (!_bottomView) {
        
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 49)];
        _bottomView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        
        [_bottomView addSubview:[self editBtn]];
        [_bottomView addSubview:[self sendBtn]];
        
        if ([self.select_imageArray count] == 1) {
            [_editBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
            [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sendBtn setBackgroundColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1]];
            
            [_sendBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
        }else if ([self.select_imageArray count] > 1) {
            [_editBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
            [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_sendBtn setBackgroundColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1]];
            
            [_sendBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",[self.select_imageArray count]] forState:UIControlStateNormal];
        }
    }
    return _bottomView;
}

-(UIButton*)editBtn
{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame = CGRectMake(0, 0, self.view.frame.size.width / 6, 49);
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationController.delegate = self;
    
    [self initNav];
    [self.view addSubview:[self exampleImageCollectionView]];
    [self.view addSubview:[self bottomView]];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.navigationController.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 64);
        self.exampleImageCollectionView.alpha = 1;
        CGRect bottomViewFrame = self.bottomView.frame;
        bottomViewFrame.origin.y = self.view.frame.size.height - 49;
        self.bottomView.frame = bottomViewFrame;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"title"];
}

-(void)initNav
{
    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    self.navigationController.navigationBar.frame = CGRectMake(0, -64, self.view.frame.size.width, 64);
    
    if ([self.imageAssetsArray count] == 1) {
        self.title = @"预览";
    }else{
        self.title = [NSString stringWithFormat:@"%ld/%ld",[self.imageAssetsArray indexOfObject:self.tap_asset]+1,[self.imageAssetsArray count]];
    }
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    UIView * rightItem = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightItem setBackgroundColor:[UIColor clearColor]];
    
    [rightItem addSubview:[self rightBtn]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightItem];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        
        NSInteger item = [[change[@"new"] componentsSeparatedByString:@"/"][0] integerValue]-1;
        
        PHAsset * asset = (PHAsset*)(self.imageAssetsArray[item]);
        
        if ([self.select_imageArray containsObject:asset]) {
            NSInteger select_num = [self.select_imageArray indexOfObject:asset]+1;
            self.rightBtn.title = [NSString stringWithFormat:@"%ld",select_num];
        }else{
            self.rightBtn.title = @"";
        }
        self.rightBtn.tag = item;
    }
}

-(BKImageAlbumItemSelectButton*)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [[BKImageAlbumItemSelectButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        __weak BKShowExampleImageViewController * mySelf = self;
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
            [self.select_imageArray removeObject:asset];
            
            if ([self.select_imageArray count] == 0) {
                [_editBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
                [_sendBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1] forState:UIControlStateNormal];
                [_sendBtn setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1]];
            }else if ([self.select_imageArray count] == 1) {
                [_editBtn setTitleColor:[UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1] forState:UIControlStateNormal];
            }
        }else{
            [self.select_imageArray addObject:asset];
            if ([self.select_imageArray count] == 1) {
                
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
            
            if (self.refreshAlbumViewOption) {
                self.refreshAlbumViewOption(self.select_imageArray);
            }
            
            *stop = YES;
        }
    }];
}

-(void)editBtnClick:(UIButton*)button
{
    
}

-(void)sendBtnClick:(UIButton*)button
{
    if (self.finishSelectOption) {
        self.finishSelectOption(self.select_imageArray.copy, BKSelectPhotoTypeImage);
    }
}

-(void)exampleImageCollectionViewTapRecognizer
{
    [UIApplication sharedApplication].statusBarHidden = ![UIApplication sharedApplication].statusBarHidden;
    if ([UIApplication sharedApplication].statusBarHidden) {
        self.navigationController.navigationBar.alpha = 0;
        self.bottomView.alpha = 0;
    }else{
        self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
        self.navigationController.navigationBar.alpha = 0.8;
        self.bottomView.alpha = 0.8;
    }
}

#pragma mark - UICollectionView

-(UICollectionView*)exampleImageCollectionView
{
    if (!_exampleImageCollectionView) {
        BKShowExampleImageCollectionViewFlowLayout * flowLayout = [[BKShowExampleImageCollectionViewFlowLayout alloc]init];
        flowLayout.allImageCount = [self.imageAssetsArray count];
        
        _exampleImageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-20, 0, self.view.frame.size.width+20*2, self.view.frame.size.height) collectionViewLayout:flowLayout];
        _exampleImageCollectionView.delegate = self;
        _exampleImageCollectionView.dataSource = self;
        _exampleImageCollectionView.backgroundColor = [UIColor clearColor];
        _exampleImageCollectionView.showsVerticalScrollIndicator = NO;
        _exampleImageCollectionView.showsHorizontalScrollIndicator = NO;
        _exampleImageCollectionView.pagingEnabled = YES;
        _exampleImageCollectionView.alpha = 0;
        
        [_exampleImageCollectionView registerClass:[BKShowExampleImageCollectionViewCell class] forCellWithReuseIdentifier:showExampleImageCell_identifier];
        
        CGFloat contentOffX = (self.view.frame.size.width+20*2) * ([[self.title componentsSeparatedByString:@"/"][0] integerValue] - 1);
        [_exampleImageCollectionView setContentOffset:CGPointMake(contentOffX, 0) animated:NO];
        
        UITapGestureRecognizer * exampleImageCollectionViewTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exampleImageCollectionViewTapRecognizer)];
        [_exampleImageCollectionView addGestureRecognizer:exampleImageCollectionViewTapRecognizer];
    }
    return _exampleImageCollectionView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageAssetsArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:showExampleImageCell_identifier forIndexPath:indexPath];
    
    cell.imageScrollView.contentSize = CGSizeMake(cell.frame.size.width-20*2, cell.frame.size.height);
    cell.showImageView.transform = CGAffineTransformMakeScale(1, 1);
    
    [self getThumbSizeImageOption:^(UIImage *thumbImage) {
        [self editImageView:cell.showImageView image:thumbImage scrollView:cell.imageScrollView];
    } nowIndex:indexPath.item];
    
    [self getMaximumSizeImageOption:^(UIImage *originalImage) {
        [self editImageView:cell.showImageView image:originalImage scrollView:cell.imageScrollView];
    } nowIndex:indexPath.item];

    return cell;
}

/**
 获取对应缩略图
 
 @param imageOption 缩略图
 */
-(void)getThumbSizeImageOption:(void (^)(UIImage * thumbImage))imageOption nowIndex:(NSInteger)nowIndex
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        options.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageForAsset:self.imageAssetsArray[nowIndex] targetSize:CGSizeMake(self.view.frame.size.width/2.0f, self.view.frame.size.width/2.0f) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            // 排除取消，错误，低清图三种情况，即已经获取到了高清图
            BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downImageloadFinined) {
                if(result)
                {
                    if (imageOption) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageOption(result);
                        });
                    }
                }
            }
        }];
    });
}

/**
 获取对应缩略图大图

 @param imageOption 大图
 */
-(void)getMaximumSizeImageOption:(void (^)(UIImage * originalImage))imageOption nowIndex:(NSInteger)nowIndex
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageForAsset:self.imageAssetsArray[nowIndex] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            // 排除取消，错误，低清图三种情况，即已经获取到了高清图
            BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            if (downImageloadFinined) {
                if(result)
                {
                    if (imageOption) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageOption(result);
                        });
                    }
                }
            }
        }];
    });
}

/**
 修改图frame

 @param showImageView   image所在的imageVIew
 @param image           image
 @param imageScrollView image所在的scrollView
 */
-(void)editImageView:(UIImageView*)showImageView image:(UIImage*)image scrollView:(UIScrollView*)imageScrollView
{
    showImageView.image = image;
    
    CGRect showImageViewFrame = showImageView.frame;

    CGFloat scale = image.size.width / showImageViewFrame.size.width;
    CGFloat height = image.size.height / scale;
    if (height > imageScrollView.frame.size.height) {
        showImageViewFrame.size.height = imageScrollView.frame.size.height;
        scale = image.size.height / showImageViewFrame.size.height;
        showImageViewFrame.size.width = image.size.width / scale;
        showImageViewFrame.origin.x = (imageScrollView.frame.size.width - showImageViewFrame.size.width) / 2.0f;
        showImageViewFrame.origin.y = 0;
    }else{
        showImageViewFrame.size.height = height;
        showImageViewFrame.size.width = imageScrollView.frame.size.width;
        showImageViewFrame.origin.x = 0;
        showImageViewFrame.origin.y = (imageScrollView.frame.size.height-showImageViewFrame.size.height)/2.0f;
    }
    
    imageScrollView.maximumZoomScale = scale<2?2:scale;
    
    showImageView.frame = showImageViewFrame;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.exampleImageCollectionView) {
        
        CGPoint p = [self.view convertPoint:self.exampleImageCollectionView.center toView:self.exampleImageCollectionView];
        NSIndexPath * indexPath = [self.exampleImageCollectionView indexPathForItemAtPoint:p];
        NSInteger item = indexPath.item;
        
        if ([self.title rangeOfString:@"/"].location != NSNotFound) {
            self.title = [NSString stringWithFormat:@"%ld/%ld",item+1,[self.imageAssetsArray count]];
        }
    }
}

@end
