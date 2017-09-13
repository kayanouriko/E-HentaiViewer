//
//  QJMangaFlowLayout.m
//  testImageView
//
//  Created by QinJ on 2017/5/4.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJMangaFlowLayout.h"
#import "QJMangaItem.h"

@implementation QJMangaFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)prepareLayout {
    [super prepareLayout];
    //初始化
    self.itemSize = CGSizeMake(UIScreenWidth(), UIScreenHeight() - 20);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = 0;
}
/*
//边界改变时,是否需要重新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

//返回所有cell的布局属性
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [super layoutAttributesForElementsInRect:rect];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    //1.计算scrollview最后停留的范围
    CGRect lastRect ;
    lastRect.origin = proposedContentOffset;
    lastRect.size = self.collectionView.frame.size;
    
    //2.取出这个范围内的所有属性
    NSArray *array = [self layoutAttributesForElementsInRect:lastRect];
    
    //起始的x值，也即默认情况下要停下来的x值
    CGFloat startX = proposedContentOffset.x;
    
    //3.遍历所有的属性
    CGFloat adjustOffsetX = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        CGFloat attrsX = CGRectGetMinX(attrs.frame);
        CGFloat attrsW = CGRectGetWidth(attrs.frame) ;
        
        if (startX - attrsX  < attrsW/2) {
            adjustOffsetX = -(startX - attrsX + 20);
        }else{
            adjustOffsetX = attrsW - (startX - attrsX);
        }
        
        break ;//只循环数组中第一个元素即可，所以直接break了
    }
    return CGPointMake(proposedContentOffset.x + adjustOffsetX, proposedContentOffset.y);
}
*/
@end
