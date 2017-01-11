//
//  QJHotViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/10.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJHotViewController.h"
#import "QJIntroViewController.h"
#import "QJMainListCell.h"
#import "HentaiParser.h"

@interface QJHotViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datas;

@end

@implementation QJHotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self.tableView.mj_header beginRefreshing];
    [self updateResource];
}

- (void)creatUI {
    self.title = NSLocalizedString(@"hot", nil);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self updateResource];
    }];
}

- (void)updateResource {
    [HentaiParser requestHotListForExHentai:NO completion:^(HentaiParserStatus status, NSArray *listArray) {
        if (status && [listArray count]) {
            if ([self.tableView.mj_header isRefreshing]) {
                [self.datas removeAllObjects];
                [self.tableView.mj_header endRefreshing];
            }
            else {
                [self.datas removeAllObjects];
            }
            [self.datas addObjectsFromArray:listArray];
            [self.tableView reloadData];
        }
        else {
            [self.tableView.mj_header endRefreshing];
        }
    }];
}

#pragma mark -tableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJMainListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell refreshUI:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.datas[indexPath.row];
    QJIntroViewController *vc = [QJIntroViewController new];
    vc.introUrl = dict[@"url"];
    vc.infoDict = dict;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 157.f;
        _tableView.tableFooterView = [UIView new];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //注册
        [_tableView registerNib:[UINib nibWithNibName:@"QJMainListCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (NSMutableArray *)datas {
    if (nil == _datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
