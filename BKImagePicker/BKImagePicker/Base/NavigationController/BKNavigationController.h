//
//  BKNavigationController.h
//  
//
//  Created by BIKE on 2018/7/12.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationController+DSNavExtension.h"

@interface BKNavigationController : UINavigationController

#pragma mark - 自定义过场动画

/**
 是否是其他自定义push动画
 如果采用其他自定义push动画 在push前设置delegate = 对应类 ; pop后或者push下一个vc不采用其他自定义push动画前设置导航delegate = nil
 */

@end
