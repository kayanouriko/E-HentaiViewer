//
//  QJMainTabBarViewController.m
//  ExReadViewer
//
//  Created by QinJ on 2017/3/4.
//  Copyright © 2017年 茅野瓜子. All rights reserved.


#import "QJMainTabBarViewController.h"
#import "ViewController.h"
#import "QJHotViewController.h"
#import "QJFavoritesViewController.h"

@interface QJMainTabBarViewController ()<UITabBarControllerDelegate>

@property (assign, nonatomic) NSInteger oldSelectIndex;

@end

@implementation QJMainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = APP_COLOR;
    self.oldSelectIndex = 0;
    self.delegate = self;
    //接收底部栏广播
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show:) name:@"MainTabBarViewShow" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidden:) name:@"MainTabBarViewHide" object:nil];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (self.oldSelectIndex == tabBarController.selectedIndex) {
        UINavigationController *navigation =(UINavigationController *)viewController;
        switch (tabBarController.selectedIndex) {
            case 0:
            {
                ViewController *vc = (ViewController *)navigation.topViewController;
                [vc refreshUI];
            }
                break;
            case 1:
            {
                QJHotViewController *vc = (QJHotViewController *)navigation.topViewController;
                [vc refreshUI];
            }
                break;
            case 2:
            {
                QJFavoritesViewController *vc = (QJFavoritesViewController *)navigation.topViewController;
                [vc refreshUI];
            }
                break;
                
            default:
                break;
        }
    }
    self.oldSelectIndex = tabBarController.selectedIndex;
}

- (void)show:(NSNotification *)noti {
    [UIView animateWithDuration:0.25 animations:^{
        self.tabBar.alpha = 1;
    }];
}

- (void)hidden:(NSNotification *)noti {
    [UIView animateWithDuration:0.25 animations:^{
        self.tabBar.alpha = 0;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
