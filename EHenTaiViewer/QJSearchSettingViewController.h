//
//  QJSearchSettingViewController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/3/30.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class QJSearchSettingViewController;

@protocol QJSearchSettingViewControllerDelegate <NSObject>

@optional
- (void)settingController:(QJSearchSettingViewController *)settingController changeSiftSettingWithArr:(NSArray *)settings;

@end

@interface QJSearchSettingViewController : QJViewController

@property (weak, nonatomic) id<QJSearchSettingViewControllerDelegate>delegate;
@property (strong, nonatomic) NSArray *settings; // 高级筛选

@end

NS_ASSUME_NONNULL_END
