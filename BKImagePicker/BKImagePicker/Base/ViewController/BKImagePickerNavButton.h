//
//  BKImagePickerNavButton.h
//  BKImagePicker
//
//  Created by 毕珂 on 2019/1/1.
//  Copyright © 2019年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 当图片和标题同时存在时 图片相对于标题的位置
 
 - DSImagePositionLeft: 左边
 - DSImagePositionTop: 上边
 - DSImagePositionRight: 右边
 - DSImagePositionBottom: 下边
 */
typedef NS_ENUM(NSUInteger, DSImagePosition) {
    DSImagePositionLeft = 0,
    DSImagePositionTop,
    DSImagePositionRight,
    DSImagePositionBottom,
};

@interface BKImagePickerNavButton : UIView

/***************************************************************************************************
 默认frame = CGRectMake(自动排列间距0, get_system_statusBar_height(), get_system_nav_ui_height(), get_system_nav_ui_height())
 ***************************************************************************************************/

#pragma mark - 图片init

-(instancetype)initWithImage:(UIImage *)image;
-(instancetype)initWithImage:(UIImage *)image imageSize:(CGSize)imageSize;

#pragma mark - 标题init

-(instancetype)initWithTitle:(NSString*)title;
-(instancetype)initWithTitle:(NSString*)title font:(UIFont*)font;
-(instancetype)initWithTitle:(NSString*)title titleColor:(UIColor*)titleColor;
-(instancetype)initWithTitle:(NSString*)title font:(UIFont*)font titleColor:(UIColor*)titleColor;

#pragma mark - 图片&标题init

-(instancetype)initWithImage:(UIImage *)image title:(NSString*)title;
-(instancetype)initWithImage:(UIImage *)image title:(NSString*)title imagePosition:(DSImagePosition)imagePosition;
-(instancetype)initWithImage:(UIImage *)image imageSize:(CGSize)imageSize title:(NSString*)title;
-(instancetype)initWithImage:(UIImage *)image imageSize:(CGSize)imageSize title:(NSString*)title imagePosition:(DSImagePosition)imagePosition;
-(instancetype)initWithImage:(UIImage *)image imageSize:(CGSize)imageSize title:(NSString*)title font:(UIFont*)font titleColor:(UIColor*)titleColor imagePosition:(DSImagePosition)imagePosition;

#pragma mark - 点击方法

/**
 点击方法(无参数)
 
 @param target 对象
 @param action 方法
 */
-(void)addTarget:(nullable id)target action:(nonnull SEL)action;

/**
 点击方法(单参数)
 
 @param target 对象
 @param action 方法
 @param object 单参数
 */
-(void)addTarget:(nullable id)target action:(nonnull SEL)action object:(id)object;

/**
 点击方法(多参数)
 
 @param target 对象
 @param action 方法
 @param objects 多参数
 */
-(void)addTarget:(nullable id)target action:(nonnull SEL)action objects:(NSArray * _Nullable)objects;

#pragma mark - 修改

/**
 标题
 */
@property (nonatomic,copy) NSString * title;

/**
 图片
 */
@property (nonatomic,strong) UIImage * image;

@end

NS_ASSUME_NONNULL_END
