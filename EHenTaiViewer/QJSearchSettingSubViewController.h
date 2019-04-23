//
//  QJSearchSettingSubViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/3/30.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QJSearchSettingSubViewControllerType) {
    QJSearchSettingSubViewControllerTypeNormal,
    QJSearchSettingSubViewControllerTypeSift,
};

@interface QJSearchSettingSubViewController : QJViewController

@property (assign, nonatomic) QJSearchSettingSubViewControllerType type;
@property (strong, nonatomic) NSArray *settings; // 高级筛选

- (NSArray *)saveAndGetSettingInfo;

@end

NS_ASSUME_NONNULL_END
