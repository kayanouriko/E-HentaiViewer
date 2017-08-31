//
//  QJSettingModel.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/28.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSettingModel.h"

@implementation QJSettingModel

+ (QJSettingModel *)creatModelWithDict:(NSDictionary *)dict {
    QJSettingModel *model = [QJSettingModel new];
    [model setValuesForKeysWithDictionary:dict];
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.value = @"";
    }
    return self;
}

@end
