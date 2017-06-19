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

@end
