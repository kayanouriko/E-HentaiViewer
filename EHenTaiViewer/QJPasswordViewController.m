//
//  QJPasswordViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/10.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJPasswordViewController.h"

@interface QJPasswordViewController ()


@property (assign, nonatomic) BOOL needPushVC;

- (IBAction)btnAction:(UIButton *)sender;

@end

@implementation QJPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.needPushVC = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.needPushVC) {
        [self pushPasswordAlertView];
        self.needPushVC = NO;
    }
}

- (void)pushPasswordAlertView {
    /*
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tip", nil) message:NSLocalizedString(@"touchidtip", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = NSLocalizedString(@"passwordinput", nil);
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.tag = 600;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *pwdTextField = (UITextField *)[alertController.view viewWithTag:600];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        if ([pwdTextField.text isEqualToString:password]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"passworderror", nil)];
            [SVProgressHUD dismissWithDelay:1.f];
        }
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
     */
}

- (IBAction)btnAction:(UIButton *)sender {
    [self pushPasswordAlertView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
