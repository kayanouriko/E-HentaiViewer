//
//  QJProtectTool.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/25.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJProtectTool.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation QJProtectTool

+ (QJProtectTool *)shareTool {
    static QJProtectTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [QJProtectTool new];
    });
    return sharedInstance;
}

- (BOOL)isEnableTouchID {
    LAContext *laContext = [LAContext new];
    return [laContext canEvaluatePolicy:kLAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL];
}

//是否支持系统密码验证
- (BOOL)isSupportDeviceOwnerAuth {
    if (@available(iOS 9.0, *)) {
        LAContext *laContext = [LAContext new];
        return [laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:NULL];
    } else {
        return NO;
    }
    return NO;
}

- (void)showTouchID:(CompletBlock)completion {
    LAContext *context = [LAContext new];
    NSString *des = @"验证用于打开应用";
    LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    if (@available(iOS 9.0, *)) {
        policy = LAPolicyDeviceOwnerAuthentication;
    }
    [context evaluatePolicy:policy localizedReason:des reply:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                completion(QJProtectToolStatusSuccess);
            } else {
                completion(QJProtectToolStatusCannel);
            }
        });
    }];
}

@end
