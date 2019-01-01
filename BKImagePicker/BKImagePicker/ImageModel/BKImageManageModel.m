//
//  BKImageManageModel.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/7/19.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKImageManageModel.h"

@implementation BKImageManageModel

-(NSMutableArray*)selectImageArray
{
    if (!_selectImageArray) {
        _selectImageArray = [NSMutableArray array];
    }
    return _selectImageArray;
}

@end
