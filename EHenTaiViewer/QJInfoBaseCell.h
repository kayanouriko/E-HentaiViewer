//
//  QJInfoBaseCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QJTableViewCell.h"

@class QJGalleryItem;
@class QJListItem;

@interface QJInfoBaseCell : QJTableViewCell

- (void)refreshUI:(QJGalleryItem *)item listItem:(QJListItem *)listItem;

@end
