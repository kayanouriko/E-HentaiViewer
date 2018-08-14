//
//  QJBrowserBookMarkPopViewCell.h
//  AnimatedTransitioningDemo
//
//  Created by zedmacbook on 2018/7/24.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJMangaImageModel, GalleryPage;

@interface QJBrowserBookMarkPopViewCell : UICollectionViewCell

@property (nonatomic, strong) QJMangaImageModel *model;
@property (nonatomic, strong) GalleryPage *galleryPage;

@end
