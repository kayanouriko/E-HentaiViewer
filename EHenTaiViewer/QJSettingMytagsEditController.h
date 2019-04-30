//
//  QJSettingMytagsEditController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class QJTagModel;

@interface QJSettingMytagsEditController : QJViewController

@property (strong, nonatomic) NSString *apikey;
@property (strong, nonatomic) NSString *apiuid;
@property (strong, nonatomic) QJTagModel *model;

@end

NS_ASSUME_NONNULL_END
