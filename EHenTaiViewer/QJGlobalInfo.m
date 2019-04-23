//
//  QJGlobalInfo.m
//  wikiForMHXX
//
//  Created by QinJ on 2017/4/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJGlobalInfo.h"

static NSString * const ExHentaiOrientation = @"ExHentaiOrientation";
static NSString * const ExHentaiScrollDiretion = @"ExHentaiScrollDiretion";
static NSString * const ExHentaiStatus = @"ExHentaiStatus";
static NSString * const ExHentaiWatchMode = @"ExHentaiWatchMode";
static NSString * const ExHentaiProtectMode = @"ExHentaiProtectMode";
static NSString * const ExHentaiTagCnMode = @"ExHentaiTagCnMode";
static NSString * const ExHentaiTitleJnMode = @"ExHentaiTitleJnMode";
static NSString * const ExHentaiTabbarItems = @"ExHentaiTabbarItems";
static NSString * const ExHentaiSearchSettingArr = @"ExHentaiSearchSettingArr";
static NSString * const ExHentaiSmallStar = @"ExHentaiSmallStar";

static NSString * const ExHentaiUserName = @"loginName";
static NSString * const ExHentaiUserDes = @"ExHentaiUserDes";
static NSString * const ExHentaiUserImageUrl = @"ExHentaiUserImageUrl";


@interface QJGlobalInfo ()

@property (nonatomic, strong) NSMutableDictionary *attrDict;

@end

@implementation QJGlobalInfo

+ (instancetype)sharedInstance {
    static QJGlobalInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [QJGlobalInfo new];
    });
    return sharedInstance;
}

- (void)putAttribute:(NSString*)key value:(id)value{
    if (value == nil) {
        value = [NSNull null];
    }
    [self.attrDict setObject:value forKey:key];
}

- (id)getAttribute:(NSString*)key {
    return [self.attrDict valueForKey:key];
}

#pragma mark - 全局配置
+ (NSArray<NSString *> *)customTabbarItems {
    NSArray *array = NSObjForKey(ExHentaiTabbarItems);
    if (nil == array || array.count != 4) {
        [self setCustomTabbarItems:@[@"当前热门", @"画廊", @"收藏", @"设置"]];
    }
    NSArray<NSString *> *customTabbarItems = NSObjForKey(ExHentaiTabbarItems);
    return customTabbarItems;
}

+ (void)setCustomTabbarItems:(NSArray<NSString *> *)customTabbarItems {
    NSObjSetForKey(ExHentaiTabbarItems, customTabbarItems);
    NSObjSynchronize();
}

+ (UIInterfaceOrientationMask)customOrientation {
    // 默认跟随系统
    if (nil == NSObjForKey(ExHentaiOrientation)) {
        [self setCustomOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
    }
    UIInterfaceOrientationMask customOrientation = [NSObjForKey(ExHentaiOrientation) integerValue];
    return customOrientation;
}

+ (void)setCustomOrientation:(UIInterfaceOrientationMask)customOrientation {
    NSObjSetForKey(ExHentaiOrientation, @(customOrientation));
    NSObjSynchronize();
}

+ (UICollectionViewScrollDirection)customScrollDiretion {
    if (nil == NSObjForKey(ExHentaiScrollDiretion)) {
        [self setCustomScrollDiretion:UICollectionViewScrollDirectionHorizontal];
    }
    UICollectionViewScrollDirection customScrollDiretion = [NSObjForKey(ExHentaiScrollDiretion) integerValue];
    return customScrollDiretion;
}

+ (void)setCustomScrollDiretion:(UICollectionViewScrollDirection)customScrollDiretion {
    NSObjSetForKey(ExHentaiScrollDiretion, @(customScrollDiretion));
    NSObjSynchronize();
}

+ (BOOL)isExHentaiStatus {
    if (nil == NSObjForKey(ExHentaiStatus)) {
        [self setExHentaiStatus:NO];
    }
    return [NSObjForKey(ExHentaiStatus) boolValue];
}

+ (void)setExHentaiStatus:(BOOL)isExHentaiStatus {
    NSObjSetForKey(ExHentaiStatus, @(isExHentaiStatus));
    NSObjSynchronize();
}

+ (BOOL)isExHentaiWatchMode {
    if (nil == NSObjForKey(ExHentaiWatchMode)) {
        [self setExHentaiWatchMode:YES];
    }
    return [NSObjForKey(ExHentaiWatchMode) boolValue];
}

+ (void)setExHentaiWatchMode:(BOOL)isExHentaiWatchMode {
    NSObjSetForKey(ExHentaiWatchMode, @(isExHentaiWatchMode));
    NSObjSynchronize();
}

+ (BOOL)isExHentaiProtectMode {
    if (nil == NSObjForKey(ExHentaiProtectMode)) {
        [self setExHentaiProtectMode:NO];
    }
    return [NSObjForKey(ExHentaiProtectMode) boolValue];
}

+ (void)setExHentaiProtectMode:(BOOL)isExHentaiProtectMode {
    NSObjSetForKey(ExHentaiProtectMode, @(isExHentaiProtectMode));
    NSObjSynchronize();
}

+ (BOOL)isExHentaiTagCnMode {
    if (nil == NSObjForKey(ExHentaiTagCnMode)) {
        [self setExHentaiTagCnMode:NO];
    }
    return [NSObjForKey(ExHentaiTagCnMode) boolValue];
}

+ (void)setExHentaiTagCnMode:(BOOL)isExHentaiTagCnMode {
    NSObjSetForKey(ExHentaiTagCnMode, @(isExHentaiTagCnMode));
    NSObjSynchronize();
}

+ (BOOL)isExHentaiTitleJnMode {
    if (nil == NSObjForKey(ExHentaiTitleJnMode)) {
        [self setExHentaiTitleJnMode:NO];
    }
    return [NSObjForKey(ExHentaiTitleJnMode) boolValue];
}

+ (void)setExHentaiTitleJnMode:(BOOL)isExHentaiTitleJnMode {
    NSObjSetForKey(ExHentaiTitleJnMode, @(isExHentaiTitleJnMode));
    NSObjSynchronize();
}

+ (NSArray *)getExHentaiSearchSettingArr {
    if (nil == NSObjForKey(ExHentaiSearchSettingArr)) {
        // 初始化
        [self setExHentaiSearchSettingArr:[self p_getFristSettingArr]];
    }
    NSArray *array = NSObjForKey(ExHentaiSearchSettingArr);
    if (array.count != 19) {
        // 初始化
        [self setExHentaiSearchSettingArr:[self p_getFristSettingArr]];
    }
    return NSObjForKey(ExHentaiSearchSettingArr);
}

+ (NSArray *)p_getFristSettingArr {
    NSMutableArray *arr = [NSMutableArray new];
    for (NSInteger i = 0; i <= 18; i++) {
        if (i < 12) {
            [arr addObject:@(1)];
        }
        else {
            [arr addObject:@(0)];
        }
    }
    return arr.copy;
}

+ (void)setExHentaiSearchSettingArr:(NSArray *)searchSettingArr {
    NSObjSetForKey(ExHentaiSearchSettingArr, searchSettingArr);
    NSObjSynchronize();
}

+ (NSInteger)getExHentaiSmallStar {
    if (nil == NSObjForKey(ExHentaiSmallStar)) {
        [self setExHentaiSmallStar:2];
    }
    return [NSObjForKey(ExHentaiSmallStar) integerValue];
}

+ (void)setExHentaiSmallStar:(NSInteger)smallStar {
    NSObjSetForKey(ExHentaiSmallStar, @(smallStar));
    NSObjSynchronize();
}

+ (NSString *)getExHentaiUserName {
    if (nil == NSObjForKey(ExHentaiUserName)) {
        [self setExHentaiUserName:@"未登录"];
    }
    return NSObjForKey(ExHentaiUserName);
}

+ (void)setExHentaiUserName:(NSString *)userName {
    NSObjSetForKey(ExHentaiUserName, userName);
    NSObjSynchronize();
}

+ (NSString *)getExHentaiUserDes {
    if (nil == NSObjForKey(ExHentaiUserDes)) {
        [self setExHentaiUserDes:@"No Information"];
    }
    return NSObjForKey(ExHentaiUserDes);
}

+ (void)setExHentaiUserDes:(NSString *)userDes {
    NSObjSetForKey(ExHentaiUserDes, userDes);
    NSObjSynchronize();
}

+ (NSString *)getExHentaiUserImageUrl {
    if (nil == NSObjForKey(ExHentaiUserImageUrl)) {
        [self setExHentaiUserImageUrl:@"LOGO"];
    }
    return NSObjForKey(ExHentaiUserImageUrl);
}

+ (void)setExHentaiUserImageUrl:(NSString *)userImageUrl {
    NSObjSetForKey(ExHentaiUserImageUrl, userImageUrl);
    NSObjSynchronize();
}

#pragma mark -懒加载
- (NSMutableDictionary *)attrDict {
    if (nil == _attrDict) {
        _attrDict = [NSMutableDictionary new];
    }
    return _attrDict;
}

@end
