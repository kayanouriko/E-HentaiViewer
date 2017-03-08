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
//@property (strong, nonatomic) UIView *statueView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (assign, nonatomic) float oldOffsetY;//前一次偏移量

@end

@implementation QJHotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self.tableView.mj_header beginRefreshing];
    [self updateResource];
}

- (void)refreshUI {
    if (![self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_header beginRefreshing];
        [self updateResource];
    }
}

- (void)creatUI {
    self.title = NSLocalizedString(@"hot", nil);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //[self.view addSubview:self.statueView];
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

#pragma mark -uitableview滚动
/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float contentOffsetY = scrollView.contentOffset.y;
    if (self.oldOffsetY && contentOffsetY > 0) {
        float changeOffset = self.oldOffsetY - contentOffsetY;
        if (changeOffset > 0) {
            self.tableView.bounces = YES;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MainTabBarViewShow" object:nil];
            [UIView animateWithDuration:0.25f animations:^{
                self.statueView.alpha = 0;
                self.statueView.frame = CGRectMake(0, 0, kScreenWidth, 0);
                self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                [self.view layoutIfNeeded];
            }];
        } else {
            self.tableView.bounces = NO;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MainTabBarViewHide" object:nil];
            [UIView animateWithDuration:0.25f animations:^{
                self.statueView.alpha = 1;
                self.statueView.frame = CGRectMake(0, 0, kScreenWidth, 20);
                self.tableView.frame = CGRectMake(0, 20, kScreenWidth, kScreenHeight - 20);
                [self.view layoutIfNeeded];
            }];
        }
    }
    self.oldOffsetY = contentOffsetY;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainTabBarViewShow" object:nil];
    self.tabBarController.tabBar.alpha = 1;
    self.statueView.alpha = 0;
    self.statueView.frame = CGRectMake(0, 0, kScreenWidth, 0);
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
}
*/

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
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"MainTabBarViewHide" object:nil];
    NSDictionary *dict = self.datas[indexPath.row];
    QJIntroViewController *vc = [QJIntroViewController new];
    vc.introUrl = dict[@"url"];
    vc.infoDict = dict;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        //_tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - 49);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 157.f;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //注册
        [_tableView registerNib:[UINib nibWithNibName:@"QJMainListCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

/*
- (UIView *)statueView {
    if (nil == _statueView) {
        _statueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        _statueView.backgroundColor = APP_COLOR;
        _statueView.alpha = 0;
    }
    return _statueView;
}
 */

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
