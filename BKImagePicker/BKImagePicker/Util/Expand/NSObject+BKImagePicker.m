//
//  NSObject+BKImagePicker.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/2.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "NSObject+BKImagePicker.h"

@implementation NSObject (BKExpand)

-(NSDictionary*)dicTag
{
    return objc_getAssociatedObject(self, @"dicTag");
}

- (void)setDicTag:(NSDictionary *)dicTag
{
    objc_setAssociatedObject(self, @"dicTag", dicTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString*)strTag
{
    return objc_getAssociatedObject(self, @"strTag");
}

-(void)setStrTag:(NSString *)strTag
{
    objc_setAssociatedObject(self, @"strTag", strTag, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
