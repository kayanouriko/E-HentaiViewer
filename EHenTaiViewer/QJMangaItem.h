//
//  QJMangaItem.h
//  testImageView
//
//  Created by QinJ on 2017/5/4.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJBigImageItem;

@protocol QJMangaItemDelagate <NSObject>

@optional
- (void)changeWillBegin;
- (void)tapInWebView;
- (void)nextPage;
- (void)forwardPage;

@end

@interface QJMangaItem : UICollectionViewCell

@property (weak, nonatomic) id<QJMangaItemDelagate>delegate;

- (void)refreshItem:(QJBigImageItem *)item;

@end
