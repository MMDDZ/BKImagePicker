//
//  UIViewController+BKExpand.h
//  BKImagePicker
//
//  Created by 毕珂 on 16/12/25.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackItemHandlerProtocol <NSObject>

@optional

-(BOOL)navigationShouldPopOnBackItem;

@end

@interface UIViewController (BKExpand) <BackItemHandlerProtocol>

@end
