//
//  QJSettingCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QJSettingCellMode) {
    QJSettingCellModeNormal,//正常
    QJSettingCellModeSwitch,//开关
};

@interface QJSettingCell : UITableViewCell

- (void)refreshUI:(NSArray *)array;

@end
