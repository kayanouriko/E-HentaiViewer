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
    if (nil == NSObjForKey(ExHentaiTabbarItems)) {
        [self setCustomTabbarItems:@[@"当前热门", @"画廊", @"收藏", @"设置", @"搜索"]];
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
        [self setExHentaiStatus:YES];
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

#pragma mark -懒加载
- (NSMutableDictionary *)attrDict {
    if (nil == _attrDict) {
        _attrDict = [NSMutableDictionary new];
    }
    return _attrDict;
}

@end
