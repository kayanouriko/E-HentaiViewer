//
//  QJStarViewCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJGalleryItem;
@class QJListItem;

@interface QJStarViewCell : UITableViewCell

- (void)refreshUI:(QJGalleryItem *)item listItem:(QJListItem *)listItem;

@end
