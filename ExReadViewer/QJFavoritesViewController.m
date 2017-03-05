//
//  QJFavoritesViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2017/1/11.
//  Copyright © 2017年 茅野瓜子. All rights reserved.
//

#import "QJFavoritesViewController.h"
#import "QJDataManager.h"
#import "QJMainListCell.h"
#import "QJIntroViewController.h"

@interface QJFavoritesViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *statueView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (strong, nonatomic) NSArray *keyArr;
@property (strong, nonatomic) QJDataManager *manager;
@property (assign, nonatomic) float oldOffsetY;//前一次偏移量

@end

@implementation QJFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self updateResource];
}

- (void)creatUI {
    
    NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [localPath  stringByAppendingPathComponent:@"QJCoreDataModel.db"];
    NSLog(@"%@",filePath);
    self.manager = [[QJDataManager alloc] initWithCoreData:@"Favorites" modelName:@"QJCoreDataModel" sqlPath:filePath success:nil fail:nil];
    
    self.title = NSLocalizedString(@"favorites", nil);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.view addSubview:self.statueView];
    
    [self.view addSubview:self.tableView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self updateResource];
    }];
}

- (void)updateResource {
    [self.manager readEntity:@[] ascending:NO filterStr:nil success:^(NSArray *results) {
        if (results.count) {
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
            }
            [self.datas removeAllObjects];
            results = (NSMutableArray *)[[results reverseObjectEnumerator] allObjects];
            for (NSManagedObject *obj in results) {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                for (NSString *key in self.keyArr) {
                    dict[key] = [obj valueForKey:key];
                }
                [self.datas addObject:dict];
            }
        }
    } fail:nil];
    [self.tableView reloadData];
}

#pragma mark -uitableview滚动
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainTabBarViewShow" object:nil];
    self.tabBarController.tabBar.alpha = 1;
    self.statueView.alpha = 0;
    self.statueView.frame = CGRectMake(0, 0, kScreenWidth, 0);
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainTabBarViewHide" object:nil];
    NSDictionary *dict = self.datas[indexPath.row];
    QJIntroViewController *vc = [QJIntroViewController new];
    vc.introUrl = dict[@"url"];
    vc.infoDict = dict;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        NSDictionary *dict = self.datas[indexPath.row];
        __block NSManagedObject *obj = nil;
        [self.manager readEntity:@[] ascending:NO filterStr:[NSString stringWithFormat:@"url == '%@'",dict[@"url"]] success:^(NSArray *results) {
            if (results.count) {
                obj = (NSManagedObject *)results.firstObject;
            }
        } fail:nil];
        [self.manager deleteEntity:obj success:^{
            [self.datas removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } fail:nil];
    }];
    NSArray *arr = @[rowAction];
    return arr;
}

#pragma mark -懒加载
- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [UITableView new];
        _tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
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

- (UIView *)statueView {
    if (nil == _statueView) {
        _statueView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        _statueView.backgroundColor = APP_COLOR;
        _statueView.alpha = 0;
    }
    return _statueView;
}

- (NSMutableArray *)datas {
    if (nil == _datas) {
        _datas = [NSMutableArray new];
    }
    return _datas;
}

- (NSArray *)keyArr {
    if (nil == _keyArr) {
        _keyArr = @[@"thumb",@"title",@"language",@"title_jpn",@"category",@"uploader",@"filecount",@"filesize",@"rating",@"posted",@"posted",@"url"];
    }
    return _keyArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
