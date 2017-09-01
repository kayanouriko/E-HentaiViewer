//
//  QJSettingItem.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJSettingItem.h"
#import "TFHpple.h"
#import "NSString+StringHeight.h"

@implementation QJSettingLanguageCheckBoxItem

+ (QJSettingLanguageCheckBoxItem *)creatModelWithHpple:(TFHppleElement *)hpple {
    QJSettingLanguageCheckBoxItem *model = [QJSettingLanguageCheckBoxItem new];
    hpple = [hpple searchWithXPathQuery:@"//input"].firstObject;
    if ([hpple.attributes.allKeys containsObject:@"name"]) {
        model.name = hpple.attributes[@"name"];
    }
    model.checked = [hpple.attributes.allKeys containsObject:@"checked"];
    if ([model.name isEqualToString:@"xl_0"] && NSObjForKey(@"xl_0") && [NSObjForKey(@"xl_0") isEqualToString:@"on"]) {
        model.checked = YES;
    }
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"";
        self.checked = NO;
    }
    return self;
}

@end

@implementation QJSettingLanguageItem

+ (QJSettingLanguageItem *)creatModelWithHpple:(TFHppleElement *)hpple {
    QJSettingLanguageItem *model = [QJSettingLanguageItem new];
    NSArray *checkboxs = [hpple searchWithXPathQuery:@"//td"];
    NSMutableArray *models = [NSMutableArray new];
    for (NSInteger i = 0; i < checkboxs.count; i++) {
        TFHppleElement *checkboxElement = checkboxs[i];
        if (i) {
            QJSettingLanguageCheckBoxItem *subModel = [QJSettingLanguageCheckBoxItem creatModelWithHpple:checkboxElement];
            [models addObject:subModel];
        }
        else {
            model.name = checkboxElement.text;
        }
    }
    model.models = models;
    return model;
}

@end

@implementation QJSettingCheckboxItem

+ (QJSettingCheckboxItem *)creatModelWithLabel:(TFHppleElement *)labelElement input:(TFHppleElement *)inputElement {
    QJSettingCheckboxItem *model = [QJSettingCheckboxItem new];
    if ([labelElement.attributes.allKeys containsObject:@"alt"]) {
        model.title = labelElement.attributes[@"alt"];
    }
    else {
        model.title = labelElement.text;
    }
    model.name = inputElement.attributes[@"name"];
    model.checked = [inputElement.attributes.allKeys containsObject:@"checked"];
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"";
        self.checked = NO;
    }
    return self;
}

@end

@implementation QJSettingItem

+ (QJSettingItem *)creatModelWithHpple:(TFHppleElement *)hpple {
    QJSettingItem *model = [QJSettingItem new];
    TFHppleElement *text = [hpple searchWithXPathQuery:@"//p"].firstObject;
    model.name = text.text;
    if ([model.name containsString:@"If you wish to hide galleries in certain languages from the gallery list and searches"]) {
        //排除语言
        model.name = @"排除语言";
        NSArray *languages = [hpple searchWithXPathQuery:@"//tr"];
        NSMutableArray *subModels = [NSMutableArray new];
        for (NSInteger i = 0; i < languages.count; i++) {
            if (i > 0) {
                TFHppleElement *languageElement = languages[i];
                QJSettingLanguageItem *subModel = [QJSettingLanguageItem creatModelWithHpple:languageElement];
                [subModels addObject:subModel];
            }
        }
        model.subModels = subModels;
    }
    else if ([model.name containsString:@"What categories would you like to view as default on the front page"]) {
        //主页分类显示
        model.name = @"主页分类显示";
        NSArray *inputs = [hpple searchWithXPathQuery:@"//input"];
        NSArray *imgs = [hpple searchWithXPathQuery:@"//label//img"];
        NSMutableArray *subModels = [NSMutableArray new];
        for (NSInteger i = 0; i < inputs.count; i++) {
            QJSettingCheckboxItem *subModel = [QJSettingCheckboxItem creatModelWithLabel:imgs[i] input:inputs[i]];
            [subModels addObject:subModel];
        }
        model.subModels = subModels;
    }
    else if ([model.name containsString:@"If you want to exclude certain namespaces from a default tag search"]) {
        //排除标签组
        model.name = @"排除标签组";
        NSArray *inputs = [hpple searchWithXPathQuery:@"//input"];
        NSArray *imgs = [hpple searchWithXPathQuery:@"//label"];
        NSMutableArray *subModels = [NSMutableArray new];
        for (NSInteger i = 0; i < inputs.count; i++) {
            QJSettingCheckboxItem *subModel = [QJSettingCheckboxItem creatModelWithLabel:imgs[i] input:inputs[i]];
            [subModels addObject:subModel];
        }
        model.subModels = subModels;
    }
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"";
        self.subModels = [NSArray new];
    }
    return self;
}

@end
