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
                
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width/2.0f, [UIScreen mainScreen].bounds.size.width/2.0f) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    // 排除取消，错误，低清图三种情况，即已经获取到了高清图
                    BOOL downImageloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (downImageloadFinined) {
                        if(result)
                        {
                            NSDictionary * albumDic = @{@"album_name":collection.localizedTitle,@"album_example_image":result,@"album_image_count":[NSString stringWithFormat:@"%ld",assetsCount]};
                            [self.imageClassArray addObject:albumDic];
                            [self.imageClassTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.imageClassArray count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
    
    NSDictionary * info_dic = [[NSBundle mainBundle] infoDictionary];
    NSString * info_language = info_dic[@"CFBundleDevelopmentRegion"];
    if ([info_language rangeOfString:@"zh"].location != NSNotFound) {
        self.title = @"相册";
    }else{
        self.title = @"Albums";
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:[self topView]];
    [self.view addSubview:[self imageClassTableView]];
    [self getAllImageClassData];
}

#pragma mark - topView

-(UIView*)topView
{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
        _topView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(64, 20, self.view.frame.size.width - 64*2, 44)];
        titleLab.font = [UIFont boldSystemFontOfSize:17];
        titleLab.textColor = [UIColor blackColor];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = self.title;
        [_topView addSubview:titleLab];
        
        UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(self.view.frame.size.width - 64, 20, 64, 44);
        [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:21/255.0f green:126/255.0f blue:251/255.0f alpha:1] forState:UIControlStateNormal];
        rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:rightBtn];
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
        _imageClassTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) style:UITableViewStylePlain];
        _imageClassTableView.delegate = self;
        _imageClassTableView.dataSource = self;
        _imageClassTableView.showsVerticalScrollIndicator = NO;
        _imageClassTableView.tableFooterView = [UIView new];
        _imageClassTableView.rowHeight = ROW_HEIGHT;
        _imageClassTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
        
        UIImageView * line = [[UIImageView alloc]initWithFrame:CGRectMake(ROW_HEIGHT+ROW_HEIGHT/3, ROW_HEIGHT-0.3, self.view.frame.size.width-(ROW_HEIGHT+ROW_HEIGHT/3), 0.3)];
        line.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
        [cell addSubview:line];
    }
    
    NSDictionary * dic = self.imageClassArray[indexPath.row];
    
    cell.exampleImageView.frame = CGRectMake(ROW_HEIGHT/3, 3, ROW_HEIGHT-6, ROW_HEIGHT-6);
    cell.exampleImageView.image = dic[@"album_example_image"];
    
    cell.titleLab.frame = CGRectMake(CGRectGetMaxX(cell.exampleImageView.frame)+ROW_HEIGHT/3, 0, 0, 0);
    cell.titleLab.text = dic[@"album_name"];
    [cell.titleLab sizeToFit];
    CGPoint titleLabCenter = cell.titleLab.center;
    titleLabCenter.y = cell.exampleImageView.center.y;
    cell.titleLab.center = titleLabCenter;
    
    cell.countLab.frame = CGRectMake(CGRectGetMaxX(cell.titleLab.frame)+5, 0, 0, 0);
    cell.countLab.text = [NSString stringWithFormat:@"(%@)",dic[@"album_image_count"]];
    [cell.countLab sizeToFit];
    CGPoint countLabCenter = cell.countLab.center;
    countLabCenter.y = cell.exampleImageView.center.y;
    cell.countLab.center = countLabCenter;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BKImagePickerViewController * imageVC = [[BKImagePickerViewController alloc]init];
    
    NSDictionary * dic = self.imageClassArray[indexPath.row];
    imageVC.title = dic[@"album_name"];
    imageVC.select_imageArray = [NSMutableArray arrayWithArray:self.select_imageArray];
    imageVC.max_select = self.max_select;
    imageVC.photoType = self.photoType;
    
    [self.navigationController pushViewController:imageVC animated:YES];
}

@end
