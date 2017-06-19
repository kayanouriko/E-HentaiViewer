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
    NSError *error;
    return [laContext canEvaluatePolicy:kLAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
}

- (void)showTouchID:(CompletBlock)completion {
    LAContext *laContext = [LAContext new];
    NSError *error;
    if ([laContext canEvaluatePolicy:kLAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:@"解锁 \"E绅士阅读器\" 的世界"
                            reply:^(BOOL success, NSError *error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if (success) {
                                        completion(QJProtectToolStatusSuccess);
                                    }
                                    if (error) {
                                        completion(QJProtectToolStatusCannel);
                                    }
                                });
         }];
    }
}

@end
