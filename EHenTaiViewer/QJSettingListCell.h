//
//  QJSettingListCell.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QJSettingModel;

@protocol QJSettingListCellDelagate <NSObject>

@optional
- (void)valueChangeWithSwitch:(UISwitch *)switchBtn model:(QJSettingModel *)model;

@end

@interface QJSettingListCell : UITableViewCell

@property (weak, nonatomic) id<QJSettingListCellDelagate>delegate;
@property (nonatomic, strong) QJSettingModel *model;

@end
