//
//  QJCollectionViewFlowLayout.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/12/15.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJCollectionViewFlowLayout.h"

#define BUBBLE_DIAMETER UIScreenWidth() - 30
#define BUBBLE_PADDING 15

@implementation QJCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 15;
        self.minimumInteritemSpacing = 0;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    //是否为下一item的方向
    BOOL isUp = proposedContentOffset.x > self.collectionView.contentOffset.x;
    
    CGSize size = self.collectionView.frame.size;
    
    // 计算可见区域的面积
    CGRect rect = CGRectMake(proposedContentOffset.x, proposedContentOffset.y, size.width, size.height);
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    // 计算 CollectionView 中点值
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    // 标记 cell 的中点与 UICollectionView 中点最小的间距
    CGFloat minDetal = 0;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (centerX == attrs.center.x) {
            //这种可能是最终位置本身就是中心,这时候不需要调整
            minDetal = 0;
            break;
        }
        CGFloat temp = attrs.center.x - centerX;
        if (isUp && temp > 0) {
            if (minDetal == 0 || minDetal > temp) {
                minDetal = temp;
            }
        }
        else if (!isUp && temp < 0){
            if (minDetal == 0 || minDetal < temp) {
                minDetal = temp;
            }
        }
    }
    return CGPointMake(proposedContentOffset.x + minDetal, proposedContentOffset.y);
}

@end
