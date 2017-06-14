//
//  BKShowExampleVideoView.h
//  BKImagePicker
//
//  Created by iMac on 16/11/1.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "BKImagePicker.h"
#import "BKImageModel.h"

@interface BKShowExampleVideoView : UIView

-(instancetype)initWithModel:(BKImageModel*)model;

-(void)showInVC:(UIViewController *)locationVC;

@end
