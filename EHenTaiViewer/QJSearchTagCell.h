//
//  QJSearchTagCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/7/31.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tag;

@interface QJSearchTagCell : UITableViewCell

- (void)refreshUI:(Tag *)tag searchKey:(NSString *)searchKey;

@end
