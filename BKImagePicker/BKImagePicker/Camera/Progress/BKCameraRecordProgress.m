//
//  BKCameraRecordProgress.m
//  BKProjectFramework
//
//  Created by BIKE on 2018/8/2.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#import "BKCameraRecordProgress.h"
#import "BKCameraRecordProgressModel.h"
#import "UIView+BKImagePicker.h"
#import "BKImagePickerConstant.h"
#import "BKImagePickerMacro.h"

@interface BKCameraRecordProgress()

@property (nonatomic,strong) NSMutableArray<BKCameraRecordProgressModel*> * progressDataArr;

@property (nonatomic,assign) CGFloat aTimeWidth;
@property (nonatomic,strong) UIView * progressView;

@end

@implementation BKCameraRecordProgress

#pragma mark - get

-(NSMutableArray*)progressDataArr
{
    if (!_progressDataArr) {
        _progressDataArr = [NSMutableArray array];
    }
    return _progressDataArr;
}

-(CGFloat)aTimeWidth
{
    if (_aTimeWidth == 0) {
        _aTimeWidth = self.bk_width / BKRecordVideoMaxTime;
    }
    return _aTimeWidth;
}

#pragma mark - set

-(void)setCurrentTime:(CGFloat)currentTime
{
    _currentTime = currentTime;
    
    self.progressView.bk_width = self.aTimeWidth * _currentTime;
}

#pragma mark - init

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = BKClearColor;
    }
    return self;
}

#pragma mark - 进度条

-(UIView*)progressView
{
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.bk_height)];
        _progressView.backgroundColor = BKCameraRecordVideoProgressColor;
        [self addSubview:_progressView];
    }
    return _progressView;
}

#pragma mark - 录制状态

-(void)pauseRecord
{
    UIView * pauseView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.progressView.frame) - 1, 0, 1, self.bk_height)];
    pauseView.backgroundColor = BKCameraPauseRecordVideoProgressColor;
    [self addSubview:pauseView];
    
    BKCameraRecordProgressModel * model = [[BKCameraRecordProgressModel alloc] init];
    model.currentPauseView = pauseView;
    model.currentTime = self.currentTime;
    [self.progressDataArr addObject:model];
}

-(void)removeLastRecord
{
    if ([self.progressDataArr count] > 0) {
        BKCameraRecordProgressModel * model = [self.progressDataArr lastObject];
        [model.currentPauseView removeFromSuperview];
        [self.progressDataArr removeLastObject];
        BKCameraRecordProgressModel * lastModel = [self.progressDataArr lastObject];
        if ([self.progressDataArr count] == 0) {
            self.currentTime = 0;
        }else{
            self.currentTime = lastModel.currentTime;
        }
    }
}

@end
