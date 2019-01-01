//
//  BKCameraFilterView.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/8.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKCameraFilterView.h"
#import "BKImagePickerMacro.h"
#import "UIView+BKImagePicker.h"
#import "UIImage+BKImagePicker.h"
#import "GPUImage.h"

NSString * const kCellID = @"contentCell";

@interface BKCameraFilterView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UISlider * sliderView;
@property (nonatomic,strong) UIView * shadowView;
@property (nonatomic,strong) NSArray<NSString*> * menuArr;
@property (nonatomic,strong) UIScrollView * menuScrollView;
@property (nonatomic,strong) UICollectionView * contentView;

@property (nonatomic,strong) GPUImagePicture * exampleImage;
@property (nonatomic,strong) NSArray<NSString*> * filterTitleArr;
@property (nonatomic,strong) NSMutableArray * filterImageArr;
@property (nonatomic,strong) NSArray<NSNumber*> * filterTypeArr;

@property (nonatomic,weak) UIButton * selectMenuBtn;
@property (nonatomic,assign) NSInteger selectLevel;
@property (nonatomic,assign) NSInteger selectFilter;

@end

@implementation BKCameraFilterView

#pragma mark - get

-(NSArray*)menuArr
{
    if (!_menuArr) {
        _menuArr = @[@"美颜",@"滤镜"];
    }
    return _menuArr;
}

-(GPUImagePicture*)exampleImage
{
    if (!_exampleImage) {
        _exampleImage = [[GPUImagePicture alloc] initWithImage:[UIImage bk_filterImageWithImageName:@"filter_image_example.jpg"]];
    }
    return _exampleImage;
}

-(NSArray<NSString *> *)filterTitleArr
{
    if (!_filterTitleArr) {
        _filterTitleArr = @[@"正常",@"干净",@"自然",@"清新",@"光泽",@"甜美",@"唯美",@"洋气",@"元气",@"萝莉",@"初恋",@"假日",@"傍晚",@"古老",@"鲜明",@"新鲜",@"马卡龙",@"慕斯",@"冰淇淋",@"糖果",@"珊瑚",@"田野",@"小森林",@"城市"];
    }
    return _filterTitleArr;
}

-(NSMutableArray *)filterImageArr
{
    if (!_filterImageArr) {
        _filterImageArr = @[@"filter_original",@"filter_clean",@"filter_nature",@"filter_fresh",@"filter_glossy",@"filter_tianmei",@"filter_meiwei",@"filter_yangqi",@"filter_yuanqi",@"filter_lolita",@"filter_chulian",@"filter_jiari",@"filter_sunset",@"filter_vintage",@"filter_vivid",@"filter_xinxian",@"filter_makalong",@"filter_musi",@"filter_bingqiling",@"filter_sweety",@"filter_coral",@"filter_grass",@"filter_xiaosenlin",@"filter_urban"].mutableCopy;
    }
    return _filterImageArr;
}

-(UIImage*)getFilterImageWithOriginalImage:(GPUImagePicture*)image lookupImageStr:(NSString*)lookupImageStr
{
    //色彩映射滤镜图片
    GPUImagePicture * lookupImage = [[GPUImagePicture alloc] initWithImage:[UIImage bk_filterImageWithImageName:lookupImageStr]];
    GPUImageLookupFilter * lookupFilter = [[GPUImageLookupFilter alloc] init];
    [image addTarget:lookupFilter atTextureLocation:0];
    [lookupImage addTarget:lookupFilter atTextureLocation:1];
    [image processImage];
    [lookupImage processImage];
    [lookupFilter useNextFrameForImageCapture];
    UIImage * addFilterImage = [lookupFilter imageFromCurrentFramebuffer];
    return addFilterImage;
}

-(NSArray<NSNumber *> *)filterTypeArr
{
    if (!_filterTypeArr) {
        _filterTypeArr = @[@(BKBeautifulSkinTypeOriginal),@(BKBeautifulSkinTypeClean),@(BKBeautifulSkinTypeNature),@(BKBeautifulSkinTypeFresh),@(BKBeautifulSkinTypeGlossy),@(BKBeautifulSkinTypeTianmei),@(BKBeautifulSkinTypeMeiwei),@(BKBeautifulSkinTypeYangqi),@(BKBeautifulSkinTypeYuanqi),@(BKBeautifulSkinTypeLolita),@(BKBeautifulSkinTypeChulian),@(BKBeautifulSkinTypeJiari),@(BKBeautifulSkinTypeSunset),@(BKBeautifulSkinTypeVintage),@(BKBeautifulSkinTypeVivid),@(BKBeautifulSkinTypeXinxian),@(BKBeautifulSkinTypeMakalong),@(BKBeautifulSkinTypeMusi),@(BKBeautifulSkinTypeBingqiling),@(BKBeautifulSkinTypeSweety),@(BKBeautifulSkinTypeCoral),@(BKBeautifulSkinTypeGrass),@(BKBeautifulSkinTypeXiaosenlin),@(BKBeautifulSkinTypeUrban)];
    }
    return _filterTypeArr;
}

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        
        [self addSubview:self.sliderView];
        [self addSubview:self.shadowView];
        [self.shadowView addSubview:self.menuScrollView];
        [self.shadowView addSubview:self.contentView];
    }
    return self;
}

#pragma mark - sliderView

-(UISlider*)sliderView
{
    if (!_sliderView) {
        _sliderView = [[UISlider alloc] initWithFrame:CGRectMake(20, 0, self.bk_width - 40, 40)];
        _sliderView.minimumValue = 0;
        _sliderView.maximumValue = 1;
        _sliderView.value = 0.8;
        _sliderView.alpha = 0;
        _sliderView.minimumTrackTintColor = BKCameraFilterTitleSelectColor;
        _sliderView.maximumTrackTintColor = BKCameraFilterTitleNormalColor;
        _sliderView.thumbTintColor = BKCameraFilterTitleSelectColor;
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _sliderView;
}

-(void)sliderValueChanged:(UISlider*)slider
{
    if (self.switchLookupFilterTypeAction) {
        self.switchLookupFilterTypeAction([self.filterTypeArr[self.selectFilter] integerValue], self.sliderView.value);
    }
}

#pragma mark - shadowView

-(UIView*)shadowView
{
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, self.bk_width, self.bk_height - 40)];
        _shadowView.backgroundColor = BKCameraFilterBackgroundColor;
    }
    return _shadowView;
}

#pragma mark - menuScrollView

-(UIScrollView*)menuScrollView
{
    if (!_menuScrollView) {
        _menuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.shadowView.bk_width, 60)];
        _menuScrollView.backgroundColor = BKClearColor;
        _menuScrollView.showsVerticalScrollIndicator = NO;
        _menuScrollView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _menuScrollView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
        }
        
        CGFloat width = _menuScrollView.bk_width / 5.5;
        [self.menuArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton * menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            menuBtn.frame = CGRectMake(idx*width, 0, width, self.menuScrollView.bk_height);
            [menuBtn setTitle:obj forState:UIControlStateNormal];
            [menuBtn setTitleColor:BKCameraFilterTitleNormalColor forState:UIControlStateNormal];
            [menuBtn setTitleColor:BKCameraFilterTitleNormalColor forState:UIControlStateHighlighted];
            [menuBtn setTitleColor:BKCameraFilterTitleSelectColor forState:UIControlStateSelected];
            menuBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            [menuBtn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            menuBtn.tag = idx;
            if (idx == 0) {
                self.selectMenuBtn = menuBtn;
                self.selectMenuBtn.selected = YES;
                self.selectMenuBtn.userInteractionEnabled = NO;
            }
            [self.menuScrollView addSubview:menuBtn];
        }];
    }
    return _menuScrollView;
}

-(void)menuBtnClick:(UIButton*)button
{
    self.selectMenuBtn.userInteractionEnabled = YES;
    self.selectMenuBtn.selected = NO;
    self.selectMenuBtn = button;
    self.selectMenuBtn.selected = YES;
    self.selectMenuBtn.userInteractionEnabled = NO;
    
    [self.contentView reloadData];
    if (self.selectMenuBtn.tag == 0) {
        self.sliderView.alpha = 0;
    }else if (self.selectMenuBtn.tag == 1) {
        if (self.selectFilter == 0) {
            self.sliderView.alpha = 0;
        }else{
            self.sliderView.alpha = 1;
        }
    }
}

#pragma mark - contentView

-(UICollectionView *)contentView
{
    if (!_contentView) {
        
        CGFloat width = 45 * BK_SCREENW / 375.0f;
        CGFloat height = self.shadowView.bk_height - CGRectGetMaxY(self.menuScrollView.frame);
        CGFloat space = (self.shadowView.bk_width - width*6) / 7;
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = space;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, space, 0, space);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(width, height);
        
        _contentView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.menuScrollView.frame), self.shadowView.bk_width, height) collectionViewLayout:layout];
        _contentView.delegate = self;
        _contentView.dataSource = self;
        _contentView.backgroundColor = BKClearColor;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _contentView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
        }
        
        [_contentView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellID];
    }
    return _contentView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.selectMenuBtn.tag == 0) {
        return 6;
    }else if (self.selectMenuBtn.tag == 1) {
        return [self.filterTitleArr count];
    }else{
        return 0;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (self.selectMenuBtn.tag == 0) {
        
        UILabel * titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, (cell.bk_height - cell.bk_width - 28)/2, cell.bk_width, cell.bk_width)];
        titleLab.backgroundColor = BKCameraFilterLevelBtnBackgroundColor;
        if (indexPath.item == self.selectLevel) {
            titleLab.textColor = BKCameraFilterTitleSelectColor;
        }else{
            titleLab.textColor = BKCameraFilterTitleNormalColor;
        }
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.clipsToBounds = YES;
        titleLab.layer.cornerRadius = titleLab.bk_height/2;
        titleLab.text = [NSString stringWithFormat:@"%ld",indexPath.item];
        titleLab.tag = 1;
        [cell addSubview:titleLab];
        
    }else if (self.selectMenuBtn.tag == 1) {
        
        UIImageView * topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.bk_width, cell.bk_width)];
        topImageView.clipsToBounds = YES;
        topImageView.contentMode = UIViewContentModeScaleAspectFill;
        topImageView.layer.cornerRadius = topImageView.bk_height/2;
        topImageView.tag = 1;
        [cell addSubview:topImageView];
        
        UIImage * exampleImage = self.filterImageArr[indexPath.item];
        if ([exampleImage isKindOfClass:[NSString class]]) {
            UIImage * resultImage = [self getFilterImageWithOriginalImage:self.exampleImage lookupImageStr:(NSString*)exampleImage];
            topImageView.image = resultImage;
            
            if (resultImage) {
                [self.filterImageArr replaceObjectAtIndex:indexPath.item withObject:resultImage];
            }
        }else if ([exampleImage isKindOfClass:[UIImage class]]) {
            topImageView.image = exampleImage;
        }
        
        UILabel * bottomTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topImageView.frame) + 8, cell.bk_width, 20)];
        bottomTitleLab.textAlignment = NSTextAlignmentCenter;
        if (self.selectFilter == indexPath.item) {
            bottomTitleLab.textColor = BKCameraFilterTitleSelectColor;
        }else{
            bottomTitleLab.textColor = BKCameraFilterTitleNormalColor;
        }
        bottomTitleLab.font = [UIFont systemFontOfSize:14];
        bottomTitleLab.text = self.filterTitleArr[indexPath.item];
        bottomTitleLab.tag = 2;
        [cell addSubview:bottomTitleLab];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectMenuBtn.tag == 0) {
        
        self.selectLevel = indexPath.item;
        [self.contentView reloadData];
        
        if (self.switchBeautyFilterLevelAction) {
            self.switchBeautyFilterLevelAction(indexPath.item);
        }
    }else if (self.selectMenuBtn.tag == 1) {
        
        self.selectFilter = indexPath.item;
        [self.contentView reloadData];
        
        if (indexPath.item == 0) {
            
            self.sliderView.value = 0;
            self.sliderView.alpha = 0;
            
            if (self.switchLookupFilterTypeAction) {
                self.switchLookupFilterTypeAction([self.filterTypeArr[self.selectFilter] integerValue], self.sliderView.value);
            }
        }else{
            
            self.sliderView.value = 0.8;
            self.sliderView.alpha = 1;
            
            if (self.switchLookupFilterTypeAction) {
                self.switchLookupFilterTypeAction([self.filterTypeArr[self.selectFilter] integerValue], self.sliderView.value);
            }
        }
    }
}

@end
