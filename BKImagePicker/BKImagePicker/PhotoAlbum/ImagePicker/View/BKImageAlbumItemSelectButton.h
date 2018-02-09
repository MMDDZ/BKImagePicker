//
//  BKImageAlbumItemSelectButton.h
//  BKImagePicker
//
//  Created by iMac on 16/10/18.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKImageAlbumItemSelectButton : UIView

/**
 标记选中第几个
 */
@property (nonatomic,copy) NSString * title;

/**
 点击方法
 */
@property (nonatomic,copy) void (^selectButtonClick)(BKImageAlbumItemSelectButton*button);

-(void)selectClickNum:(NSInteger)num addMethod:(void (^)(void))method;

@end
