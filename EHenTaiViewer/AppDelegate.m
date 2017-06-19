//
//  AppDelegate.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/17.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "AppDelegate.h"
#import "QJNetworkTool.h"
#import "QJProtectTool.h"
#import "QJTouchIDViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //TODO:检查更新
    
    //TODO:检查相册权限
    
    //解决iOS遗留bug,导航栏push或者pop存在黑块问题
    self.window.backgroundColor = [UIColor whiteColor];
    //判断全局的版块变量,确保初始化必须有值
    if (!NSObjForKey(@"ExHentaiStatus")) {
        NSObjSetForKey(@"ExHentaiStatus", @(NO));
        NSObjSynchronize();
    }
    //观看模块
    if (!NSObjForKey(@"WatchMode")) {
        NSObjSetForKey(@"WatchMode", @(NO));
        NSObjSynchronize();
    }
    //保护模块
    if (!NSObjForKey(@"ProtectMode")) {
        NSObjSetForKey(@"ProtectMode", @(NO));
        NSObjSynchronize();
    }
    //网络监测
    [[QJNetworkTool shareTool] starNotifier];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[QJGlobalInfo sharedInstance] putAttribute:@"BackgroundTime" value:@([[NSProcessInfo processInfo] systemUptime])];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (NSObjForKey(@"ProtectMode") && [NSObjForKey(@"ProtectMode") boolValue]) {
        NSTimeInterval beginTime = [[[QJGlobalInfo sharedInstance] getAttribute:@"BackgroundTime"] integerValue];
        NSTimeInterval endTime = [[NSProcessInfo processInfo] systemUptime];
        if (endTime - beginTime > 120) {
            if ([[QJProtectTool shareTool] isEnableTouchID]) {
                //TouchID
                UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                if (![vc isKindOfClass:[QJTouchIDViewController class]]) {
                    QJTouchIDViewController *subVC = [QJTouchIDViewController new];
                    [vc presentViewController:subVC animated:nil completion:nil];
                }
            }
            else {
                //密码
            }
        }
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
