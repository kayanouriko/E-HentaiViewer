//
//  QJSettingModel.h
//  EHenTaiViewer
//
//  Created by QinJ on 2017/8/28.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QJSettingModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *subTitleSelected;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *type;

+ (QJSettingModel *)creatModelWithDict:(NSDictionary *)dict;

@end
