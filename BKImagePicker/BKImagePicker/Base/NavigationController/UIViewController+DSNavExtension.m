//
//  UIViewController+DSNavExtension.m
//  DSCnliveShopSDK
//
//  Created by zhaolin on 2018/12/7.
//

#import "UIViewController+DSNavExtension.h"
#import <objc/message.h>

@implementation UIViewController (DSNavExtension)

-(NSDictionary*)pushMessage
{
    return objc_getAssociatedObject(self, @"BKImagePicker_pushMessage_viewController");
}

- (void)setPushMessage:(NSDictionary *)pushMessage
{
    objc_setAssociatedObject(self, @"BKImagePicker_pushMessage_viewController", pushMessage, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


