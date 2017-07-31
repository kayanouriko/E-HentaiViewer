//
//  QJAboutListViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/9.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJAboutListViewController.h"
#import <SafariServices/SafariServices.h>

@interface QJAboutListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datas;

@end

@implementation QJAboutListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"致谢";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

#pragma mark -tableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.datas[indexPath.row][@"title"];
    cell.textLabel.font = AppFontContentStyle();
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *url = self.datas[indexPath.row][@"url"];
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
        [self presentViewController:safariVC animated:YES completion:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(isPad ? 60 : 0, 0,isPad ? UIScreenWidth() - 120 : UIScreenWidth(), UIScreenHeight()) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSArray *)datas {
    if (nil == _datas) {
        if ([self.type isEqualToString:@"1"]) {
            //开源项目
            _datas = @[
                       @{
                           @"title":@"ibireme/YYWebImage",
                           @"url":@"https://github.com/ibireme/YYWebImage"
                           },
                       @{
                           @"title":@"imlifengfeng/FFToast",
                           @"url":@"https://github.com/imlifengfeng/FFToast"
                           },
                       @{
                           @"title":@"ninjinkun/NJKWebViewProgress",
                           @"url":@"https://github.com/ninjinkun/NJKWebViewProgress"
                           },
                       @{
                           @"title":@"Topfunky/TFHpple",
                           @"url":@"http://topfunky.com"
                           },
                       @{
                           @"title":@"huahua0809/XHStarRateView",
                           @"url":@"https://github.com/huahua0809/XHStarRateView"
                           },
                       @{
                           @"title":@"Mapaler/EhTagTranslator",
                           @"url":@"https://github.com/Mapaler/EhTagTranslator"
                           },
                       ];
        }
        else {
            //参考项目
            _datas = @[
                       @{
                           @"title":@"2DimensionLovers/e-Hentai",
                           @"url":@"https://github.com/2DimensionLovers/e-Hentai"
                           },
                       @{
                           @"title":@"DaidoujiChen/Dai-Hentai",
                           @"url":@"https://github.com/DaidoujiChen/Dai-Hentai"
                           },
                       @{
                           @"title":@"seven332/EhViewer",
                           @"url":@"https://github.com/seven332/EhViewer"
                           },
                       ];
        }
    }
    return _datas;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
