//
//  QJTabBarController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJTabBarController.h"

@interface QJTabBarController ()<UITabBarControllerDelegate>



@end

@implementation QJTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if (nav.viewControllers.count == 1 && [nav.topViewController respondsToSelector:@selector(scrollToTop)]) {
            [nav.topViewController performSelector:@selector(scrollToTop)];
        }
#pragma clang diagnostic pop
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    /*
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        
        NSLog(@"%@", NSStringFromClass([nav.topViewController class]));
    }
    */
    //[viewController.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
