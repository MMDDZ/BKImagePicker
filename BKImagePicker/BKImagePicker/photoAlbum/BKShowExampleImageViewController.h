//
//  BKShowExampleImageViewController.h
//  BKImagePicker
//
//  Created by 毕珂 on 16/10/15.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface BKShowExampleImageViewController : UIViewController

@property (nonatomic,strong) PHFetchResult<PHAsset *> *assets;

@end
