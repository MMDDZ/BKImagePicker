//
//  BKBeautifulSkinFilter.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/17.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKBeautifulSkinFilter.h"
#import "GPUImage.h"
#import "UIImage+BKImagePicker.h"

@interface BKBeautifulSkinFilter()

/**
 色彩映射滤镜
 */
@property (nonatomic,strong) GPUImageLookupFilter * lookupFilter;

@end

@implementation BKBeautifulSkinFilter

#pragma mark - set

-(void)setLevel:(CGFloat)level
{
    if (_level == level) {
        return;
    }
    
    _level = level;
    
    if (level > 1) {
        self.lookupFilter.intensity = 1;
    }else if (level < 0) {
        self.lookupFilter.intensity = 0;
    }else {
        self.lookupFilter.intensity = _level;
    }
}

-(void)setType:(BKBeautifulSkinType)type
{
    if (_type == type) {
        return;
    }
    
    //以下所有图片来自 https://www.jianshu.com/p/ceb6812b47aa
    _type = type;
    UIImage * lookupImage = nil;
    switch (_type) {
        case BKBeautifulSkinTypeOriginal:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_original"];
        }
            break;
        case BKBeautifulSkinTypeClean:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_clean"];
        }
            break;
        case BKBeautifulSkinTypeNature:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_nature"];
        }
            break;
        case BKBeautifulSkinTypeXinxian:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_xinxian"];
        }
            break;
        case BKBeautifulSkinTypeFresh:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_fresh"];
        }
            break;
        case BKBeautifulSkinTypeBingqiling:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_bingqiling"];
        }
            break;
        case BKBeautifulSkinTypeChulian:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_chulian"];
        }
            break;
        case BKBeautifulSkinTypeCoral:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_coral"];
        }
            break;
        case BKBeautifulSkinTypeCrisp:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_crisp"];
        }
            break;
        case BKBeautifulSkinTypeGlossy:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_glossy"];
        }
            break;
        case BKBeautifulSkinTypeGrass:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_grass"];
        }
            break;
        case BKBeautifulSkinTypeJiari:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_jiari"];
        }
            break;
        case BKBeautifulSkinTypeJugeng:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_jugeng"];
        }
            break;
        case BKBeautifulSkinTypeKissKiss:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_kisskiss"];
        }
            break;
        case BKBeautifulSkinTypeLolita:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_lolita"];
        }
            break;
        case BKBeautifulSkinTypeMakalong:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_makalong"];
        }
            break;
        case BKBeautifulSkinTypeMeiwei:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_meiwei"];
        }
            break;
        case BKBeautifulSkinTypeMusi:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_musi"];
        }
            break;
        case BKBeautifulSkinTypePink:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_pink"];
        }
            break;
        case BKBeautifulSkinTypeSunset:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_sunset"];
        }
            break;
        case BKBeautifulSkinTypeSweety:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_sweety"];
        }
            break;
        case BKBeautifulSkinTypeTianmei:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_tianmei"];
        }
            break;
        case BKBeautifulSkinTypeUrban:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_urban"];
        }
            break;
        case BKBeautifulSkinTypeVintage:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_vintage"];
        }
            break;
        case BKBeautifulSkinTypeVivid:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_vivid"];
        }
            break;
        case BKBeautifulSkinTypeXiaosenlin:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_xiaosenlin"];
        }
            break;
        case BKBeautifulSkinTypeYangqi:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_yangqi"];
        }
            break;
        case BKBeautifulSkinTypeYuanqi:
        {
            lookupImage = [UIImage bk_filterImageWithImageName:@"filter_yuanqi"];
        }
            break;
        default:
            break;
    }
    
    GPUImagePicture * imageSource = [[GPUImagePicture alloc] initWithImage:lookupImage];
    [imageSource addTarget:self.lookupFilter atTextureLocation:1];
    [imageSource processImage];
}

#pragma mark - init

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        self.lookupFilter = [[GPUImageLookupFilter alloc] init];
        self.lookupFilter.intensity = 0;
        [self addFilter:self.lookupFilter];
        
        UIImage * lookupImage = [UIImage bk_filterImageWithImageName:@"filter_original"];
        GPUImagePicture * imageSource = [[GPUImagePicture alloc] initWithImage:lookupImage];
        [imageSource addTarget:self.lookupFilter atTextureLocation:1];
        [imageSource processImage];
        
        self.initialFilters = @[self.lookupFilter];
        self.terminalFilter = self.lookupFilter;
        
    }
    return self;
}

@end
