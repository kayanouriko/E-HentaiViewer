//
//  QJInfoThumbCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QJTableViewCell.h"

@class QJGalleryItem;

@interface QJInfoThumbCell : QJTableViewCell

- (void)refreshUI:(QJGalleryItem *)item;

@end
