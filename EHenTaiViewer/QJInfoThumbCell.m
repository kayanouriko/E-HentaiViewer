//
//  QJInfoThumbCell.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJInfoThumbCell.h"
#import "QJImageCollectionViewCell.h"
#import "QJGalleryItem.h"

@interface QJInfoThumbCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightLine;
@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation QJInfoThumbCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//设置水平滚动
    
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QJImageCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([QJImageCollectionViewCell class])];
    
    CGFloat width = UIScreenWidth() / 2.f > 240 ? 240 : UIScreenWidth() / 2.f;
    self.collectionViewHeightLine.constant = width * 4 / 3 + 20;
}

- (void)refreshUI:(QJGalleryItem *)item {
    [self.datas removeAllObjects];
    [self.datas addObjectsFromArray:item.smallImages];
    [self.collectionView reloadData];
}

#pragma mark -collectionView
- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CGFloat width = UIScreenWidth() / 2.f > 240 ? 240 : UIScreenWidth() / 2.f;
    return CGSizeMake(width , width * 4 / 3);
}
 
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QJImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([QJImageCollectionViewCell class]) forIndexPath:indexPath];
    [cell.thumbImageView yy_setImageWithURL:[NSURL URLWithString:self.datas[indexPath.item]] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionHandleCookies];
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -setter
- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

@end
