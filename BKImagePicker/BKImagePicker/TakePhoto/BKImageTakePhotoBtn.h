//
//  BKImageTakePhotoBtn.h
//  guoguanjuyanglao
//
//  Created by zhaolin on 2017/12/21.
//  Copyright © 2017年 zhaolin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKImageTakePhotoBtn : UIView

@property (nonatomic,copy) void (^shutterAction)(void);

@end