//
//  QJTagViewController.m
//  ExReadViewer
//
//  Created by 覃江 on 2016/12/31.
//  Copyright © 2016年 茅野瓜子. All rights reserved.
//

#import "QJTagViewController.h"
#import "QJIntroViewController.h"
#import "QJMainListCell.h"
#import "HentaiParser.h"
#import "TagCollect+CoreDataClass.h"

@interface QJTagViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datas;
@property (assign, nonatomic) NSInteger pageIndex;
@property (assign, nonatomic) float oldOffsetY;//前一次偏移量
@property (assign, nonatomic) BOOL isExHentai;//判断是表站还是里站
@property (strong, nonatomic) UIImageView *collectImageView;//收藏图标
@property (assign, nonatomic) BOOL isCollect;//是否已经收藏

@end

@implementation QJTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
    [self.tableView.mj_header beginRefreshing];
    [self updateResource];
}

- (void)creatUI {
    //初始化
    self.isExHentai = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ehentaiStatus"] boolValue];
    
    self.isCollect = NO;
    NSArray *tagCollectArr = [TagCollect MR_findByAttribute:@"tagName" withValue:self.tagName];
    if (tagCollectArr.count) {
        self.isCollect = YES;
    }
    
    self.title = self.tagName;
    //右上角
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 0, 44, 24);
    self.collectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 24, 24)];
    self.collectImageView.image = [[UIImage imageNamed:self.isCollect ? @"collected" : @"collect"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.collectImageView.tintColor = [UIColor whiteColor];
    [btn addSubview:self.collectImageView];
    [btn addTarget:self action:@selector(tagCollect)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.pageIndex = 0;
        [self updateResource];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.pageIndex++;
        [self updateResource];
    }];
}

#pragma mark -tag收藏
- (void)tagCollect {
    if (self.isCollect) {
        //已经收藏
        NSArray *tagArr = [TagCollect MR_findByAttribute:@"tagName" withValue:self.tagName];
        for (TagCollect *tmp in tagArr) {
            [tmp MR_deleteEntity];
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        self.collectImageView.image = [[UIImage imageNamed:@"collect"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"remove_from_favorite_success", nil)];
        [SVProgressHUD dismissWithDelay:1.f];
    } else {
        //没收藏
        TagCollect *tag = [TagCollect MR_createEntity];
        tag.tagName = self.tagName;
        tag.tagUrl = self.mainUrl;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        self.collectImageView.image = [[UIImage imageNamed:@"collected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"add_to_favorite_success", nil)];
        [SVProgressHUD dismissWithDelay:1.f];
    }
}

- (void)updateResource {
    NSString *url = nil;
    if ([self.tagName isEqualToString:NSLocalizedString(@"similar_gallery", nil)]) {
        url = [NSString stringWithFormat:@"%@&page=%ld",self.mainUrl,(long)self.pageIndex];
    }
    else {
        url = [NSString stringWithFormat:@"%@?page=%ld",self.mainUrl,(long)self.pageIndex];
    }
    [HentaiParser requestListAtFilterUrl:url forExHentai:self.isExHentai completion: ^(HentaiParserStatus status, NSArray *listArray) {
        if (status && [listArray count]) {
            if ([self.tableView.mj_header isRefreshing]) {
                [self.datas removeAllObjects];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
            }
            else if ([self.tableView.mj_footer isRefreshing]) {
                [self.tableView.mj_footer endRefreshing];
            }
            else {
                [self.datas removeAllObjects];
            }
            [self.datas addObjectsFromArray:listArray];
            [self.tableView reloadData];
        }
        else {
            if ([self.tableView.mj_header isRefreshing]) {
                [self.tableView.mj_header endRefreshing];
                [self.datas removeAllObjects];
            }
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
            [self.tableView reloadData];
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
            [UIView animateWithDuration:0.25f animations:^{
                self.statueView.alpha = 0;
                self.statueView.frame = CGRectMake(0, 0, kScreenWidth, 0);
                self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                [self.view layoutIfNeeded];
            }];
        } else {
            self.tableView.bounces = NO;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
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
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        //_tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
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
