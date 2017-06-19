//
//  QJListCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJListItem;

@interface QJListCell : UITableViewCell

- (void)refreshUI:(QJListItem *)item;

@end
