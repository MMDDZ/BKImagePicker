//
//  BKShowExampleVideoView.h
//  BKImagePicker
//
//  Created by iMac on 16/11/1.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface BKShowExampleVideoView : UIView

-(instancetype)initWithAsset:(PHAsset*)asset;

-(void)showInVC:(UIViewController*)vc;

@end
