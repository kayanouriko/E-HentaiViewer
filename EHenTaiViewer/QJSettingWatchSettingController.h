//
//  QJSettingWatchSettingController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/16.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

typedef NS_ENUM(NSInteger, QJSettingWatchSettingControllerType) {
    QJSettingWatchSettingControllerTypeEH,//常规设置
    QJSettingWatchSettingControllerTypeHight,//高级设置
    QJSettingWatchSettingControllerTypeSuggest,//建议
    QJSettingWatchSettingControllerTypeAbout, //关于
    QJSettingWatchSettingControllerTypeAboutReference,//参考
    QJSettingWatchSettingControllerTypeAboutFrame,//框架
};

@interface QJSettingWatchSettingController : QJViewController

@property (nonatomic, assign) QJSettingWatchSettingControllerType type;

@end
