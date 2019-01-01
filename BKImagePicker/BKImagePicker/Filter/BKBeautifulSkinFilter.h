//
//  BKBeautifulSkinFilter.h
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/17.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "GPUImageFilterGroup.h"

typedef NS_ENUM(NSUInteger, BKBeautifulSkinType) {
    BKBeautifulSkinTypeOriginal = 0,             //正常
    BKBeautifulSkinTypeClean,                    //干净
    BKBeautifulSkinTypeNature,                   //自然
    BKBeautifulSkinTypeFresh,                    //清新
    BKBeautifulSkinTypeGlossy,                   //光泽
    BKBeautifulSkinTypeTianmei,                  //甜美
    BKBeautifulSkinTypeMeiwei,                   //唯美
    BKBeautifulSkinTypeYangqi,                   //洋气
    BKBeautifulSkinTypeYuanqi,                   //元气
    BKBeautifulSkinTypeLolita,                   //萝莉
    BKBeautifulSkinTypeChulian,                  //初恋
    BKBeautifulSkinTypeJiari,                    //假日
    BKBeautifulSkinTypeSunset,                   //傍晚
    BKBeautifulSkinTypeVintage,                  //古老
    BKBeautifulSkinTypeVivid,                    //鲜明
    BKBeautifulSkinTypeXinxian,                  //新鲜
    BKBeautifulSkinTypeMakalong,                 //马卡龙
    BKBeautifulSkinTypeMusi,                     //慕斯
    BKBeautifulSkinTypeBingqiling,               //冰淇淋
    BKBeautifulSkinTypeSweety,                   //糖果
    BKBeautifulSkinTypeCoral,                    //珊瑚
    BKBeautifulSkinTypeGrass,                    //田野
    BKBeautifulSkinTypeXiaosenlin,               //小森林
    BKBeautifulSkinTypeUrban,                    //城市
    BKBeautifulSkinTypeCrisp,                    //
    BKBeautifulSkinTypeJugeng,                   //
    BKBeautifulSkinTypeKissKiss,                 //
    BKBeautifulSkinTypePink,                     //
};

@interface BKBeautifulSkinFilter : GPUImageFilterGroup

/**
 类型
 */
@property (nonatomic,assign) BKBeautifulSkinType type;

/**
 程度 0~1
 */
@property (nonatomic,assign) CGFloat level;

@end
