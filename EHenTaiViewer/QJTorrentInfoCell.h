//
//  QJTorrentInfoCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/9.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJTorrentItem;

@interface QJTorrentInfoCell : UITableViewCell

- (void)refreshUI:(QJTorrentItem *)item;

@end
