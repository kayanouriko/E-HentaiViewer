//
//  QJLoginViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/5/22.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJLoginViewController.h"
#import "QJHenTaiParser.h"
#import "QJWebViewController.h"

@interface QJLoginViewController ()<UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navgationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarTopLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLabelBottomLine;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextF;
@property (weak, nonatomic) IBOutlet UIView *loginView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)btnAction:(UIButton *)sender;

- (IBAction)cancelAction:(UIBarButtonItem *)sender;

@end

@implementation QJLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navgationBar.delegate = self;
    self.navigationBarTopLine.constant = UIStatusBarHeight();
    self.tipLabelBottomLine.constant = UITabBarSafeBottomMargin();
    [self buttonNormalStatus];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (void)loginAction {
    if (self.usernameTextF.text.length && self.passwordTextF.text.length) {
        [self.view endEditing:YES];
        [self buttonLogingStatus];
        [[QJHenTaiParser parser] loginWithUserName:self.usernameTextF.text password:self.passwordTextF.text complete:^(QJHenTaiParserStatus status) {
            if (status == QJHenTaiParserStatusSuccess) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_NOTI object:nil];
            }
            else if (status == QJHenTaiParserStatusParseFail || status == QJHenTaiParserStatusNetworkFail) {
                [self buttonNormalStatus];
            }
        }];
    }
    else {
        [self showErrorAnimation];
    }
}

- (void)showErrorAnimation {
    CAKeyframeAnimation *shake = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.values = @[@-10,@0,@10,@0];
    shake.repeatCount = 2;
    shake.duration = 0.1f;
    [self.loginView.layer addAnimation:shake forKey:nil];
    [self.usernameTextF.layer addAnimation:shake forKey:nil];
    [self.passwordTextF.layer addAnimation:shake forKey:nil];
}

- (void)buttonLogingStatus {
    self.titleLabel.text = @"登录中...";
    self.activity.hidden = NO;
    [self.activity startAnimating];
    UIButton *btn = [self.view viewWithTag:300];
    btn.enabled = NO;
}

- (void)buttonNormalStatus {
    self.titleLabel.text = @"登录";
    self.activity.hidden = YES;
    [self.activity stopAnimating];
    UIButton *btn = [self.view viewWithTag:300];
    btn.enabled = YES;
}

#pragma mark -按钮点击事件
- (IBAction)btnAction:(UIButton *)sender {
    switch (sender.tag - 300) {
        case 0:
        {
            [self loginAction];
        }
            break;
        case 1:
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        case 2:
        {
            //网页登陆
            QJWebViewController *vc = [QJWebViewController new];
            [self presentViewController:vc animated:YES completion:nil];
        }
            break;
        case 3:
        {
            // 删除cookie
            if ([[QJHenTaiParser parser] deleteCokie]) {
                Toast(@"删除cookie成功");
            }
        }
            break;
        default:
            break;
    }
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
