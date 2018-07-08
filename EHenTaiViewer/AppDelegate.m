//
//  AppDelegate.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/17.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//  TODO:第三方跳转识别

#import "AppDelegate.h"
#import "QJNetworkTool.h"
#import "QJProtectTool.h"
#import "QJTouchIDViewController.h"
#import "Tag+CoreDataClass.h"
#import "QJTouchIDViewController.h"
#import "QJSecretBgTool.h"
#import "QJOrientationManager.h"

@interface AppDelegate ()

@property (nonatomic, assign, getter=isFristTime) BOOL fristTime;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //TODO:检查更新,弹窗提醒
    
    //设置数据库
    [self setCoreData];
    // 解决iOS遗留bug,导航栏push或者pop存在黑块问题
    self.window.backgroundColor = [UIColor whiteColor];
    // 把转屏重新修正为竖屏
    [QJOrientationManager recoverPortraitOrienttation];
    // 网络监测
    [[QJNetworkTool shareTool] starNotifier];
    // 密码验证相关
    [[QJGlobalInfo sharedInstance] putAttribute:@"BackgroundTime" value:@([[NSProcessInfo processInfo] systemUptime] - 120)];
    self.fristTime = YES;
    
    return YES;
}

- (void)setCoreData {
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Model.sqlite"];
    Tag *tag = [Tag MR_findFirst];
    if (nil == tag) {
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(saveAllTags) object:nil];
        [thread start];
    }
}

- (void)saveAllTags {
    //存储全部Tag标签,以后备用更新本地离线Tag值
    //数据库操作
    NSString *path = [[NSBundle mainBundle] pathForResource:@"EhTag_CN" ofType:@"json"];
    NSDictionary *tagJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingAllowFragments error:nil];
    NSArray<NSDictionary *> *catgoery = tagJson[@"dataset"];
    NSInteger i = 0;
    for (NSDictionary *subCat in catgoery) {
        NSArray<NSDictionary *> *tags = subCat[@"tags"];
        for (NSDictionary *tagDic in tags) {
            NSString *type = isnull(@"type", tagDic);
            if (![type isEqualToString:@"0"]) {
                continue;
            }
            Tag *tag = [Tag MR_createEntityInContext:[NSManagedObjectContext MR_defaultContext]];
            tag.name = isnull(@"name", tagDic);
            tag.cname = isnull(@"cname", tagDic);
            tag.info = isnull(@"info", tagDic);
            i++;
            if (i % 1000 == 0) {
                [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
            }
        }
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

#pragma mark -横竖屏设置相关
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return self.orientation;
}

// 前台即将进入后台执行的方法
- (void)applicationWillResignActive:(UIApplication *)application {
    [[QJSecretBgTool sharedInstance] showSecretBackground];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[QJGlobalInfo sharedInstance] putAttribute:@"BackgroundTime" value:@([[NSProcessInfo processInfo] systemUptime])];
}

// 后台即将进入前台执行的方法
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self checkTouchID];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[QJSecretBgTool sharedInstance] hiddenSecretBackground];
    if (self.isFristTime) {
        self.fristTime = NO;
        [self checkTouchID];
    }
}

- (void)checkTouchID {
    if ([QJGlobalInfo isExHentaiProtectMode]) {
        NSTimeInterval beginTime = [[[QJGlobalInfo sharedInstance] getAttribute:@"BackgroundTime"] integerValue];
        NSTimeInterval endTime = [[NSProcessInfo processInfo] systemUptime];
        if (endTime - beginTime > 60) {
            if ([[QJProtectTool shareTool] isEnableTouchID]) {
                //TouchID
                UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
                if (![vc isKindOfClass:[QJTouchIDViewController class]]) {
                    QJTouchIDViewController *subVC = [QJTouchIDViewController new];
                    [vc presentViewController:subVC animated:nil completion:nil];
                }
            }
        }
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
