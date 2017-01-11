//
//  QJAboutViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/9.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJAboutViewController.h"
#import "QJAboutListViewController.h"

@interface QJAboutViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) NSArray *datas;
//@property (strong, nonatomic) UIView *footerView;

@end

@implementation QJAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"about", nil);
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.tableView];
}

#pragma mark -tableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *row = self.datas[section][@"row"];
    return row.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.datas[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *row = self.datas[indexPath.section][@"row"];
    cell.textLabel.text = row[indexPath.row];
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *versionLabel = [UILabel new];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
        versionLabel.text = currentVersion;
        versionLabel.textColor = [UIColor lightGrayColor];
        versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [cell addSubview:versionLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[versionLabel]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(versionLabel)]];
        [cell addConstraint:[NSLayoutConstraint constraintWithItem:versionLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    else if (indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row) {
            //打开邮件
            [[UIApplication sharedApplication]openURL:[NSURL   URLWithString:@"mailto:qinjiang104@163.com"]];
        }
        else {
            //跳转github
            NSString *githubLink = @"https://github.com/kayanouriko/E-HentaiViewer";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:githubLink]];
        }
    }
    else if (indexPath.section == 2) {
        QJAboutListViewController *vc = [QJAboutListViewController new];
        vc.type = [NSString stringWithFormat:@"%ld",indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64.f) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.headView;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (UIView *)headView {
    if (nil == _headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 116)];
        _headView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 25, 40, 50, 50)];
        logoImageView.layer.cornerRadius = 5.f;
        logoImageView.clipsToBounds = YES;
        logoImageView.image = [UIImage imageNamed:@"logo"];
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 95, kScreenWidth, 21)];
        tipLabel.text = NSLocalizedString(@"abouttip", nil);
        tipLabel.textColor = [UIColor lightGrayColor];
        tipLabel.font = kNormalFontSize;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [_headView addSubview:logoImageView];
        [_headView addSubview:tipLabel];
    }
    return _headView;
}

- (NSArray *)datas {
    if (nil == _datas) {
        _datas = @[
                   @{
                       @"title":@"",
                       @"row":@[NSLocalizedString(@"versions", nil)]
                       },
                   @{
                       @"title":NSLocalizedString(@"contact", nil),
                       @"row":@[NSLocalizedString(@"github", nil) ,NSLocalizedString(@"email", nil)]
                       },
                   @{
                       @"title":NSLocalizedString(@"thanks", nil),
                       @"row":@[NSLocalizedString(@"reference", nil) ,NSLocalizedString(@"opensource", nil)]
                       },
                   ];
    }
    return _datas;
}

/*
- (UIView *)footerView {
    if (nil == _footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        tipLabel.text = 
    }
    return _footerView;
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
