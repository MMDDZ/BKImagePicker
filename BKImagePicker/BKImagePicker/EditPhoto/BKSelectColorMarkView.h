//
//  BKSelectColorMarkView.h
//  BKImagePicker
//
//  Created by 毕珂 on 2017/5/12.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    BKSelectTypeColor = 0,
    BKSelectTypeMaSaiKe,
} BKSelectType;

@interface BKSelectColorMarkView : UIImageView

@property (nonatomic,strong) UIColor * selectColor;

@property (nonatomic,assign) BKSelectType selectType;

@end
