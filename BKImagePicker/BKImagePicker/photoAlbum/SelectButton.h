//
//  SelectButton.h
//  BKImagePicker
//
//  Created by iMac on 16/10/18.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectButton : UIButton

/**
 标记选中第几个
 */
@property (nonatomic,copy) NSString * title;

-(instancetype)initSelectButtonWithFrame:(CGRect)frame;

-(void)selectClickNum:(NSInteger)num addMethod:(void (^)())method;

@end
