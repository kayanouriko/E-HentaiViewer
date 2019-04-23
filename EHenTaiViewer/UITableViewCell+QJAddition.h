//
//  UITableViewCell+QJAddition.h
//  bangumitv
//
//  Created by zedmacbook on 2018/11/5.
//  Copyright © 2018 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (QJAddition)

/// 添加圆角设置
- (void)addSectionCornerRadiusWithIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
