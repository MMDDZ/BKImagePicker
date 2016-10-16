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

@interface BKShowExampleImageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView * exampleImageCollectionView;

@property (nonatomic,assign) NSInteger nowItem;

@end

@implementation BKShowExampleImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initNav];
    [self.view addSubview:[self exampleImageCollectionView]];
}

-(void)initNav
{
    if ([self.imageArray count] == 1) {
        self.title = @"预览";
    }else{
        self.title = [NSString stringWithFormat:@"%ld/%ld",[self.imageArray indexOfObject:self.tap_asset]+1,[self.imageArray count]];
    }
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 64, 64);
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(button.frame.size.width-12.5, (button.frame.size.height-25)/2.0f, 25, 25)];
    titleLab.font = [UIFont systemFontOfSize:13];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.backgroundColor = [UIColor colorWithRed:45/255.0f green:150/255.0f blue:250/255.0f alpha:1];
    titleLab.text = @"11";
    titleLab.clipsToBounds = YES;
    titleLab.layer.cornerRadius = titleLab.frame.size.width/2.0f;
    titleLab.layer.borderColor = [UIColor whiteColor].CGColor;
    titleLab.layer.borderWidth = 0.5;
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.tag = 1;
    [button addSubview:titleLab];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    rightItem.imageInsets = UIEdgeInsetsMake(0, 20, 0, 0);
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)rightBtnClick:(UIButton*)button
{
    UILabel * titleLab = (UILabel*)[button viewWithTag:1];
    
}

#pragma mark - UICollectionView

-(UICollectionView*)exampleImageCollectionView
{
    if (!_exampleImageCollectionView) {
        BKShowExampleImageCollectionViewFlowLayout * flowLayout = [[BKShowExampleImageCollectionViewFlowLayout alloc]init];
        flowLayout.allImageCount = [self.imageArray count];
        
        _exampleImageCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-20, 64, self.view.frame.size.width+20*2, self.view.frame.size.height-64) collectionViewLayout:flowLayout];
        _exampleImageCollectionView.delegate = self;
        _exampleImageCollectionView.dataSource = self;
        _exampleImageCollectionView.backgroundColor = [UIColor clearColor];
        _exampleImageCollectionView.showsVerticalScrollIndicator = NO;
        _exampleImageCollectionView.pagingEnabled = YES;
        
        [_exampleImageCollectionView registerClass:[BKShowExampleImageCollectionViewCell class] forCellWithReuseIdentifier:showExampleImageCell_identifier];
        
        CGFloat contentOffX = (self.view.frame.size.width+20*2) * ([[self.title componentsSeparatedByString:@"/"][0] integerValue] - 1);
        [_exampleImageCollectionView setContentOffset:CGPointMake(contentOffX, 0) animated:NO];
    }
    return _exampleImageCollectionView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.imageArray count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BKShowExampleImageCollectionViewCell * cell = (BKShowExampleImageCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:showExampleImageCell_identifier forIndexPath:indexPath];
    
    cell.imageScrollView.contentSize = CGSizeMake(cell.frame.size.width-20*2, cell.frame.size.height);
    cell.imageScrollView.hidden = YES;
    cell.showImageView.transform = CGAffineTransformMakeScale(1, 1);
    cell.showImageView.userInteractionEnabled = YES;
    
    [self getMaximumSizeImageOption:^(UIImage *originalImage) {
        [self editImageView:cell.showImageView image:originalImage scrollView:cell.imageScrollView];
        cell.imageScrollView.hidden = NO;
    } nowIndex:indexPath.row];

    return cell;
}

/**
 获取对应缩略图大图

 @param imageOption 大图
 */
-(void)getMaximumSizeImageOption:(void (^)(UIImage * originalImage))imageOption nowIndex:(NSInteger)nowIndex
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        
        PHCachingImageManager * imageManager = [[PHCachingImageManager alloc]init];
        [imageManager requestImageForAsset:self.imageArray[nowIndex] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
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
    showImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGRect showImageViewFrame = showImageView.frame;
    
    if (showImageViewFrame.size.width > imageScrollView.frame.size.width) {
        
        showImageViewFrame.size.width = imageScrollView.frame.size.width;
        CGFloat scale = image.size.width/showImageViewFrame.size.width;
        showImageViewFrame.size.height = image.size.height/scale;
        showImageViewFrame.origin.x = 0;
        showImageViewFrame.origin.y = (imageScrollView.frame.size.height-showImageViewFrame.size.height)/2.0f;
        
        imageScrollView.maximumZoomScale = scale;
    }else{
        
        showImageViewFrame.origin.x = (imageScrollView.frame.size.width - image.size.width)/2.0f;
        showImageViewFrame.origin.y = (imageScrollView.frame.size.height - image.size.height)/2.0f;
        
        imageScrollView.maximumZoomScale=2.0;
    }
    
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
            self.title = [NSString stringWithFormat:@"%ld/%ld",item+1,[self.imageArray count]];
        }
    }
}


@end
