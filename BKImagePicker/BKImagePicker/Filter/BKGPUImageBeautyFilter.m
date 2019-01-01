//
//  BKGPUImageBeautyFilter.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/27.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKGPUImageBeautyFilter.h"

@interface BKGPUImageBeautyFilter()

/**
 磨皮滤镜
 */
@property (nonatomic,strong) BKImagePickerGPUImageBeautifyFilter * beautyFilter;

/**
 亮度滤镜
 */
@property (nonatomic,strong) GPUImageBrightnessFilter * brightnessFilter;

/**
 美肤滤镜
 */
@property (nonatomic,strong) BKBeautifulSkinFilter * beautifulSkinFilter;

/**
 添加的滤镜数据 (自带数组self.targets一直是空数组...)
 */
@property (nonatomic,strong) NSMutableArray<GPUImageFilter*> * groupTargets;

@end

@implementation BKGPUImageBeautyFilter

#pragma mark - 美颜等级

-(void)setBeautyLevel:(BKBeautyLevel)beautyLevel
{
    _beautyLevel = beautyLevel;
    
    GPUImageBilateralFilter * bilateralFilter = [self.beautyFilter valueForKey:@"bilateralFilter"];
    if (!bilateralFilter) {
        return;
    }
    
    switch (_beautyLevel) {
        case BKBeautyLevelZero:
        {
            bilateralFilter.texelSpacingMultiplier = 0;
            bilateralFilter.distanceNormalizationFactor = 8;
        }
            break;
        case BKBeautyLevelOne:
        {
            bilateralFilter.texelSpacingMultiplier = 1.6;
            bilateralFilter.distanceNormalizationFactor = 7;
        }
            break;
        case BKBeautyLevelTwo:
        {
            bilateralFilter.texelSpacingMultiplier = 3.2;
            bilateralFilter.distanceNormalizationFactor = 6;
        }
            break;
        case BKBeautyLevelThree:
        {
            bilateralFilter.texelSpacingMultiplier = 4.8;
            bilateralFilter.distanceNormalizationFactor = 5;
        }
            break;
        case BKBeautyLevelFour:
        {
            bilateralFilter.texelSpacingMultiplier = 6.4;
            bilateralFilter.distanceNormalizationFactor = 4;
        }
            break;
        case BKBeautyLevelFive:
        {
            bilateralFilter.texelSpacingMultiplier = 8;
            bilateralFilter.distanceNormalizationFactor = 3;
        }
            break;
        default:
            break;
    }
}

#pragma mark - 亮度等级

-(void)setBrightnessLevel:(CGFloat)brightnessLevel
{
    _brightnessLevel = brightnessLevel;
    self.brightnessFilter.brightness = _brightnessLevel;
}

#pragma mark - 修改皮肤色彩

-(void)switchLookupFilterType:(BKBeautifulSkinType)type level:(CGFloat)level
{
    self.beautifulSkinFilter.type = type;
    self.beautifulSkinFilter.level = level;
}

#pragma mark - get

-(NSMutableArray<GPUImageFilter *> *)groupTargets
{
    if (!_groupTargets) {
        _groupTargets = [NSMutableArray array];
    }
    return _groupTargets;
}

#pragma mark - init

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self bk_addFilter:(GPUImageFilter*)self.beautyFilter];
        [self bk_addFilter:self.brightnessFilter];
        [self bk_addFilter:(GPUImageFilter*)self.beautifulSkinFilter];
    }
    return self;
}

#pragma mark - 滤镜

-(BKImagePickerGPUImageBeautifyFilter*)beautyFilter
{
    if (!_beautyFilter) {
        _beautyFilter = [[BKImagePickerGPUImageBeautifyFilter alloc] init];
        [self setBeautyLevel:BKBeautyLevelZero];
    }
    return _beautyFilter;
}

-(GPUImageBrightnessFilter*)brightnessFilter
{
    if (!_brightnessFilter) {
        _brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
        _brightnessFilter.brightness = 0;
    }
    return _brightnessFilter;
}

-(BKBeautifulSkinFilter*)beautifulSkinFilter
{
    if (!_beautifulSkinFilter) {
        _beautifulSkinFilter = [[BKBeautifulSkinFilter alloc] init];
    }
    return _beautifulSkinFilter;
}

#pragma mark - 添加滤镜

-(void)bk_addFilter:(GPUImageFilter*)filter
{
    if ([self.groupTargets containsObject:filter] || !filter) {
        return;
    }
    
    if ([self.groupTargets count] == 0) {

        [self addTarget:filter];
        
        self.initialFilters = @[filter];
        self.terminalFilter = filter;
    }else if ([self.groupTargets count] > 0) {
        
        GPUImageFilter * lastFilter = [self.groupTargets lastObject];
        
        [self addTarget:filter];
        
        [lastFilter addTarget:filter];
        
        self.initialFilters = @[[self.groupTargets firstObject]];
        self.terminalFilter = filter;
    }
    
    [self.groupTargets addObject:filter];
}

#pragma mark - 删除滤镜

-(void)bk_removeFilter:(GPUImageFilter*)filter
{
    if (![self.groupTargets containsObject:filter] || !filter) {
        return;
    }
    
    if ([self.groupTargets count] == 1) {
        
        [self.groupTargets removeAllObjects];
        [self removeAllTargets];
        
        self.initialFilters = @[];
        self.terminalFilter = nil;
        
    }else if ([self.groupTargets count] > 1) {
        
        [self.groupTargets removeLastObject];
        [self removeTarget:filter];
        
        GPUImageFilter * lastFilter = [self.groupTargets lastObject];
        [lastFilter removeTarget:filter];
        
        self.initialFilters = @[[self.groupTargets firstObject]];
        self.terminalFilter = lastFilter;
    }
}

@end
