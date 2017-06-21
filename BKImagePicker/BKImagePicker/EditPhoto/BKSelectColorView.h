//
//  BKSelectColorView.h
//  BKImagePicker
//
//  Created by 毕珂 on 2017/5/1.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BKSelectColorMarkView.h"

@protocol BKSelectColorViewDelegate <NSObject>

@optional

/**
 撤销
 */
-(void)revocationAction;

/**
 选取颜色

 @param color 颜色(不是颜色类型此参数为nil)
 @param selectType 选取类型
 */
-(void)selectColor:(UIColor*)color orSelectType:(BKSelectType)selectType;

@end

@interface BKSelectColorView : UIView

@property (nonatomic,assign) id<BKSelectColorViewDelegate> delegate;

-(instancetype)initWithStartPosition:(CGPoint)point delegate:(id)delegate;

@end
