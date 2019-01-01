//
//  UIViewController+DSNavExtension.h
//  DSCnliveShopSDK
//
//  Created by zhaolin on 2018/12/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (DSNavExtension)

/**
 push时保留的信息
 */
@property (nonatomic,copy) NSDictionary * pushMessage;

@end

NS_ASSUME_NONNULL_END
