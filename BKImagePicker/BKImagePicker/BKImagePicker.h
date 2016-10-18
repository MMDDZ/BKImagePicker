//
//  BKImagePicker.h
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKImagePicker : NSObject

/**
 最大选取量
 */
@property (nonatomic,assign) NSInteger max_select;

-(void)takePhoto;

-(void)photoAlbum;

@end
