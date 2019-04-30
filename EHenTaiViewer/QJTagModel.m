//
//  QJTagModel.m
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import "QJTagModel.h"
#import "NSString+StringHeight.h"

@implementation QJTagModel

+ (QJTagModel *)creatModelWithUserTag:(NSString *)usertag dict:(NSDictionary *)dict {
    QJTagModel *model = [QJTagModel new];
    model.usertag = usertag;
    model.group = isnull(@"ns", dict);
    model.name = isnull(@"tn", dict);
    return model;
}

+ (QJTagModel *)creatModelWithDict:(NSDictionary *)dict {
    QJTagModel *model = [QJTagModel new];
    [model setValuesForKeysWithDictionary:dict];
    return model;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.usertag = @"";
        self.group = @"";
        self.name = @"";
        self.name_ch = @"";
        self.color = @"#f1f1f1";
        self.backgroundColor = @"#3377FF";
        self.isWatched = NO;
        self.isHidden = NO;
        self.isNone = YES;
        self.weight = @"10";
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"watched"]) {
        self.isWatched = [value boolValue];
    }
    else if ([key isEqualToString:@"hidden"]) {
        self.isHidden = [value boolValue];
    }
    else if ([key isEqualToString:@"none"]) {
        self.isNone = [value boolValue];
    }
}

#pragma mark - Setter
- (void)setName:(NSString *)name {
    _name = name;
    // 通知获取中文标签
    self.name_ch = [name getCHTagName];
}

@end

@implementation QJTagListModel

+ (QJTagListModel *)creatModelWithDict:(NSDictionary *)dict {
    QJTagListModel *model = [QJTagListModel new];
    [model setValuesForKeysWithDictionary:dict];
    return model;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"usertags"]) {
        NSMutableArray *datas = [NSMutableArray new];
        NSArray *array = value;
        for (NSDictionary *dic in array) {
            QJTagModel *model = [QJTagModel creatModelWithDict:dic];
            [datas addObject:model];
        }
        self.tags = [datas copy];
    }
}

@end
