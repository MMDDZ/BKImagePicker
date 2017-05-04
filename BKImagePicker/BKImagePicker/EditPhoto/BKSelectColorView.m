//
//  BKSelectColorView.m
//  BKImagePicker
//
//  Created by 毕珂 on 2017/5/1.
//  Copyright © 2017年 BIKE. All rights reserved.
//

#import "BKSelectColorView.h"
#import "BKImagePickerConst.h"

@implementation BKSelectColorView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self createColorBtn];
    }
    return self;
}

-(void)createColorBtn
{
    for (int i = 0; i < 10 ; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(UISCREEN_WIDTH/8, 0, UISCREEN_WIDTH/2, self.bk_height);
        [button addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonDragIn:) forControlEvents:UIControlEventTouchDragInside];
        button.tag = i+1;
        [self addSubview:button];
        
        UIImageView * colorImageView = [[UIImageView alloc]initWithFrame:button.bounds];
        switch (i) {
            case 0:
            {
                colorImageView.backgroundColor = [UIColor redColor];
            }
                break;
            case 1:
            {
                colorImageView.backgroundColor = [UIColor orangeColor];
            }
                break;
            case 2:
            {
                colorImageView.backgroundColor = [UIColor yellowColor];
            }
                break;
            case 3:
            {
                colorImageView.backgroundColor = [UIColor greenColor];
            }
                break;
            case 4:
            {
                colorImageView.backgroundColor = [UIColor blueColor];
            }
                break;
            case 5:
            {
                colorImageView.backgroundColor = [UIColor purpleColor];
            }
                break;
            case 6:
            {
                colorImageView.backgroundColor = [UIColor blackColor];
            }
                break;
            case 7:
            {
                colorImageView.backgroundColor = [UIColor whiteColor];
            }
                break;
            case 8:
            {
                colorImageView.backgroundColor = [UIColor lightGrayColor];
            }
                break;
            case 9:
            {
                
            }
                break;
            default:
                break;
        }
    }
}

-(void)buttonDown:(UIButton*)button
{
    
}

-(void)buttonDragIn:(UIButton*)button
{
    
}

@end
