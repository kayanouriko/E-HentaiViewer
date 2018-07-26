//
//  QJTabBarController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJTabBarController.h"

@interface QJTabBarController ()<UITabBarControllerDelegate>

@property (nonatomic, strong) UITabBarItem *lastSelectedItem;

@end

@implementation QJTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.lastSelectedItem = self.tabBar.selectedItem;
    
    // 这里设置自定义tabbar
    NSArray<NSString *> *tabbarItems = [QJGlobalInfo customTabbarItems];
    NSMutableArray *viewControllers = [NSMutableArray new];
    for (NSString *title in tabbarItems) {
        for (NSInteger i = 0; i < self.tabBar.items.count; i++) {
            UITabBarItem *item = (UITabBarItem *)self.tabBar.items[i];
            if ([item.title isEqualToString:title]) {
                [viewControllers addObject:self.viewControllers[i]];
                item = nil;
                break;
            }
            item = nil;
        }
    }
    self.viewControllers = viewControllers;
    viewControllers = nil;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if (nav.viewControllers.count == 1 && self.lastSelectedItem == tabBarController.tabBar.selectedItem && [nav.topViewController respondsToSelector:@selector(scrollToTop)]) {
            [nav.topViewController performSelector:@selector(scrollToTop)];
        }
#pragma clang diagnostic pop
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.lastSelectedItem = tabBarController.tabBar.selectedItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
