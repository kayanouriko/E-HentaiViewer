//
//  QJTagModel.h
//  EHenTaiViewer
//
//  Created by QinJ on 2019/4/26.
//  Copyright © 2019 kayanouriko. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QJTagModel : NSObject

/**
 @"usertag": usertag,
 @"name": name,
 @"group": group,
 @"color": color,
 @"backgroundColor": backgroundColor,
 @"watched": watched,
 @"hidden": hidden,
 @"none": none,
 @"weight": weight,
 */

@property (strong, nonatomic) NSString *usertag; // id
@property (strong, nonatomic) NSString *group;   // 所属分组
@property (strong, nonatomic) NSString *name;    // 标签名字
@property (strong, nonatomic) NSString *name_ch; // 标签名字_中文
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) NSString *backgroundColor;
@property (assign, nonatomic) BOOL isWatched;
@property (assign, nonatomic) BOOL isHidden;
@property (assign, nonatomic) BOOL isNone;
@property (strong, nonatomic) NSString *weight;

// 从api获取的model
+ (QJTagModel *)creatModelWithUserTag:(NSString *)usertag dict:(NSDictionary *)dict;
// 从解析的html回调获取的model
+ (QJTagModel *)creatModelWithDict:(NSDictionary *)dict;

@end

@interface QJTagListModel : NSObject
/**
 @"apiuid": apiuid,
 @"apikey": apikey,
 @"tagset_name": tagset_name,
 @"usertags": usertags,
 */
@property (strong, nonatomic) NSString *apiuid;
@property (strong, nonatomic) NSString *apikey;
@property (strong, nonatomic) NSString *tagset_name;
@property (strong, nonatomic) NSArray<QJTagModel *> *tags;

+ (QJTagListModel *)creatModelWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
