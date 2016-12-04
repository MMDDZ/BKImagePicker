//
//  BKShowExampleGIFView.h
//  BKImagePicker
//
//  Created by 毕珂 on 16/11/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "BKImagePicker.h"

@interface BKShowExampleGIFView : UIView

@property (nonatomic,copy) void (^finishSelectOption)(NSArray * imageArr,BKSelectPhotoType selectPhotoType);

-(instancetype)initWithAsset:(PHAsset*)asset;

-(void)showInVC:(UIViewController*)vc;

@end
