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

@interface QJBrowserBookMarkPopView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarHeightLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segCenterLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonCenterLine;
@property (nonatomic, strong) QJMangaManager *manager;

@end

@implementation QJBrowserBookMarkPopView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.alpha = 0;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJBrowserBookMarkPopViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJBrowserBookMarkPopViewCell class])];
}

+ (QJBrowserBookMarkPopView *)creatPopViewWithDelegate:(id<QJBrowserBookMarkPopViewDelegate>)theDelagate manager:(QJMangaManager *)manager {
    QJBrowserBookMarkPopView *popView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([QJBrowserBookMarkPopView class]) owner:self options:nil].firstObject;
    popView.delegate = theDelagate;
    popView.manager = manager;
    return popView;
}

#pragma mark - View Action
- (void)show {
    [self initContentBeforeShow];
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1.f;
    }];
}

- (void)showWithoutAnimate {
    [self initContentBeforeShow];
    self.alpha = 1.f;
}

- (void)initContentBeforeShow {
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
    self.frame = [UIScreen mainScreen].bounds;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [self.collectionView reloadData];
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

- (void)changeFrameIfNeed {
    [self closeWithoutAnimate];
    [self showWithoutAnimate];
}

#pragma mark - Control Action
- (IBAction)cannelAction:(UIButton *)sender {
    [self close];
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
    return self.manager.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QJBrowserBookMarkPopViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJBrowserBookMarkPopViewCell class]) forIndexPath:indexPath];
    cell.model = self.manager.photos[indexPath.row];
    if (![self.manager.photos[indexPath.row] isParser]) {
        [self.manager startImageParserForModel:self.manager.photos[indexPath.row]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self close];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectImageWithIndex:)]) {
        [self.delegate didSelectImageWithIndex:indexPath.row];
    }
}


@end
