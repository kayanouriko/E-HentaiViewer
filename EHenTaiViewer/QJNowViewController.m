//
//  QJNowViewController.m
//  EHenTaiViewer
//
//  Created by QinJ on 2017/9/20.
//  Copyright © 2017年 kayanouriko. All rights reserved.
//

#import "QJNowViewController.h"
#import "QJListTableView.h"
#import "QJListCell.h"
#import "QJHenTaiParser.h"
#import "QJNewInfoViewController.h"
#import "QJRankingViewController.h"
//iconfont
#import "TBCityIconFont.h"
#import "UIImage+TBCityIconFont.h"

@interface QJNowViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) QJListTableView *tableview;
@property (nonatomic, strong) NSArray<QJListItem *> *datas;
@property (nonatomic, strong) UIRefreshControl *refrshControl;

@end

@implementation QJNowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"当前热门";
    [self setContent];
    [self showFreshingViewWithTip:nil];
    [self updateHotResource];
}

#pragma mark -滚动到顶部
- (void)scrollToTop {
    if (self.datas.count) {
        [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)updateHotResource {
    [[QJHenTaiParser parser] updateHotListInfoComplete:^(QJHenTaiParserStatus status, NSArray<QJListItem *> *listArray) {
        if (status == QJHenTaiParserStatusSuccess) {
            self.datas = listArray;
            [self.tableview reloadData];
        }
        [self.refrshControl endRefreshing];
        if ([self isShowFreshingStatus]) {
            [self hiddenFreshingView];
        }
    }];
}

- (void)setContent {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage iconWithInfo:TBCityIconInfoMake(@"\U0000e61f", 25, [UIColor whiteColor])] style:UIBarButtonItemStylePlain target:self action:@selector(clickToplist)];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.view addSubview:self.tableview];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableview)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableview)]];
}

- (void)clickToplist {
    QJRankingViewController *vc = [QJRankingViewController new];
    // vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QJListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([QJListCell class])];
    [cell refreshUI:self.datas[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QJNewInfoViewController *vc = [QJNewInfoViewController new];
    // vc.hidesBottomBarWhenPushed = YES;
    vc.model = self.datas[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -getter
- (QJListTableView *)tableview {
    if (nil == _tableview) {
        _tableview = [QJListTableView new];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        if (@available(iOS 11.0, *)) {
            
        }
        else {
            _tableview.contentInset = UIEdgeInsetsMake(UINavigationBarHeight(), 0, UITabBarHeight(), 0);
        }
        [_tableview addSubview:self.refrshControl];
    }
    return _tableview;
}

- (UIRefreshControl *)refrshControl {
    if (nil == _refrshControl) {
        _refrshControl = [UIRefreshControl new];
        [_refrshControl addTarget:self action:@selector(updateHotResource) forControlEvents:UIControlEventValueChanged];
    }
    return _refrshControl;
}

- (NSArray<QJListItem *> *)datas {
    if (nil == _datas) {
        _datas = [NSArray new];
    }
    return _datas;
}

@end
