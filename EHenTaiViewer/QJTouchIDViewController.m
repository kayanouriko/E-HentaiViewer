//
//  QJTouchIDViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/9.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJTouchIDViewController.h"
#import "QJProtectTool.h"

@interface QJTouchIDViewController ()

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJTouchIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self unlockWithTouchID];
}

- (IBAction)btnAction:(UIButton *)sender {
    [self unlockWithTouchID];
}

- (void)unlockWithTouchID {
    [[QJProtectTool shareTool] showTouchID:^(QJProtectToolStatus status) {
        if (status == QJProtectToolStatusSuccess) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
