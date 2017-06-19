//
//  QJNetworkTool.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/24.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJNetworkTool.h"
#import "Reachability.h"

@interface QJNetworkTool ()

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
            ToastError(nil, @"貌似现在没有任何网络连接哦~");
            break;
        }
            
        case ReachableViaWWAN:{
            ToastWarning(nil, @"你现在是在移动数据下浏览,注意流量哦~");
            break;
        }
        case ReachableViaWiFi:{
            
            break;
        }
    }
}

@end
