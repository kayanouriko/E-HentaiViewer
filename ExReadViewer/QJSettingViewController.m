//
//  QJSettingViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/8.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJSettingViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "QJAboutViewController.h"
#import "QJPasswordViewController.h"
#import "QJLoginViewController.h"
#import "QJSettingUserCell.h"

@interface QJSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datas;
@property (strong, nonatomic) NSMutableArray *privacyArr;

@end

@implementation QJSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"setting", nil);
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    QJSettingUserCell *cell = [self.view viewWithTag:900];
    [cell readUserName];
    
    UILabel *cacheLabel = [self.view viewWithTag:1100];
    NSInteger size = [[[SDWebImageManager sharedManager] imageCache] getSize];
    NSInteger mbSize = size / (1024 * 1024);
    cacheLabel.text = [NSString stringWithFormat:@"%ldMB",(long)mbSize];
}

#pragma mark -tableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *row = self.datas[section][@"row"];
    return row.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section) {
        return 45.f;
    }
    else {
        return 90.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section) {
        return 40.f;
    } else {
        return 20.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.datas[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        QJSettingUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usercell"];
        cell.tag = 900;
        [cell readUserName];
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *row = self.datas[indexPath.section][@"row"];
    cell.textLabel.text = row[indexPath.row];
    if (indexPath.section == 1) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //开关
        UISwitch *swichBtn = [UISwitch new];
        swichBtn.tag = 1000 + indexPath.row;
        BOOL switchOn = [self.privacyArr[indexPath.row] boolValue];
        swichBtn.on = switchOn;
        [swichBtn addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
        
        swichBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [cell addSubview:swichBtn];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[swichBtn]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(swichBtn)]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:swichBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    else if (indexPath.section == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *cacheLabel = [UILabel new];
        cacheLabel.tag = 1100 + indexPath.row;
        NSInteger size = [[[SDWebImageManager sharedManager] imageCache] getSize];
        NSInteger mbSize = size / (1024 * 1024);
        cacheLabel.text = [NSString stringWithFormat:@"%ldMB",(long)mbSize];
        cacheLabel.font = kNormalFontSize;
        cacheLabel.textColor = [UIColor lightGrayColor];
        [cell addSubview:cacheLabel];
        
        cacheLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cacheLabel]-35-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cacheLabel)]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:cacheLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)switchValueChange:(UISwitch *)switchBtn {
    //检测可用性
    if (switchBtn.tag - 1000) {
        //touchid
        [self checkTouchIDWithSwitch:switchBtn];
    }
    else {
        [self checkPasswordWithSwitch:switchBtn];
    }
}

- (void)checkPasswordWithSwitch:(UISwitch *)switchBtn {
    if (switchBtn.on) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tip", nil) message:NSLocalizedString(@"passwordcheck", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = NSLocalizedString(@"passwordinput", nil);
            textField.secureTextEntry = YES;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.tag = 800;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = NSLocalizedString(@"passwordinputagain", nil);
            textField.secureTextEntry = YES;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.tag = 801;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self changeStatusWithBtn:switchBtn];
            UITextField *pwdTextField = (UITextField *)[alertController.view viewWithTag:800];
            [[NSUserDefaults standardUserDefaults] setObject:pwdTextField.text forKey:@"password"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        }];
        okAction.enabled = NO;
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [self changeStatusWithBtn:switchBtn];
    }
}

- (void)alertTextFieldDidChange:(NSNotification *)notification{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    UITextField *oneTextField = (UITextField *)[alertController.view viewWithTag:800];
    UITextField *twoTextField = (UITextField *)[alertController.view viewWithTag:801];
    UIAlertAction *okAction = alertController.actions.lastObject;
    if ([oneTextField.text isEqualToString:twoTextField.text] && oneTextField.text.length > 4) {
        okAction.enabled = YES;
    }
    else {
        okAction.enabled = NO;
    }
}

- (void)changeStatusWithBtn:(UISwitch *)switchBtn {
    //改变存储状态
    self.privacyArr[switchBtn.tag - 1000] = @(switchBtn.on);
    [[NSUserDefaults standardUserDefaults] setObject:self.privacyArr forKey:@"privacy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//touchid
- (void)checkTouchIDWithSwitch:(UISwitch *)switchBtn {
    if (switchBtn.on) {
        LAContext *laContext = [[LAContext alloc] init];
        NSError *error;
        if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                      localizedReason:NSLocalizedString(@"touchidcheck", nil)
                                reply:^(BOOL success, NSError *error) {
                                    if (success) {
                                        switchBtn.on = YES;
                                    }
                                    if (error) {
                                        switchBtn.on = NO;
                                    }
                                }];
        }
        else {
            switchBtn.on = NO;
        }
    }
    [self changeStatusWithBtn:switchBtn];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3) {
        QJAboutViewController *vc = [QJAboutViewController new];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 0) {
        QJLoginViewController *vc = [QJLoginViewController new];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 2) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tip", nil) message:NSLocalizedString(@"tip_clear_image_cache", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[[SDWebImageManager sharedManager] imageCache] clearDiskOnCompletion:^{
                UILabel *cacheLabel = [self.view viewWithTag:1100];
                NSInteger size = [[[SDWebImageManager sharedManager] imageCache] getSize];
                NSInteger mbSize = size / (1024 * 1024);
                cacheLabel.text = [NSString stringWithFormat:@"%ldMB",(long)mbSize];
            }];
        }];
        [alertController addAction:okAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancelAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64.f) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerNib:[UINib nibWithNibName:@"QJSettingUserCell" bundle:nil] forCellReuseIdentifier:@"usercell"];
    }
    return _tableView;
}

- (NSArray *)datas {
    if (nil == _datas) {
        _datas = @[
                   @{
                       @"title":@"",
                       @"row":@[@""],
                       },
                   @{
                       @"title":NSLocalizedString(@"privacy", nil),
                       @"row":@[NSLocalizedString(@"password", nil),NSLocalizedString(@"touchid", nil)],
                       },
                   @{
                       @"title":NSLocalizedString(@"accessibility_options", nil),
                       @"row":@[NSLocalizedString(@"clear_image_cache", nil)]
                       },
                   @{
                       @"title":NSLocalizedString(@"other", nil),
                       @"row":@[NSLocalizedString(@"about", nil)],
                       }
                   ];
    }
    return _datas;
}

//NSInteger size = [[[SDWebImageManager sharedManager] imageCache]getSize];
//NSLog(@"%ld",size);

- (NSMutableArray *)privacyArr {
    if (nil == _privacyArr) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"privacy"]) {
            _privacyArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"privacy"]];
        }
        else {
            _privacyArr = [NSMutableArray arrayWithArray:@[@(NO),@(NO)]];
            [[NSUserDefaults standardUserDefaults] setObject:_privacyArr forKey:@"privacy"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return _privacyArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
