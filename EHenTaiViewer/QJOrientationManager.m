//
//  QJOrientationManager.m
//  EHenTaiViewer
//
//  Created by kayanouriko on 2018/6/26.
//  Copyright © 2018年 kayanouriko. All rights reserved.
//

#import "QJOrientationManager.h"
#import "AppDelegate.h"
#import "UIDevice+QJDevice.h"

@implementation QJOrientationManager

+ (void)changeOrientationFromSetting {
    // 获取应用的AppDelegate
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    // 获取应用配置的屏幕方向
    // 竖屏, 横屏, 跟随系统(除了反向竖屏)
    appDelegate.orientation = [QJGlobalInfo customOrientation];
    // 横竖屏的时候强制转换现在的屏幕
    switch (appDelegate.orientation) {
        case UIInterfaceOrientationMaskPortrait:
            [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
            break;
        case UIInterfaceOrientationMaskLandscape:
            [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeLeft];
            break;
        default:
            break;
    }
}

+ (NSInteger)getOrientationSegSelected {
    NSInteger selectedIndex = 2;
    UIInterfaceOrientationMask customOrientation = [QJGlobalInfo customOrientation];
    switch (customOrientation) {
        case UIInterfaceOrientationMaskPortrait:
            selectedIndex = 0;
            break;
        case UIInterfaceOrientationMaskLandscape:
            selectedIndex = 1;
            break;
        default:
            break;
    }
    return selectedIndex;
}

+ (void)recoverPortraitOrienttation {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.orientation = UIInterfaceOrientationMaskPortrait;
    [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
}

+ (void)setOrientationWithSelected:(NSInteger)selectedIndex {
    UIInterfaceOrientationMask customOrientation = UIInterfaceOrientationMaskAllButUpsideDown;
    switch (selectedIndex) {
        case 0:
            customOrientation = UIInterfaceOrientationMaskPortrait;
            break;
        case 1:
            customOrientation = UIInterfaceOrientationMaskLandscape;
            break;
        default:
            break;
    }
    [QJGlobalInfo setCustomOrientation:customOrientation];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.orientation = customOrientation;
    switch (customOrientation) {
        case UIInterfaceOrientationMaskPortrait:
            [UIDevice switchNewOrientation:UIInterfaceOrientationPortrait];
            break;
        case UIInterfaceOrientationMaskLandscape:
            [UIDevice switchNewOrientation:UIInterfaceOrientationLandscapeRight];
            break;
        default:
            break;
    }
}

+ (NSInteger)getDiretionSegSelected {
    UICollectionViewScrollDirection customScrollDiretion = [QJGlobalInfo customScrollDiretion];
    return customScrollDiretion == UICollectionViewScrollDirectionHorizontal ? 0 : 1;
}

+ (void)setDiretionWithSelected:(NSInteger)selectedIndex {
    UICollectionViewScrollDirection customScrollDiretion = selectedIndex ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
    [QJGlobalInfo setCustomScrollDiretion:customScrollDiretion];
}

+ (void)saveImageToSystemThumbWithImagePath:(NSString *)imagePath {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存该页到系统相册" message:@"\n\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    
    [alert.view addSubview:imageView];
    [alert.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alert.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [alert.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:alert.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    // 获取到的alert宽度为270,这个貌似是固定值,待确定,160是根据\n的数量进行调整的
    [alert.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[imageView(270)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    [alert.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(160)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView)]];
    [[self visibleViewController] presentViewController:alert animated:YES completion:nil];
}

+ (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        [self showAlertWithError:error];
    } else {
        Toast(@"保存图片成功");
    }
    
}

+ (void)showAlertWithError:(NSError *)error {
    if (error.code == -3310) {
        // 权限问题,跳转设置修复
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存失败" message:@"保存图片相关权限未打开,跳转设置权限后应用会自动重启" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (@available(iOS 10.0, *)) {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                }
            } else {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
        [alert addAction:cancelAction];
        [alert addAction:defaultAction];
        [[self visibleViewController] presentViewController:alert animated:YES completion:nil];
    } else {
        Toast(@"遭遇不可抗拒原因保存图片失败");
    }
}

#pragma mark - 获取当前页面的Nav
// 感谢终极方法:https://www.jianshu.com/p/901a8fb1760f
+ (UIWindow *)mainWindow {
    return [UIApplication sharedApplication].delegate.window;
}

+ (UIViewController *)visibleViewController {
    UIViewController *rootViewController = [self.mainWindow rootViewController];
    return [self getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *) getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [self getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
    
}

+ (UINavigationController *)visibleNavigationController {
    return [[self visibleViewController] navigationController];
}

@end
