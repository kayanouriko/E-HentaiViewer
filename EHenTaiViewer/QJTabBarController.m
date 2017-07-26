//
//  QJTabBarController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/6/19.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJTabBarController.h"
#import "QJIPADMainDockView.h"

@interface QJTabBarController ()

@property (nonatomic, strong) QJIPADMainDockView *dock;

@end

@implementation QJTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UITabBarItem *item in self.tabBar.items) {
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item.titlePositionAdjustment  = UIOffsetMake(0,20);
    }
}

#pragma mark -getter
- (QJIPADMainDockView *)dock {
    if (nil == _dock) {
        _dock = [[NSBundle mainBundle] loadNibNamed:@"QJIPADMainDockView" owner:nil options:nil][0];
        _dock.frame = CGRectMake(0, 0, 70, UIScreenHeight());
    }
    return _dock;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
