//
//  BKImageOriginalButton.h
//  BKImagePicker
//
//  Created by zhaolin on 2018/4/13.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKImageOriginalButton : UIView

/**
 标题
 */
@property (nonatomic,strong) NSString * title;

/**
 标题
 */
@property (nonatomic,strong) UIColor * titleColor;

/**
 点击事件
 */
@property (nonatomic,copy) void (^tapSelctAction)(void);

@end
