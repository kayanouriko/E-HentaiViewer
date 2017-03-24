//
//  QJAboutListViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/9.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJAboutListViewController.h"

@interface QJAboutListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datas;

@end

@implementation QJAboutListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"thanks", nil);
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
    cell.textLabel.font = kNormalFontSize;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *url = self.datas[indexPath.row][@"url"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64.f) style:UITableViewStyleGrouped];
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
                           @"title":@"AFNetworking/AFNetworking",
                           @"url":@"https://github.com/AFNetworking/AFNetworking"
                           },
                       @{
                           @"title":@"danielamitay/DACircularProgress",
                           @"url":@"https://github.com/danielamitay/DACircularProgress"
                           },
                       @{
                           @"title":@"jdg/MBProgressHUD",
                           @"url":@"https://github.com/jdg/MBProgressHUD"
                           },
                       @{
                           @"title":@"CoderMJLee/MJRefresh",
                           @"url":@"https://github.com/CoderMJLee/MJRefresh"
                           },
                       @{
                           @"title":@"mwaterfall/MWPhotoBrowser",
                           @"url":@"https://github.com/mwaterfall/MWPhotoBrowser"
                           },
                       @{
                           @"title":@"rs/SDWebImage",
                           @"url":@"https://github.com/rs/SDWebImage"
                           },
                       @{
                           @"title":@"SVProgressHUD/SVProgressHUD",
                           @"url":@"https://github.com/SVProgressHUD/SVProgressHUD"
                           },
                       @{
                           @"title":@"laideybug/MMButtonMenu",
                           @"url":@"https://github.com/laideybug/MMButtonMenu"
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
