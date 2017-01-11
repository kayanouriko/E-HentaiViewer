//
//  AppDelegate.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/25.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "QJTouchIDViewController.h"
#import "QJPasswordViewController.h"

@interface AppDelegate ()<UIApplicationDelegate>

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger time;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /*定时器后台运行*/
    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    /*设置Audio Session的Category 一般会在激活之前设置好Category和mode。但是也可以在已激活的audio session中设置，不过会在发生route change之后才会发生改变*/
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryErr];
    /*激活Audio Session*/
    [[AVAudioSession sharedInstance] setActive: YES error: &activationErr];
    self.time = 0;
    
    
    //改变状态栏颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //进入后台
    UIApplication* app = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    
    /*注册一个后台任务，告诉系统我们需要向系统借一些事件*/
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                /*销毁后台任务标识符*/
                /*不管有没有完成，结束background_task任务*/
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                /*销毁后台任务标识符*/
                /*不管有没有完成，结束background_task任务*/
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
    NSArray *status = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"privacy"]];
    if (status.count) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeat) userInfo:nil repeats:YES];
    }
}

- (void)repeat {
    self.time++;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSArray *status = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"privacy"]];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    //进入前台
    if (status.count && self.time > 59 && [status[1] boolValue]) {
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        QJTouchIDViewController *subVC = [QJTouchIDViewController new];
        [vc presentViewController:subVC animated:YES completion:nil];
    }
    else if (status.count && self.time > 59 && [status[0] boolValue] && password) {
        UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        QJPasswordViewController *subVC = [QJPasswordViewController new];
        [vc presentViewController:subVC animated:YES completion:nil];
    }
    self.time = 0;
    [self.timer invalidate];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
