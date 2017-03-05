//
//  QJMainTabBarViewController.m
//  ExReadViewer
//
//  Created by QinJ on 2017/3/4.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//  TODO:双击点击刷新

#import "QJMainTabBarViewController.h"

@interface QJMainTabBarViewController ()

@end

@implementation QJMainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.tintColor = APP_COLOR;
    //接收底部栏广播
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show:) name:@"MainTabBarViewShow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidden:) name:@"MainTabBarViewHide" object:nil];
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
