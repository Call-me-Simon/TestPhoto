//
//  SelectPhotosViewController.m
//  TestPhoto
//
//  Created by Simon on 2018/1/10.
//  Copyright © 2018年 sunshixiang. All rights reserved.
//

#import "SelectPhotosViewController.h"
#import "PhotoCollectionViewCell.h"
#import <Masonry.h>
#import <Photos/Photos.h>

#define KHeaterCollectionViewCellWidth(section) (kScreenWidth - (section-1+2)*kFitWidth(10))/(section)
#define kScreenWidth [UIScreen  mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kFitHeight(height) (height)/(667.0 - 64) * (kScreenHeight - 64)
#define kFitWidth(width) (width)/375.0 * kScreenWidth
#define KModelCollectionViewCellIdentifier @"modelCollectionViewCellIdentifier"

@interface SelectPhotosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *showPhotoCollectionView;

@property (nonatomic, strong) NSMutableArray *photoArray;

@end

@implementation SelectPhotosViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getOriginalImages];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photoArray = @[].mutableCopy;
    [self initNav];
    if (!_showPhotoCollectionView) {
        [self.view addSubview:self.showPhotoCollectionView];
    }
    // Do any additional setup after loading the view.
}

-(void)initNav
{
    
    // 在主线程异步加载，使下面的方法最后执行，防止其他的控件挡住了导航栏
    dispatch_async(dispatch_get_main_queue(), ^{
        // 隐藏系统导航栏
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        // 创建假的导航栏
        UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
        navView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1.0f];
        [self.view addSubview:navView];
        // 创建导航栏左按钮
        UIButton *left= [UIButton buttonWithType:UIButtonTypeSystem];
        left.frame = CGRectMake(20, 27, 30, 30);
        [left setBackgroundImage:[UIImage imageNamed:@"Numberback_highlight"] forState:UIControlStateNormal];
        [left addTarget:self action:@selector(preAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:left];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.text = @"添加智能图标";
        titleLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0f];
        titleLabel.frame = CGRectMake(left.frame.origin.x + left.frame.size.width + 20, 20, 150, 44);
        [navView addSubview:titleLabel];
    });
}

-(void)preAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getOriginalImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获得所有的自定义相簿
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        // 遍历所有的自定义相簿
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:YES];
        }
        
        // 获得相机胶卷
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        // 遍历相机胶卷,获取大图
        [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
    });
}

- (void)getThumbnailImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 获得所有的自定义相簿
        PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        // 遍历所有的自定义相簿
        for (PHAssetCollection *assetCollection in assetCollections) {
            [self enumerateAssetsInAssetCollection:assetCollection original:NO];
        }
        // 获得相机胶卷
        PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
        [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
    });
}

/**
 *  遍历相簿中的全部图片
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    for (PHAsset *asset in assets) {
        // 是否要原图
        CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
        
        // 从asset中获得图片
        __weak typeof(self) weakSelf = self;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"%@", result);
            original ? [weakSelf.photoArray addObject:result] : [weakSelf.photoArray addObject:result];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.showPhotoCollectionView reloadData];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UICollectionView *)showPhotoCollectionView
{
    if (!_showPhotoCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(KHeaterCollectionViewCellWidth(4.0), KHeaterCollectionViewCellWidth(4.0));
        _showPhotoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64) collectionViewLayout:flowLayout];
        _showPhotoCollectionView.backgroundColor = [UIColor whiteColor];
        _showPhotoCollectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
        _showPhotoCollectionView.delegate = self;
        _showPhotoCollectionView.dataSource = self;
        _showPhotoCollectionView.allowsSelection = YES;
        [_showPhotoCollectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:KModelCollectionViewCellIdentifier];
    }
    return _showPhotoCollectionView;
}

#pragma mark --- UICollectionViewDelegate && UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photoArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCollectionViewCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:KModelCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.iconImageView.image = _photoArray[indexPath.item];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_photoArray[indexPath.item]) {
        self.selectPhoto(_photoArray[indexPath.item]);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
