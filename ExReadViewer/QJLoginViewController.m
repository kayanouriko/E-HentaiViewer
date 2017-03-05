//
//  QJLoginViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/20.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJLoginViewController.h"
#import "AFNetworking.h"
#import "TFHpple.h"
#import "DiveExHentaiV2.h"

@interface QJLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"login", nil);
    [self.loginBtn setTitle:NSLocalizedString(@"login", nil) forState:UIControlStateNormal];
    self.usernameTextF.placeholder = NSLocalizedString(@"username", nil);
    self.passwordTextF.placeholder = NSLocalizedString(@"passwordname", nil);
}

#pragma mark -登录验证
- (IBAction)btnAction:(UIButton *)sender {
    switch (sender.tag - 300) {
        case 0:
        {
            [SVProgressHUD show];
            [DiveExHentaiV2 diveBy:self.usernameTextF.text andPassword:self.passwordTextF.text completion:^(BOOL isSuccess) {
                if (isSuccess) {
                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"loginsuccess", nil)];
                    [SVProgressHUD dismissWithDelay:1.f completion:^{
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                }
                else {
                    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"loginfailed", nil)];
                    [SVProgressHUD dismissWithDelay:1.f];
                }
            }];
        }
            break;
        case 1:
        {
            [SVProgressHUD show];
            if ([DiveExHentaiV2 checkCookie]) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"validcookie", nil)];
                [SVProgressHUD dismissWithDelay:1.f];
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"invalidcookie", nil)];
                [SVProgressHUD dismissWithDelay:1.f];
            }
        }
            break;
        case 2:
        {
            [SVProgressHUD show];
            if ([DiveExHentaiV2 deleteCokie]) {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"deletecookie", nil)];
                [SVProgressHUD dismissWithDelay:1.f];
            }
            else {
                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"deletefcookie", nil)];
                [SVProgressHUD dismissWithDelay:1.f];
            }
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
