//
//  QJNewBrowerImageCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2018/4/6.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJMangaImageModel;

@protocol QJNewBrowerImageCellDelegate <NSObject>

@optional
- (void)collectionViewShouldRefreshWithModel:(QJMangaImageModel *)model;
- (void)scrollViewInCellWillBeginDragging;

@end

@interface QJNewBrowerImageCell : UICollectionViewCell

/** QJNewBrowerImageCell Delegate */
@property (nonatomic, weak) id<QJNewBrowerImageCellDelegate> delegate;
/** model */
@property (nonatomic, strong) QJMangaImageModel *model;

@end
