//
//  BKPhotoAlbumListViewController.m
//  BKImagePicker
//
//  Created by BIKE on 2018/2/5.
//  Copyright © 2018年 BIKE. All rights reserved.
//

#define ROW_HEIGHT BK_SCREENH/10.0f

#import "BKPhotoAlbumListViewController.h"
#import "BKImagePickerViewController.h"
#import <Photos/Photos.h>
#import "BKPhotoAlbumListModel.h"
#import "BKPhotoAlbumListTableViewCell.h"
#import "BKImagePicker.h"

@interface BKPhotoAlbumListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * imageClassTableView;
@property (nonatomic,strong) NSMutableArray * imageClassArray;

@end

@implementation BKPhotoAlbumListViewController

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
        BKPhotoAlbumListModel * model = [[BKPhotoAlbumListModel alloc]init];
        
        // 获取所有资源的集合按照创建时间倒序排列
        PHFetchOptions * fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d || mediaType = %d",PHAssetMediaTypeImage,PHAssetMediaTypeVideo];
        
        PHFetchResult<PHAsset *> *assets  = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
        if ([assets count] > 0) {
            
            __block NSInteger coverCount = 0;
            __block NSInteger assetsCount = [assets count];
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                switch ([BKTool sharedManager].photoType) {
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
                options.networkAccessAllowed = YES;
                
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(BK_SCREENW/2.0f, BK_SCREENW/2.0f) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
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

#pragma mark - init

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self getAllImageClassData];
    }
    return self;
}

#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTopNav];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.imageClassTableView.frame = CGRectMake(0, CGRectGetMaxY(self.topNavView.frame), self.view.bk_width, self.view.bk_height - CGRectGetMaxY(self.topNavView.frame) - self.bottomNavView.bk_height);
}

#pragma mark - initTopNav

-(void)initTopNav
{
    self.title = @"相册";
    self.rightLab.text = @"取消";
    self.leftImageView.image = nil;
}

-(void)leftNavBtnAction:(UIButton *)button
{
    
}

-(void)rightNavBtnAction:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView

-(UITableView*)imageClassTableView
{
    if (!_imageClassTableView) {
        _imageClassTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
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
        [self.view addSubview:_imageClassTableView];
    }
    return _imageClassTableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.imageClassArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"BKPhotoAlbumListTableViewCell";
    BKPhotoAlbumListTableViewCell * cell = (BKPhotoAlbumListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BKPhotoAlbumListTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(ROW_HEIGHT+ROW_HEIGHT/3, ROW_HEIGHT-BK_ONE_PIXEL, BK_SCREENW-(ROW_HEIGHT+ROW_HEIGHT/3), BK_ONE_PIXEL)];
        line.backgroundColor = BKLineColor;
        [cell addSubview:line];
    }
    
    BKPhotoAlbumListModel * model = self.imageClassArray[indexPath.row];
    
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
    BKPhotoAlbumListModel * model = self.imageClassArray[indexPath.row];
    
    BKImagePickerViewController * imageVC = [[BKImagePickerViewController alloc]init];
    imageVC.title = model.albumName;    
    [self.navigationController pushViewController:imageVC animated:YES];
}

@end
