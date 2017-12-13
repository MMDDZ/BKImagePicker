//
//  BKImageClassViewController.m
//  BKImagePicker
//
//  Created by iMac on 16/10/13.
//  Copyright © 2016年 BIKE. All rights reserved.
//

#define ROW_HEIGHT _imageClassTableView.frame.size.height/10.0f

#import "BKImageClassViewController.h"
#import "BKImagePickerViewController.h"
#import <Photos/Photos.h>
#import "BKImageClassModel.h"
#import "BKImageClassTableViewCell.h"

@interface BKImageClassViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UIView * topView;

@property (nonatomic,strong) UITableView * imageClassTableView;
@property (nonatomic,strong) NSMutableArray * imageClassArray;

@end

@implementation BKImageClassViewController

-(NSMutableArray*)imageClassArray
{
    if (!_imageClassArray) {
        _imageClassArray = [NSMutableArray array];
    }
    return _imageClassArray;
}

-(void)getAllImageClassData
{
    //系统的相簿
    PHFetchResult * smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [self getSingleAlbum:smartAlbums];
    
    //用户自己创建的相簿
    PHFetchResult * userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    [self getSingleAlbum:userAlbums];
}

-(void)getSingleAlbum:(PHFetchResult*)fetchResult
{
    [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAssetCollection *collection = obj;
        BKImageClassModel * model = [[BKImageClassModel alloc]init];
        
        // 获取所有资源的集合按照创建时间倒序排列
        PHFetchOptions * fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d || mediaType = %d",PHAssetMediaTypeImage,PHAssetMediaTypeVideo];
        
        PHFetchResult<PHAsset *> *assets  = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
        if ([assets count] > 0) {
            
            __block NSInteger coverCount = 0;
            __block NSInteger assetsCount = [assets count];
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                switch (self.photoType) {
                    case BKPhotoTypeDefault:
                        break;
                    case BKPhotoTypeImageAndGif:
                    {
                        if (obj.mediaType == PHAssetMediaTypeVideo) {
                            assetsCount--;
                            
                            if (idx == coverCount) {
                                coverCount++;
                            }
                        }
                    }
                        break;
                    case BKPhotoTypeImageAndVideo:
                    {
                        NSString * fileName = [obj valueForKey:@"filename"];
                        if ([fileName rangeOfString:@"gif"].location != NSNotFound || [fileName rangeOfString:@"GIF"].location != NSNotFound) {
                            assetsCount--;
                            
                            if (idx == coverCount) {
                                coverCount++;
                            }
                        }
                    }
                        break;
                    case BKPhotoTypeImage:
                    {
                        if (obj.mediaType == PHAssetMediaTypeImage) {
                            
                            NSString * fileName = [obj valueForKey:@"filename"];
                            if ([fileName rangeOfString:@"gif"].location != NSNotFound || [fileName rangeOfString:@"GIF"].location != NSNotFound) {
                                assetsCount--;
                                
                                if (idx == coverCount) {
                                    coverCount++;
                                }
                            }
                        }else{
                            assetsCount--;
                            
                            if (idx == coverCount) {
                                coverCount++;
                            }
                        }
                    }
                        break;
                }
            }];
            
            if (assetsCount > 0) {
                
                PHAsset * asset = assets[coverCount];
                
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
                options.synchronous = YES;
                
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(SCREENW/2.0f, SCREENW/2.0f) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    // 排除取消，错误，低清图三种情况，即已经获取到了高清图
                    BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (downImageloadFinined) {
                        if(result) {
                            model.albumName = collection.localizedTitle;
                            model.albumFirstImage = result;
                            model.albumImageCount = assetsCount;
                            
                            [self.imageClassArray addObject:model];
                            [self.imageClassTableView reloadData];
                        }
                    }
                }];
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"相册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:[self topView]];
    [self.view addSubview:[self imageClassTableView]];
    [self getAllImageClassData];
}

#pragma mark - topView

-(UIView*)topView
{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENW, SYSTEM_NAV_HEIGHT)];
        _topView.backgroundColor = BKNavBackgroundColor;
        
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(64, SYSTEM_STATUSBAR_HEIGHT, SCREENW - 64*2, SYSTEM_NAV_UI_HEIGHT)];
        titleLab.font = [UIFont boldSystemFontOfSize:17];
        titleLab.textColor = [UIColor blackColor];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = self.title;
        [_topView addSubview:titleLab];
        
        UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(SCREENW - 64, SYSTEM_STATUSBAR_HEIGHT, 64, SYSTEM_NAV_UI_HEIGHT);
        [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        [rightBtn setTitleColor:BKNavHighlightTitleColor forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:rightBtn];
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(0, SYSTEM_NAV_HEIGHT - ONE_PIXEL, SCREENW, ONE_PIXEL)];
        line.backgroundColor = BKLineColor;
        [_topView addSubview:line];
    }
    return _topView;
}

-(void)rightBtnClick:(UIButton*)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView

-(UITableView*)imageClassTableView
{
    if (!_imageClassTableView) {
        _imageClassTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, SYSTEM_NAV_HEIGHT, SCREENW, SCREENH - SYSTEM_NAV_HEIGHT) style:UITableViewStylePlain];
        _imageClassTableView.delegate = self;
        _imageClassTableView.dataSource = self;
        _imageClassTableView.showsVerticalScrollIndicator = NO;
        _imageClassTableView.tableFooterView = [UIView new];
        _imageClassTableView.rowHeight = ROW_HEIGHT;
        _imageClassTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _imageClassTableView.estimatedRowHeight = 0;
            _imageClassTableView.estimatedSectionFooterHeight = 0;
            _imageClassTableView.estimatedSectionHeaderHeight = 0;
            _imageClassTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _imageClassTableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.imageClassArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"BKImageClassTableViewCell";
    BKImageClassTableViewCell * cell = (BKImageClassTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BKImageClassTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(ROW_HEIGHT+ROW_HEIGHT/3, ROW_HEIGHT-ONE_PIXEL, SCREENW-(ROW_HEIGHT+ROW_HEIGHT/3), ONE_PIXEL)];
        line.backgroundColor = BKLineColor;
        [cell addSubview:line];
    }
    
    BKImageClassModel * model = self.imageClassArray[indexPath.row];
    
    cell.exampleImageView.frame = CGRectMake(ROW_HEIGHT/3, 3, ROW_HEIGHT-6, ROW_HEIGHT-6);
    cell.exampleImageView.image = model.albumFirstImage;
    
    cell.titleLab.frame = CGRectMake(CGRectGetMaxX(cell.exampleImageView.frame)+ROW_HEIGHT/3, 0, 0, 0);
    cell.titleLab.text = model.albumName;
    [cell.titleLab sizeToFit];
    CGPoint titleLabCenter = cell.titleLab.center;
    titleLabCenter.y = cell.exampleImageView.center.y;
    cell.titleLab.center = titleLabCenter;
    
    cell.countLab.frame = CGRectMake(CGRectGetMaxX(cell.titleLab.frame)+5, 0, 0, 0);
    cell.countLab.text = [NSString stringWithFormat:@"(%ld)",model.albumImageCount];
    [cell.countLab sizeToFit];
    CGPoint countLabCenter = cell.countLab.center;
    countLabCenter.y = cell.exampleImageView.center.y;
    cell.countLab.center = countLabCenter;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BKImageClassModel * model = self.imageClassArray[indexPath.row];
    
    BKImagePickerViewController * imageVC = [[BKImagePickerViewController alloc]init];
    imageVC.title = model.albumName;
    imageVC.selectImageArray = [NSMutableArray arrayWithArray:self.selectImageArray];
    imageVC.isOriginal = self.isOriginal;
    imageVC.max_select = self.max_select;
    imageVC.photoType = self.photoType;
    
    [self.navigationController pushViewController:imageVC animated:YES];
}

@end
