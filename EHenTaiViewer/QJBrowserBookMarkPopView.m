//
//  QJBrowserBookMarkPopView.m
//  AnimatedTransitioningDemo
//
//  Created by zedmacbook on 2018/7/24.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJBrowserBookMarkPopView.h"
#import "QJBrowserBookMarkPopViewCell.h"
#import "QJMangaImageModel.h"
#import "QJMangaManager.h"
#import "QJBrowerCollectManager.h"
#import "GalleryPage+CoreDataClass.h"

@interface QJBrowserBookMarkPopView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeightLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segCenterLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonCenterLine;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (nonatomic, strong) QJMangaManager *manager;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isCollectMode; // 书签模式
@property (nonatomic, strong) NSString *gid;
@property (nonatomic, strong) NSArray *datas;

@end

@implementation QJBrowserBookMarkPopView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.datas = @[];
    
    self.alpha = 0;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJBrowserBookMarkPopViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJBrowserBookMarkPopViewCell class])];
}

+ (QJBrowserBookMarkPopView *)creatPopViewWithDelegate:(id<QJBrowserBookMarkPopViewDelegate>)theDelagate manager:(QJMangaManager *)manager gid:(NSString *)gid {
    QJBrowserBookMarkPopView *popView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([QJBrowserBookMarkPopView class]) owner:self options:nil].firstObject;
    popView.delegate = theDelagate;
    popView.manager = manager;
    popView.gid = gid;
    return popView;
}

#pragma mark - View Action
- (void)showWithIndexPath:(NSIndexPath *)indexPath {
    [self settingContentBeforeShowWithIndexPath:indexPath];
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1.f;
    }];
}

- (void)showWithoutAnimateWithIndexPath:(NSIndexPath *)indexPath {
    [self settingContentBeforeShowWithIndexPath:indexPath];
    self.alpha = 1.f;
}

- (void)settingContentBeforeShowWithIndexPath:(NSIndexPath *)indexPath {
    if (isAppOrientationPortrait) {
        self.navigationBarHeightLine.constant = UINavigationBarHeight();
        self.segCenterLine.constant = UIStatusBarHeight() / 2;
        self.buttonCenterLine.constant = UIStatusBarHeight() / 2;
    } else {
        self.navigationBarHeightLine.constant = UISearchBarHeight();
        self.segCenterLine.constant = 0;
        self.buttonCenterLine.constant = 0;
    }
    self.showed = YES;
    self.isCollectMode = NO;
    self.segControl.selectedSegmentIndex = 0;
    
    self.frame = [UIScreen mainScreen].bounds;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    self.datas = self.manager.photos;
    [self.collectionView reloadData];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
}

- (void)close {
    self.showed = NO;
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)closeWithoutAnimate {
    self.showed = NO;
    [self removeFromSuperview];
    self.alpha = 0;
}

- (void)changeFrameIfNeedWithIndexPath:(NSIndexPath *)indexPath {
    [self closeWithoutAnimate];
    [self showWithoutAnimateWithIndexPath:indexPath];
}

#pragma mark - Control Action
- (IBAction)cannelAction:(UIButton *)sender {
    [self close];
}

- (IBAction)segValueChangeAction:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: {
            self.isCollectMode = NO;
            self.datas = self.manager.photos;
            [self.collectionView reloadData];
            [self.collectionView selectItemAtIndexPath:self.indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
        }
            break;
        case 1: {
            // 先记录当前的indexPath
            self.isCollectMode = YES;
            self.indexPath = [self.collectionView indexPathForCell:[self.collectionView visibleCells].firstObject];
            self.datas = [QJBrowerCollectManager getAllCollectPagesWithGid:self.gid];
            [self.collectionView reloadData];
            if (self.datas.count) {
                [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionTop];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - CollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat count = isAppOrientationPortrait ? 3.f : 4.f;
    CGFloat width = (UIScreenWidth() - 15 * (count + 1)) / count;
    return CGSizeMake(width, width * 4 / 3.f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QJBrowserBookMarkPopViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJBrowserBookMarkPopViewCell class]) forIndexPath:indexPath];
    if (self.isCollectMode) {
        cell.galleryPage = self.datas[indexPath.row];
    }
    else {
        cell.model = self.datas[indexPath.row];
        if (![self.manager.photos[indexPath.row] isParser]) {
            [self.manager startImageParserForModel:self.manager.photos[indexPath.row]];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self close];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectImageWithIndex:)]) {
        NSInteger index = 0;
        if (self.isCollectMode) {
            GalleryPage *galleryPage = self.datas[indexPath.row];
            index = galleryPage.page;
        } else {
            index = indexPath.row;
        }
        [self.delegate didSelectImageWithIndex:index];
    }
}


@end
