//
//  QJSearchGalleryCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/2.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSearchGalleryCell.h"
#import "QJSearchGalleryThumbCell.h"
#import "QJListItem.h"

@interface QJSearchGalleryCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeightLine;
@property (nonatomic, strong) NSMutableArray<QJListItem *> *datas;

@end

@implementation QJSearchGalleryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.collection.delegate = self;
    self.collection.dataSource = self;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//设置水平滚动
    
    self.collection.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    self.collection.collectionViewLayout = layout;
    self.collection.backgroundColor = [UIColor clearColor];
    [self.collection registerNib:[UINib nibWithNibName:NSStringFromClass([QJSearchGalleryThumbCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJSearchGalleryThumbCell class])];
    
    CGFloat width = UIScreenWidth() * 2.f / 7.f > 240 ? 240 : UIScreenWidth() * 2.f / 7.f;
    self.collectionHeightLine.constant = width * 4 / 3 + 2;
}

- (void)refrshUI:(NSArray<QJListItem *> *)array {
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:array];
    [self.collection reloadData];
}

#pragma mark -collectionView
- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CGFloat width = UIScreenWidth() * 2.f / 7.f > 240 ? 240 : UIScreenWidth() * 2.f / 7.f;
    return CGSizeMake(width , width * 4 / 3);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QJSearchGalleryThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJSearchGalleryThumbCell class]) forIndexPath:indexPath];
    [cell refrshUI:self.datas[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickOneTopGalleryWithItem:)]) {
        [self.delegate didClickOneTopGalleryWithItem:self.datas[indexPath.item]];
    }
}

#pragma mark -getter
- (NSMutableArray<QJListItem *> *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
