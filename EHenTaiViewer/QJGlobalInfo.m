//
//  QJGlobalInfo.m
//  wikiForMHXX
//
//  Created by QinJ on 2017/4/18.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJGlobalInfo.h"

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

#pragma mark -懒加载
- (NSMutableDictionary *)attrDict {
    if (nil == _attrDict) {
        _attrDict = [NSMutableDictionary new];
    }
    return _attrDict;
}

@end
