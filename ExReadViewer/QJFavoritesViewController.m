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
@property (strong, nonatomic) NSMutableArray *datas;
@property (strong, nonatomic) NSArray *keyArr;
@property (strong, nonatomic) QJDataManager *manager;

@end

@implementation QJFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateResource];
}

- (void)creatUI {
    NSString *localPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [localPath  stringByAppendingPathComponent:@"QJCoreDataModel.db"];
    NSLog(@"%@",filePath);
    self.manager = [[QJDataManager alloc] initWithCoreData:@"Favorites" modelName:@"QJCoreDataModel" sqlPath:filePath success:nil fail:nil];
    
    self.title = NSLocalizedString(@"favorites", nil);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
}

- (void)updateResource {
    [self.manager readEntity:@[] ascending:NO filterStr:nil success:^(NSArray *results) {
        if (results.count) {
            [self.datas removeAllObjects];
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
