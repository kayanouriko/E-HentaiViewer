//
//  QJNetworkTool.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJNetworkTool.h"
#import "Reachability.h"

@interface QJNetworkTool () {
    long long _aboveBytes;
    NSInteger _count;
}

@property (nonatomic) Reachability *internetReachability;

@end

@implementation QJNetworkTool

+ (QJNetworkTool *)shareTool {
    static QJNetworkTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [QJNetworkTool new];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        _count = 0;
    }
    return self;
}

- (BOOL)isEnableNetwork {
    return [self.internetReachability currentReachabilityStatus] != NotReachable;
}

- (BOOL)isEnableMobleNetwork {
    return [self.internetReachability currentReachabilityStatus] == ReachableViaWWAN;
}

- (void)starNotifier {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:)name:kReachabilityChangedNotification object:nil];
    [self.internetReachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification*)notification {
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:{
            Toast(@"没有任何网络连接");
            break;
        }
            
        case ReachableViaWWAN:{
            Toast(@"正在移动数据下浏览");
            break;
        }
        case ReachableViaWiFi:{
            
            break;
        }
    }
}

#pragma mark - 菊花部分
- (void)showNetworkActivity {
    if (_count == 0) {
        NetworkShow();
    }
    _count++;
}

- (void)hiddenNetworkActivity {
    _count--;
    if (_count <= 0) {
        _count = 0;
        NetworkHidden();
    }
}

@end
