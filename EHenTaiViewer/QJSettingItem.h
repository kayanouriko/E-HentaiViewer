//
//  QJSettingItem.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TFHppleElement;

@interface QJSettingLanguageCheckBoxItem : NSObject

@property (nonatomic, strong) NSString *name;//名字
@property (nonatomic, assign, getter=isChecked) BOOL checked;//是否被选中

+ (QJSettingLanguageCheckBoxItem *)creatModelWithHpple:(TFHppleElement *)hpple;

@end

@interface QJSettingLanguageItem : NSObject

@property (nonatomic, strong) NSString *name;//语言名字
@property (nonatomic, strong) NSArray<QJSettingLanguageCheckBoxItem *> *models;//是否被选中

+ (QJSettingLanguageItem *)creatModelWithHpple:(TFHppleElement *)hpple;

@end

@interface QJSettingCheckboxItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign, getter=isChecked) BOOL checked;

+ (QJSettingCheckboxItem *)creatModelWithLabel:(TFHppleElement *)labelElement input:(TFHppleElement *)inputElement;

@end

@interface QJSettingItem : NSObject

@property (nonatomic, strong) NSString *name;//名字
@property (nonatomic, strong) NSArray *subModels;

+ (QJSettingItem *)creatModelWithHpple:(TFHppleElement *)hpple;

@end
