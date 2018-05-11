//
//  NSObject+BKImagePicker.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/2.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "NSObject+BKImagePicker.h"

@implementation NSObject (BKImagePicker)

-(NSDictionary*)bk_dicTag
{
    return objc_getAssociatedObject(self, @"bk_dicTag");
}

- (void)setBk_dicTag:(NSDictionary *)bk_dicTag
{
    objc_setAssociatedObject(self, @"bk_dicTag", bk_dicTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString*)bk_strTag
{
    return objc_getAssociatedObject(self, @"bk_strTag");
}

-(void)setBk_strTag:(NSString *)bk_strTag
{
    objc_setAssociatedObject(self, @"bk_strTag", bk_strTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
