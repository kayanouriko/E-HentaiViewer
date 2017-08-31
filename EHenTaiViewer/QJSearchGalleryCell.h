//
//  QJSearchGalleryCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/2.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJListItem;

@protocol QJSearchGalleryCellDelagate <NSObject>

@optional
- (void)didClickOneTopGalleryWithItem:(QJListItem *)item;

@end

@interface QJSearchGalleryCell : UITableViewCell

@property (weak, nonatomic) id<QJSearchGalleryCellDelagate>delegate;

- (void)refrshUI:(NSArray<QJListItem *> *)array;

@end
