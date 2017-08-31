//
//  QJSearchUploaderCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/2.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJToplistUploaderItem;

@interface QJSearchUploaderCell : UITableViewCell

- (void)refrshUI:(NSArray<QJToplistUploaderItem *> *)upladers;

@end
