//
//  QJTabBarController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJTabBarController.h"

@interface QJTabBarController ()

@end

@implementation QJTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
    for (UITabBarItem *item in self.tabBar.items) {
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item.titlePositionAdjustment  = UIOffsetMake(0,20);
    }
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
