//
//  QJTouchIDViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/9.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJTouchIDViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

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
    LAContext *laContext = [[LAContext alloc] init];
    NSError *error;
    if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:NSLocalizedString(@"touchidtip", nil)
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                }
                                if (error) {
                                    NSLog(@"---failed to evaluate---error: %@---", error.description);
                                    //do your error handle
                                }
                            }];
    }
    else {
        NSLog(@"==========Not support :%@", error.description);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
