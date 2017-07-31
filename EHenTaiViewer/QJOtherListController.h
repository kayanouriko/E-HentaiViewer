//
//  QJOtherListController.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/1.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJViewController.h"

typedef NS_ENUM(NSInteger, QJOtherListControllerType) {
    QJOtherListControllerTypePerson,//上传人
    QJOtherListControllerTypeTag,//标签
    QJOtherListControllerTypeCatgoery,//分类
    QJOtherListControllerTypeTagIncomplete,//不完整的标签
};

@interface QJOtherListController : QJViewController

@property (nonatomic, assign) QJOtherListControllerType type;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *titleName;

@end
